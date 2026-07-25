import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../theme/app_theme.dart';
import '../../features/flight/domain/entities/flight.dart';


/// Boarding-pass style card that shows the selected flight at a glance.
///
/// Layout:
///   [Header row]  "YOUR FLIGHT TODAY" · flight + airline  |  status pill
///   [Route row]   FROM (32 Poppins) - dashed arc + plane - TO (32 Poppins)
///   [Perforation] notch-dashed-notch separator
///   [Footer row]  Gate · Boards · Seat  + QR glyph
class BoardingPassCard extends StatelessWidget {
  final Flight flight;
  final VoidCallback? onTap;

  const BoardingPassCard({super.key, required this.flight, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;
    final bgColor = isDark ? AppColors.dBg : AppColors.paper;

    final timeFormat = DateFormat('HH:mm');
    final boardingTime = flight.departureTime.subtract(const Duration(minutes: 30));

    // Status pill colours
    final isDelayed = flight.status == 'delayed';
    final isOnTime = flight.status == 'on_time' || flight.status == 'scheduled';
    final pillBg = isDelayed
        ? AppColors.warningAlpha15
        : isOnTime
            ? AppColors.successAlpha15
            : AppColors.skyAlpha10;
    final pillText = isDelayed
        ? AppColors.warning
        : isOnTime
            ? AppColors.success
            : AppColors.sky;
    final pillLabel = isDelayed
        ? 'Delayed${flight.delayMinutes != null ? " +${flight.delayMinutes}m" : ""}'
        : isOnTime
            ? 'On time'
            : _capitalise(flight.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: hairline, width: 1),
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOUR FLIGHT TODAY',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.muted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${flight.flightNumber} · ${flight.airline}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? AppColors.dText : AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: pillBg,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      pillLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: pillText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Route row ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Departure
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.departureAirport,
                        style: AppTypography.mono(
                          fontSize: 32,
                          weight: FontWeight.w700,
                          color: isDark ? AppColors.dText : AppColors.ink,
                        ).copyWith(letterSpacing: -0.9),
                      ),
                      Text(
                        timeFormat.format(flight.departureTime),
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                  // Dashed arc + plane (custom painter)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 36,
                            child: CustomPaint(
                              painter: _DashedArcPainter(
                                color: isDark ? AppColors.dHairline : AppColors.hairline,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.flight_takeoff_rounded,
                                  size: 18,
                                  color: AppColors.sky,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Arrival
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        flight.arrivalAirport,
                        style: AppTypography.mono(
                          fontSize: 32,
                          weight: FontWeight.w700,
                          color: isDark ? AppColors.dText : AppColors.ink,
                        ).copyWith(letterSpacing: -0.9),
                      ),
                      Text(
                        flight.arrivalCity,
                        style: theme.textTheme.bodySmall?.copyWith(color: AppColors.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Perforation ──────────────────────────────────────────
            SizedBox(
              height: 14,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Left notch circle
                  Positioned(
                    left: -7,
                    top: 0,
                    child: _NotchCircle(color: bgColor, borderColor: hairline),
                  ),
                  // Dashed line
                  Positioned.fill(
                    left: 7,
                    right: 7,
                    child: CustomPaint(
                      painter: _DashedLinePainter(
                        color: hairline,
                      ),
                    ),
                  ),
                  // Right notch circle
                  Positioned(
                    right: -7,
                    top: 0,
                    child: _NotchCircle(color: bgColor, borderColor: hairline),
                  ),
                ],
              ),
            ),

            // ── Footer ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
              child: Row(
                children: [
                  if (flight.gate != null) ...[
                    Meta(label: 'Gate', value: flight.gate!),
                    const SizedBox(width: 24),
                  ],
                  Meta(
                    label: 'Boards',
                    value: timeFormat.format(boardingTime),
                  ),
                  const SizedBox(width: 24),
                  const Meta(label: 'Seat', value: '-'),
                  const Spacer(),
                  Icon(
                    Icons.qr_code_rounded,
                    size: 32,
                    color: isDark ? AppColors.dMuted : AppColors.muted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _capitalise(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');
  }
}

// ── Helper widget ──────────────────────────────────────────────────────────────
/// A label + value pair used in the boarding-pass footer.
class Meta extends StatelessWidget {
  final String label;
  final String value;

  const Meta({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10.5,
            color: AppColors.muted,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.mono(
            fontSize: 14,
            weight: FontWeight.w600,
            color: isDark ? AppColors.dText : AppColors.ink,
          ),
        ),
      ],
    );
  }
}

// ── Notch circle ───────────────────────────────────────────────────────────────
class _NotchCircle extends StatelessWidget {
  final Color color;
  final Color borderColor;

  const _NotchCircle({required this.color, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: borderColor, width: 1),
      ),
    );
  }
}

// ── Custom painters ────────────────────────────────────────────────────────────
class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashGap = 4.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset((x + dashWidth).clamp(0, size.width), y), paint);
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}

class _DashedArcPainter extends CustomPainter {
  final Color color;
  const _DashedArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, size.height * 0.1, size.width, size.height * 1.5);
    // Draw a dashed arc (approximate with PathMetrics)
    final path = Path()..addArc(rect, 3.14, -3.14);
    final pm = path.computeMetrics().first;
    const dashLen = 6.0;
    const gapLen = 4.0;
    double dist = 0;
    final total = pm.length;
    while (dist < total) {
      final end = (dist + dashLen).clamp(0.0, total);
      canvas.drawPath(pm.extractPath(dist, end), paint);
      dist += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(_DashedArcPainter old) => old.color != color;
}

