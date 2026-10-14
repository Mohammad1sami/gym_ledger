import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/member.dart';
import '../models/training_note.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/glass_card.dart';

class NoteDetailView extends StatelessWidget {
  final TrainingNote note;
  final Member? member;
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const NoteDetailView({
    super.key,
    required this.note,
    required this.member,
    required this.onBack,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (member == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'Member not found',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Nav Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _IconBtn(
                icon: Icons.chevron_left_rounded,
                onTap: onBack,
              ),
              _IconBtn(
                icon: Icons.edit_outlined,
                iconColor: const Color(0xFF6366F1),
                onTap: onEdit,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Member Info Header
          Row(
            children: [
              AvatarWidget(name: member!.name, size: 50, imagePath: member!.imagePath),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member!.name,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Logged ${note.formattedDate}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Diet Plan Glass Card
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFD97706)),
                    const SizedBox(width: 8),
                    Text(
                      'Diet Plan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  note.diet,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Workout Plan Glass Card
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fitness_center_rounded, size: 16, color: Color(0xFF0D9488)),
                    const SizedBox(width: 8),
                    Text(
                      'Workout Plan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  note.workout,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
              ],
            ),
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
