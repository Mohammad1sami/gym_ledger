import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/training_note.dart';
import 'avatar_widget.dart';
import 'glass_card.dart';

class NoteCard extends StatelessWidget {
  final TrainingNote note;
  final Member? member;
  final VoidCallback onTap;
  final bool compact;
  final bool showName;

  const NoteCard({
    super.key,
    required this.note,
    required this.member,
    required this.onTap,
    this.compact = false,
    this.showName = false,
  });

  @override
  Widget build(BuildContext context) {
    if (member == null) return const SizedBox.shrink();

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 14 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showName)
                Row(
                  children: [
                    AvatarWidget(name: member!.name, size: 24, imagePath: member!.imagePath),
                    const SizedBox(width: 8),
                    Text(
                      member!.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
              Text(
                note.formattedDate,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          if (showName) const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  note.diet,
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF475569),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 9),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.fitness_center_rounded, size: 14, color: Color(0xFF0D9488)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note.workout,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
