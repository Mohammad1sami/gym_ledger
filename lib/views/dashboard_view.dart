import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/member.dart';
import '../models/payment.dart';
import '../models/training_note.dart';
import '../widgets/glass_card.dart';
import '../widgets/member_card.dart';
import '../widgets/note_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/stat_line.dart';

class DashboardView extends StatelessWidget {
  final List<Member> members;
  final List<TrainingNote> recentNotes;
  final List<Payment> payments;
  final Function(Member) onSelectMember;
  final Function(String filter) goFilter;
  final VoidCallback onOpenNotes;
  final VoidCallback onOpenBilling;

  const DashboardView({
    super.key,
    required this.members,
    required this.recentNotes,
    required this.payments,
    required this.onSelectMember,
    required this.goFilter,
    required this.onOpenNotes,
    required this.onOpenBilling,
  });

  @override
  Widget build(BuildContext context) {
    final total = members.length;
    final active = members.where((m) => m.status == MemberStatus.active).length;
    final expiring = members.where((m) => m.status == MemberStatus.expiring).length;
    final expired = members.where((m) => m.status == MemberStatus.expired).length;
    final activePct = total > 0 ? active / total : 0.0;

    final double collectedAmount = payments
        .where((p) => p.status == PaymentStatus.paid)
        .fold(0.0, (sum, p) => sum + p.amount);

    final attentionList = members
        .where((m) => m.status != MemberStatus.active)
        .toList()
      ..sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
    final topAttention = attentionList.take(3).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Studio Tag
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/icon/app_icon.jpg',
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'BruteWing',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Welcome back',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 26,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 22),

          // Hero Ring Card
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.12),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.7],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    HeroProgressRing(
                      total: total.toDouble(),
                      activePct: activePct,
                      size: 140,
                      strokeWidth: 11,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$total',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 34,
                              color: const Color(0xFF0F172A),
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'members',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatLine(color: const Color(0xFF0D9488), label: 'Active', value: active),
                          const SizedBox(height: 11),
                          StatLine(color: const Color(0xFFD97706), label: 'Expiring', value: expiring),
                          const SizedBox(height: 11),
                          StatLine(color: const Color(0xFFE11D48), label: 'Expired', value: expired),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Filter Cards
          Row(
            children: [
              Expanded(
                child: GlassCard(
                  onTap: () => goFilter('attention'),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.notifications_active_outlined, size: 20, color: Color(0xFFD97706)),
                      const SizedBox(height: 8),
                      Text(
                        '${expiring + expired}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'Follow-up',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassCard(
                  onTap: onOpenBilling,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.account_balance_wallet_outlined, size: 20, color: Color(0xFF0D9488)),
                      const SizedBox(height: 8),
                      Text(
                        '₹${(collectedAmount / 1000).toStringAsFixed(1)}k',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'Collected',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlassCard(
                  onTap: onOpenNotes,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.note_alt_outlined, size: 20, color: Color(0xFF6366F1)),
                      const SizedBox(height: 8),
                      Text(
                        '${recentNotes.length}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'Logs',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Needs Attention Header & List
          _SectionHeader(
            title: 'Needs attention',
            onMore: () => goFilter('attention'),
          ),
          const SizedBox(height: 12),
          if (topAttention.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  "Everyone's up to date ✨",
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            Column(
              children: topAttention
                  .map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: MemberCard(
                        member: m,
                        onTap: () => onSelectMember(m),
                      ),
                    ),
                  )
                  .toList(),
            ),

          const SizedBox(height: 18),

          // Recent Training Notes Header & List
          _SectionHeader(
            title: 'Recent training notes',
            onMore: onOpenNotes,
          ),
          const SizedBox(height: 12),
          if (recentNotes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  "No notes logged yet",
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            Column(
              children: recentNotes.take(2).map((n) {
                final member = members.firstWhere(
                  (m) => m.id == n.memberId,
                  orElse: () => members.first,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: NoteCard(
                    note: n,
                    member: member,
                    onTap: onOpenNotes,
                    compact: true,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onMore;

  const _SectionHeader({
    required this.title,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        GestureDetector(
          onTap: onMore,
          child: const Text(
            'See all',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF4F46E5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
