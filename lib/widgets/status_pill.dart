import 'package:flutter/material.dart';
import '../models/member.dart';
import '../theme/app_theme.dart';

class StatusPill extends StatelessWidget {
  final MemberStatus status;

  const StatusPill({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final meta = AppTheme.getStatusMeta(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: meta.glow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: meta.color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: meta.color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            meta.label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: meta.color,
            ),
          ),
        ],
      ),
    );
  }
}
