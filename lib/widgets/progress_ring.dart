import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/member.dart';
import '../theme/app_theme.dart';

class MemberProgressRing extends StatelessWidget {
  final Member member;
  final double size;
  final double strokeWidth;

  const MemberProgressRing({
    super.key,
    required this.member,
    this.size = 50,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    final total = Member.planDays[member.plan] ?? 30;
    final left = math.max(0, member.daysLeft);
    final pct = (left / total).clamp(0.0, 1.0);
    final meta = AppTheme.getStatusMeta(member.status);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          progress: pct,
          color: meta.color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class HeroProgressRing extends StatelessWidget {
  final double total;
  final double activePct;
  final double size;
  final double strokeWidth;
  final Widget child;

  const HeroProgressRing({
    super.key,
    required this.total,
    required this.activePct,
    this.size = 150,
    this.strokeWidth = 11,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _HeroRingPainter(
              progress: activePct,
              strokeWidth: strokeWidth,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track line
    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      final startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _HeroRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _HeroRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    final trackPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    // Gradient Progress arc
    if (progress > 0) {
      final gradient = AppTheme.primaryGradient.createShader(rect);
      final progressPaint = Paint()
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      final startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeroRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.strokeWidth != strokeWidth;
  }
}
