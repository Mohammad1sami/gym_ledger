import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/member.dart';

class AppTheme {
  // Background gradient colors (Light Glass Theme)
  static const Color bgLight1 = Color(0xFFF0F4F8); // Soft Ice Blue Slate
  static const Color bgLight2 = Color(0xFFE6EEF8); // Soft Periwinkle
  static const Color bgLight3 = Color(0xFFECEBF8); // Soft Lavender Tint

  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgLight1, bgLight2, bgLight3],
    stops: [0.0, 0.5, 1.0],
  );

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Primary Action Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF0284C7)],
  );

  // WhatsApp Gradient
  static const LinearGradient whatsappGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
  );

  // Status colors (Light Theme accessible contrast)
  static const Color activeColor = Color(0xFF0D9488);
  static const Color activeGlow = Color(0x3314B8A6);

  static const Color expiringColor = Color(0xFFD97706);
  static const Color expiringGlow = Color(0x33F59E0B);

  static const Color expiredColor = Color(0xFFE11D48);
  static const Color expiredGlow = Color(0x33F43F5E);

  static StatusMeta getStatusMeta(MemberStatus status) {
    switch (status) {
      case MemberStatus.active:
        return const StatusMeta(label: 'Active', color: activeColor, glow: activeGlow);
      case MemberStatus.expiring:
        return const StatusMeta(label: 'Expiring', color: expiringColor, glow: expiringGlow);
      case MemberStatus.expired:
        return const StatusMeta(label: 'Expired', color: expiredColor, glow: expiredGlow);
    }
  }

  // Glassmorphism styling tokens (Light Glass)
  static BoxDecoration glassDecoration({double borderRadius = 22, Color? color, Border? border}) {
    return BoxDecoration(
      color: color ?? Colors.white.withOpacity(0.65),
      borderRadius: BorderRadius.circular(borderRadius),
      border: border ?? Border.all(color: Colors.white.withOpacity(0.85), width: 1.2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F0F172A),
          blurRadius: 20,
          offset: Offset(0, 6),
        ),
      ],
    );
  }

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: bgLight1,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6366F1),
        secondary: Color(0xFF0284C7),
        surface: Color(0xFFF8FAFC),
      ),
    );
  }
}

class StatusMeta {
  final String label;
  final Color color;
  final Color glow;

  const StatusMeta({
    required this.label,
    required this.color,
    required this.glow,
  });
}

