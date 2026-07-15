import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Value-proposition banner: a calm neutral card with a headline, supporting
/// line, and a faint airport line-illustration bleeding off the right edge.
class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = isDark ? AppColors.dSurface : const Color(0xFFF1F3F6);
    final titleColor = isDark ? AppColors.dText : AppColors.ink;
    final bodyColor = isDark ? AppColors.dMuted : AppColors.muted;
    final artColor = isDark ? AppColors.dHairline : const Color(0xFFCED4DE);

    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 190,
            child: CustomPaint(painter: _AirportArtPainter(color: artColor)),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 210,
                  child: Text(
                    'Everything in the airport.\nFinally, in one place.',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.smMd),
                SizedBox(
                  width: 220,
                  child: Text(
                    'Live flights, real-time navigation, and personalized recommendations.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: bodyColor,
                      height: 1.45,
                    ),
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

/// Faint line art: a terminal with an arched roof, a control tower, and a
/// plane climbing along a dotted path.
class _AirportArtPainter extends CustomPainter {
  final Color color;
  const _AirportArtPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final ground = h * 0.82;

    // Ground line
    canvas.drawLine(Offset(w * 0.05, ground), Offset(w, ground), stroke);

    // Terminal: arched roof + base
    final tLeft = w * 0.30;
    final tRight = w * 0.72;
    final tTop = ground - 46;
    final roof = Path()
      ..moveTo(tLeft, ground)
      ..lineTo(tLeft, tTop + 14)
      ..quadraticBezierTo((tLeft + tRight) / 2, tTop - 12, tRight, tTop + 14)
      ..lineTo(tRight, ground);
    canvas.drawPath(roof, stroke);
    // Terminal windows
    for (var i = 0; i < 3; i++) {
      final x = tLeft + 12 + i * 12.0;
      canvas.drawLine(Offset(x, ground), Offset(x, ground - 16), stroke);
    }

    // Control tower
    final towerX = w * 0.16;
    canvas.drawLine(Offset(towerX, ground), Offset(towerX, ground - 58), stroke);
    final cab = Path()
      ..moveTo(towerX - 8, ground - 58)
      ..lineTo(towerX + 8, ground - 58)
      ..lineTo(towerX + 6, ground - 72)
      ..lineTo(towerX - 6, ground - 72)
      ..close();
    canvas.drawPath(cab, stroke);

    // Dotted takeoff path
    final start = Offset(w * 0.20, ground - 8);
    final end = Offset(w * 0.95, h * 0.14);
    final control = Offset(w * 0.55, ground - 20);
    const steps = 14;
    for (var i = 0; i <= steps; i++) {
      final t = i / steps;
      final mt = 1 - t;
      final p = Offset(
        mt * mt * start.dx + 2 * mt * t * control.dx + t * t * end.dx,
        mt * mt * start.dy + 2 * mt * t * control.dy + t * t * end.dy,
      );
      if (i.isEven) canvas.drawCircle(p, 1.4, fill);
    }

    // Plane at the end of the path (simple upward chevron)
    canvas.save();
    canvas.translate(end.dx, end.dy);
    canvas.rotate(-math.pi / 5);
    final plane = Path()
      ..moveTo(0, -8)
      ..lineTo(6, 7)
      ..lineTo(0, 3)
      ..lineTo(-6, 7)
      ..close();
    canvas.drawPath(plane, fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AirportArtPainter old) => old.color != color;
}
