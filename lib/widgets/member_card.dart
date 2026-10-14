import 'package:flutter/material.dart';
import '../models/member.dart';
import 'avatar_widget.dart';
import 'glass_card.dart';
import 'progress_ring.dart';
import 'status_pill.dart';

class MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback onTap;

  const MemberCard({
    super.key,
    required this.member,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = member.status;
    final d = member.daysLeft;

    String subtitleText;
    if (status == MemberStatus.expired) {
      subtitleText = '${member.plan} · Expired ${d.abs()}d ago';
    } else if (status == MemberStatus.expiring) {
      subtitleText = '${member.plan} · ${d}d left';
    } else {
      subtitleText = '${member.plan} · Until ${member.formattedEndShort}';
    }

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MemberProgressRing(member: member, size: 46, strokeWidth: 3.5),
                AvatarWidget(name: member.name, size: 36, imagePath: member.imagePath),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(status: status),
        ],
      ),
    );
  }
}
