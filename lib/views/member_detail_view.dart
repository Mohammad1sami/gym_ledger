import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/member.dart';
import '../models/payment.dart';
import '../models/training_note.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/note_card.dart';
import '../widgets/payment_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/status_pill.dart';

class MemberDetailView extends StatelessWidget {
  final Member member;
  final List<TrainingNote> notes;
  final List<Payment> payments;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddNote;
  final Function(TrainingNote) onSelectNote;
  final VoidCallback onRecordPayment;
  final Function(Payment) onTogglePaymentStatus;

  const MemberDetailView({
    super.key,
    required this.member,
    required this.notes,
    required this.payments,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
    required this.onAddNote,
    required this.onSelectNote,
    required this.onRecordPayment,
    required this.onTogglePaymentStatus,
  });

  Future<void> _makeCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Call launch exception: $e');
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final whatsappSchemeUrl = Uri.parse('whatsapp://send?phone=91$cleanPhone');
    final whatsappWebUrl = Uri.parse('https://wa.me/91$cleanPhone');

    try {
      if (await canLaunchUrl(whatsappSchemeUrl)) {
        await launchUrl(whatsappSchemeUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(whatsappWebUrl)) {
        await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('WhatsApp launch exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = member.status;
    final d = member.daysLeft;
    final memberNotes = notes
        .where((n) => n.memberId == member.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final memberPayments = payments
        .where((p) => p.memberId == member.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      child: Column(
        children: [
          // Top Navigation Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _IconBtn(
                icon: Icons.chevron_left_rounded,
                onTap: onBack,
              ),
              Row(
                children: [
                  _IconBtn(
                    icon: Icons.edit_outlined,
                    iconColor: const Color(0xFF6366F1),
                    onTap: onEdit,
                  ),
                  const SizedBox(width: 8),
                  _IconBtn(
                    icon: Icons.delete_outline_rounded,
                    iconColor: const Color(0xFFE11D48),
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Member Hero Profile
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MemberProgressRing(member: member, size: 100, strokeWidth: 6),
                AvatarWidget(name: member.name, size: 80, imagePath: member.imagePath),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            member.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            member.phone,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 11),
          StatusPill(status: status),
          const SizedBox(height: 20),

          // Call & WhatsApp Action Buttons
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  onTap: () => _makeCall(member.phone),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.phone_rounded, size: 16, color: Color(0xFF0F172A)),
                      SizedBox(width: 7),
                      Text(
                        'Call',
                        style: TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openWhatsApp(member.phone),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppTheme.whatsappGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3325D366),
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 7),
                        Text(
                          'WhatsApp',
                          style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Plan & Membership Details Card
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.fitness_center_rounded,
                  iconColor: const Color(0xFF6366F1),
                  label: 'Plan',
                  value: member.plan,
                ),
                const _Divider(),
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  iconColor: const Color(0xFF0D9488),
                  label: 'Start date',
                  value: member.formattedStart,
                ),
                const _Divider(),
                _DetailRow(
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFFE11D48),
                  label: 'End date',
                  value: member.formattedEnd,
                ),
                const _Divider(),
                _DetailRow(
                  icon: Icons.notifications_none_rounded,
                  iconColor: const Color(0xFFD97706),
                  label: 'Status',
                  value: status == MemberStatus.expired
                      ? 'Expired ${d.abs()}d ago'
                      : '$d days remaining',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Payment & Billing Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Billing & Payments ',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '(${memberPayments.length})',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onRecordPayment,
                child: Row(
                  children: const [
                    Icon(Icons.add_circle_outline_rounded, size: 14, color: Color(0xFF4F46E5)),
                    SizedBox(width: 3),
                    Text(
                      'Record',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Payment Records Cards
          if (memberPayments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No payments recorded for this member',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
            )
          else
            Column(
              children: memberPayments
                  .map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PaymentCard(
                        payment: p,
                        member: member,
                        onStatusToggle: () => onTogglePaymentStatus(p),
                      ),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 18),

          // Training Notes Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Training notes ',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '(${memberNotes.length})',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onAddNote,
                child: Row(
                  children: const [
                    Icon(Icons.add_rounded, size: 14, color: Color(0xFF4F46E5)),
                    SizedBox(width: 3),
                    Text(
                      'Add',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Training Notes Cards
          if (memberNotes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No notes logged for this member yet',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
              ),
            )
          else
            Column(
              children: memberNotes
                  .map(
                    (n) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: NoteCard(
                        note: n,
                        member: member,
                        onTap: () => onSelectNote(n),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    this.iconColor = const Color(0xFF0F172A),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderRadius: 12,
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: 38,
        height: 38,
        child: Icon(icon, color: iconColor, size: 19),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 9),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 13),
      color: const Color(0xFFE2E8F0),
    );
  }
}
