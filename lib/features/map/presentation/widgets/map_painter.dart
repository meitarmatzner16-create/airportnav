import 'package:flutter/material.dart';
import 'package:airport_nav/features/map/domain/entities/map_floor.dart';

class MapPainter extends CustomPainter {
  final MapFloor floor;

  MapPainter({required this.floor});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / floor.width;
    final scaleY = size.height / floor.height;

    // Background
    final bgPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bgPaint,
    );

    final wallPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final roomFill = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final corridorPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;

    final gateAreaPaint = Paint()
      ..color = const Color(0xFFDDE4F7)
      ..style = PaintingStyle.fill;

    // Draw main terminal outline
    final terminalRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        20 * scaleX,
        20 * scaleY,
        (floor.width - 40) * scaleX,
        (floor.height - 40) * scaleY,
      ),
      Radius.circular(12 * scaleX),
    );
    canvas.drawRRect(terminalRect, corridorPaint);
    canvas.drawRRect(terminalRect, wallPaint);

    // Draw main corridor (horizontal center)
    final corridorRect = Rect.fromLTWH(
      40 * scaleX,
      (floor.height * 0.4) * scaleY,
      (floor.width - 80) * scaleX,
      (floor.height * 0.2) * scaleY,
    );
    canvas.drawRect(corridorRect, corridorPaint);
    canvas.drawRect(corridorRect, wallPaint..strokeWidth = 1.0);

    // Draw gate areas (top and bottom wings)
    // Top gate area
    final topGateArea = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        40 * scaleX,
        30 * scaleY,
        (floor.width - 80) * scaleX,
        (floor.height * 0.25) * scaleY,
      ),
      Radius.circular(8 * scaleX),
    );
    canvas.drawRRect(topGateArea, gateAreaPaint);
    canvas.drawRRect(topGateArea, wallPaint);

    // Bottom gate area
    final bottomGateArea = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        40 * scaleX,
        (floor.height * 0.65) * scaleY,
        (floor.width - 80) * scaleX,
        (floor.height * 0.25) * scaleY,
      ),
      Radius.circular(8 * scaleX),
    );
    canvas.drawRRect(bottomGateArea, gateAreaPaint);
    canvas.drawRRect(bottomGateArea, wallPaint);

    // Draw shop/service rooms in center area
    wallPaint.strokeWidth = 1.5;

    // Left side rooms
    _drawRoom(canvas, 150, floor.height * 0.42, 120, floor.height * 0.16,
        scaleX, scaleY, roomFill, wallPaint);
    _drawRoom(canvas, 300, floor.height * 0.42, 120, floor.height * 0.16,
        scaleX, scaleY, roomFill, wallPaint);

    // Right side rooms
    _drawRoom(canvas, 580, floor.height * 0.42, 120, floor.height * 0.16,
        scaleX, scaleY, roomFill, wallPaint);
    _drawRoom(canvas, 730, floor.height * 0.42, 120, floor.height * 0.16,
        scaleX, scaleY, roomFill, wallPaint);

    // Draw grid lines for orientation (subtle)
    final gridPaint = Paint()
      ..color = const Color(0x80E2E8F0)
      ..strokeWidth = 0.5;

    for (double x = 100; x < floor.width; x += 100) {
      canvas.drawLine(
        Offset(x * scaleX, 20 * scaleY),
        Offset(x * scaleX, (floor.height - 20) * scaleY),
        gridPaint,
      );
    }
    for (double y = 100; y < floor.height; y += 100) {
      canvas.drawLine(
        Offset(20 * scaleX, y * scaleY),
        Offset((floor.width - 20) * scaleX, y * scaleY),
        gridPaint,
      );
    }
  }

  void _drawRoom(Canvas canvas, double x, double y, double w, double h,
      double scaleX, double scaleY, Paint fill, Paint stroke) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x * scaleX, y * scaleY, w * scaleX, h * scaleY),
      Radius.circular(4 * scaleX),
    );
    canvas.drawRRect(rect, fill);
    canvas.drawRRect(rect, stroke);
  }

  @override
  bool shouldRepaint(covariant MapPainter oldDelegate) {
    return oldDelegate.floor.id != floor.id;
  }
}
