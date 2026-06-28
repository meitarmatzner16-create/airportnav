import 'package:flutter/material.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/features/map/domain/entities/map_floor.dart';

class NavPathPainter extends CustomPainter {
  final NavPath navPath;
  final double mapWidth;
  final double mapHeight;

  NavPathPainter({
    required this.navPath,
    required this.mapWidth,
    required this.mapHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (navPath.waypoints.length < 2) return;

    final scaleX = size.width / mapWidth;
    final scaleY = size.height / mapHeight;

    // Draw path shadow
    final shadowPaint = Paint()
      ..color = AppColors.accentAlpha20
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(
      navPath.waypoints[0].x * scaleX,
      navPath.waypoints[0].y * scaleY,
    );
    for (int i = 1; i < navPath.waypoints.length; i++) {
      path.lineTo(
        navPath.waypoints[i].x * scaleX,
        navPath.waypoints[i].y * scaleY,
      );
    }
    canvas.drawPath(path, shadowPaint);

    // Draw dashed path
    final dashPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _drawDashedPath(canvas, path, dashPaint, 12.0, 8.0);

    // Draw start marker
    final startPoint = navPath.waypoints.first;
    _drawMarker(
      canvas,
      Offset(startPoint.x * scaleX, startPoint.y * scaleY),
      const Color(0xFF16A34A),
      const Color(0x4D16A34A),
    );

    // Draw end marker
    final endPoint = navPath.waypoints.last;
    _drawMarker(
      canvas,
      Offset(endPoint.x * scaleX, endPoint.y * scaleY),
      const Color(0xFFDC2626),
      const Color(0x4DDC2626),
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashLength,
    double gapLength,
  ) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        final extractedPath = metric.extractPath(distance, end);
        canvas.drawPath(extractedPath, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  void _drawMarker(Canvas canvas, Offset center, Color color, Color outerColor) {
    final outerPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 12, outerPaint);

    final innerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, innerPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 6, borderPaint);
  }

  @override
  bool shouldRepaint(covariant NavPathPainter oldDelegate) {
    return oldDelegate.navPath.fromPoiId != navPath.fromPoiId ||
        oldDelegate.navPath.toPoiId != navPath.toPoiId;
  }
}
