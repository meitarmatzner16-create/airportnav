import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum AppLogoVariant { sky, ink, mono }

/// Paints "The Pass": a notched boarding-pass tile whose interior turns into a
/// route and takes flight.
///
/// All geometry is defined on a 64-unit grid and scaled by `size / 64`, so the
/// mark is identical at 20px and 1024px.
class LogoPainter extends CustomPainter {
  final AppLogoVariant variant;
  final bool showRoute;
  final double tileProgress;
  final double routeProgress;
  final double planeProgress;

  const LogoPainter({
    required this.variant,
    required this.showRoute,
    this.tileProgress = 1,
    this.routeProgress = 1,
    this.planeProgress = 1,
  });

  // ── 64-grid constants ────────────────────────────────────────────────
  static const double _grid = 64;
  static const double _radius = 18; // corner radius
  static const double _notchR = 7.5; // notch radius
  static const double _notchCy = 30; // notch centre Y

  /// Tile outline with the two boarding-pass notches subtracted. Real
  /// geometry (not an overlay) so it stays crisp over any background.
  static Path tilePath(double s) {
    final k = s / _grid;
    final rrect = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s),
        Radius.circular(_radius * k),
      ));
    final notches = Path()
      ..addOval(
          Rect.fromCircle(center: Offset(0, _notchCy * k), radius: _notchR * k))
      ..addOval(
          Rect.fromCircle(center: Offset(s, _notchCy * k), radius: _notchR * k));
    return Path.combine(PathOperation.difference, rrect, notches);
  }

  static Path _planePath(double k) => Path()
    ..moveTo(49 * k, 15 * k)
    ..lineTo(27 * k, 25.5 * k)
    ..lineTo(36.5 * k, 29.5 * k)
    ..lineTo(40 * k, 39 * k)
    ..close();

  static Path _routePath(double k) => Path()
    ..moveTo(13 * k, 48 * k)
    ..quadraticBezierTo(25 * k, 47 * k, 33 * k, 38 * k);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final k = s / _grid;
    final tile = tilePath(s);
    final tileAlpha = tileProgress.clamp(0.0, 1.0);

    // ── Tile ───────────────────────────────────────────────────────────
    final tilePaint = Paint();
    switch (variant) {
      case AppLogoVariant.sky:
        tilePaint.shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sky2, AppColors.sky],
        ).createShader(Rect.fromLTWH(0, 0, s, s));
        tilePaint.color = Colors.white.withValues(alpha: tileAlpha);
        break;
      case AppLogoVariant.ink:
        tilePaint.color = AppColors.ink.withValues(alpha: tileAlpha);
        break;
      case AppLogoVariant.mono:
        tilePaint.color = AppColors.sky.withValues(alpha: tileAlpha);
        break;
    }

    if (tilePaint.shader != null && tileAlpha < 1) {
      // Fade a shader-filled path by compositing it through a layer.
      canvas.saveLayer(
        Rect.fromLTWH(0, 0, s, s),
        Paint()..color = Colors.white.withValues(alpha: tileAlpha),
      );
      canvas.drawPath(tile, tilePaint);
      canvas.restore();
    } else {
      canvas.drawPath(tile, tilePaint);
    }

    canvas.save();
    canvas.clipPath(tile);

    // ── Route dots (drawn along the extracted sub-path) ────────────────
    if (showRoute && routeProgress > 0) {
      final metrics = _routePath(k).computeMetrics().first;
      final len = metrics.length * routeProgress.clamp(0.0, 1.0);
      final dot = Paint()
        ..color = AppColors.amber
        ..style = PaintingStyle.fill;
      const spacing = 7.5; // grid units between dots
      for (double d = 0; d <= len; d += spacing * k) {
        final tan = metrics.getTangentForOffset(d);
        if (tan != null) canvas.drawCircle(tan.position, 1.7 * k, dot);
      }
    }

    // ── Plane ──────────────────────────────────────────────────────────
    if (planeProgress > 0) {
      final p = planeProgress.clamp(0.0, 1.0);
      canvas.save();
      canvas.translate(-3 * k * (1 - p), 4 * k * (1 - p));
      canvas.drawPath(
        _planePath(k),
        Paint()..color = Colors.white.withValues(alpha: p),
      );
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LogoPainter old) =>
      old.variant != variant ||
      old.showRoute != showRoute ||
      old.tileProgress != tileProgress ||
      old.routeProgress != routeProgress ||
      old.planeProgress != planeProgress;
}
