import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/member.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/glass_card.dart';
import '../widgets/status_pill.dart';

class NotificationsView extends StatelessWidget {
  final List<Member> members;

  const NotificationsView({
    super.key,
    required this.members,
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
    final queue = members
        .where((m) => m.status != MemberStatus.active)
        .toList()
      ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Header
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 4),
          child: Text(
            'Reminders',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Follow up with members, soonest first.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ),
        const SizedBox(height: 18),

        // List Queue
        Expanded(
          child: queue.isEmpty
              ? const Center(
                  child: Text(
                    'All caught up — no follow-ups needed',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
                  itemCount: queue.length,
                  itemBuilder: (context, index) {
                    final m = queue[index];
                    final status = m.status;
                    final d = m.daysLeft;
                    final meta = AppTheme.getStatusMeta(status);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                AvatarWidget(name: m.name, size: 40, status: status, imagePath: m.imagePath),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        status == MemberStatus.expired
                                            ? 'Expired ${d.abs()} days ago'
                                            : 'Expires in $d days',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: meta.color,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusPill(status: status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _makeCall(m.phone),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.85),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.phone_rounded, size: 13, color: Color(0xFF0F172A)),
                                          SizedBox(width: 6),
                                          Text(
                                            'Call',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF0F172A),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => _openWhatsApp(m.phone),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.whatsappGradient,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.chat_bubble_outline_rounded, size: 13, color: Colors.white),
                                          SizedBox(width: 6),
                                          Text(
                                            'WhatsApp',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
