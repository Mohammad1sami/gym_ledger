import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/member.dart';
import '../theme/app_theme.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  final double size;
  final MemberStatus? status;
  final String? imagePath;

  const AvatarWidget({
    super.key,
    required this.name,
    this.size = 44,
    this.status,
    this.imagePath,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  bool get _hasImage =>
      imagePath != null && imagePath!.isNotEmpty && File(imagePath!).existsSync();

  @override
  Widget build(BuildContext context) {
    final meta = status != null ? AppTheme.getStatusMeta(status!) : null;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (meta != null)
            Container(
              width: size + 8,
              height: size + 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [meta.glow, Colors.transparent],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _hasImage ? null : AppTheme.primaryGradient,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x336366F1),
                  blurRadius: 14,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: _hasImage
                ? ClipOval(
                    child: Image.file(
                      File(imagePath!),
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    _initials,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: size * 0.34,
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
