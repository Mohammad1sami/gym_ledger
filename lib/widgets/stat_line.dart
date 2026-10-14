import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatLine extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const StatLine({
    super.key,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color,
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
            ),
          ),
        ),
        Text(
          '$value',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
