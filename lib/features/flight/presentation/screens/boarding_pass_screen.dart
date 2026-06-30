import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/boarding_pass_card.dart';
import '../../domain/entities/flight.dart';
import '../providers/flight_providers.dart';

class BoardingPassScreen extends ConsumerWidget {
  const BoardingPassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final flight = ref.watch(selectedFlightProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.dText : AppColors.ink,
          ),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Back',
        ),
        title: Text(
          'Boarding pass',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.dText : AppColors.ink,
          ),
        ),
        centerTitle: false,
      ),
      body: flight == null
          ? _NoFlightState(isDark: isDark)
          : _BoardingPassBody(flight: flight, isDark: isDark),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// No flight selected fallback
// ─────────────────────────────────────────────────────────────────────────────

class _NoFlightState extends StatelessWidget {
  final bool isDark;
  const _NoFlightState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flight_rounded,
              size: 48,
              color: isDark ? AppColors.dMuted : AppColors.muted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No flight selected',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.dText : AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Select a flight from the home screen to view your boarding pass.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main boarding pass body
// ─────────────────────────────────────────────────────────────────────────────

class _BoardingPassBody extends StatelessWidget {
  final Flight flight;
  final bool isDark;

  const _BoardingPassBody({required this.flight, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('d MMM yyyy');
    final boardingTime = flight.departureTime.subtract(const Duration(minutes: 30));

    // BCBP-style payload for the QR code
    final dateYmd = DateFormat('yyyyMMdd').format(flight.departureTime);
    final seatDisplay = flight.gate != null ? '14A' : '14A';
    final bcbpString =
        'BP|${flight.flightNumber}|${flight.departureAirport}>${flight.arrivalAirport}'
        '|$dateYmd|GATE:${flight.gate ?? "TBA"}|SEAT:$seatDisplay|SEQ:042';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Boarding pass panel ────────────────────────────────────
          _BoardingPassPanel(
            flight: flight,
            isDark: isDark,
            timeFormat: timeFormat,
            dateFormat: dateFormat,
            boardingTime: boardingTime,
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── QR code panel ─────────────────────────────────────────
          _QrPanel(
            isDark: isDark,
            bcbpString: bcbpString,
            flightNumber: flight.flightNumber,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Boarding pass panel (ticket visual)
// ─────────────────────────────────────────────────────────────────────────────

class _BoardingPassPanel extends StatelessWidget {
  final Flight flight;
  final bool isDark;
  final DateFormat timeFormat;
  final DateFormat dateFormat;
  final DateTime boardingTime;

  const _BoardingPassPanel({
    required this.flight,
    required this.isDark,
    required this.timeFormat,
    required this.dateFormat,
    required this.boardingTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBg = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;
    final bgColor = isDark ? AppColors.dBg : AppColors.paper;

    // Status pill values (reuse logic from BoardingPassCard)
    final isDelayed = flight.status == 'delayed';
    final isBoarding = flight.status == 'boarding';
    final isOnTime = flight.status == 'on_time' || flight.status == 'scheduled';
    final pillBg = isDelayed
        ? AppColors.warningAlpha15
        : isBoarding
            ? AppColors.skyAlpha15
            : isOnTime
                ? AppColors.successAlpha15
                : AppColors.inkAlpha10;
    final pillText = isDelayed
        ? AppColors.warning
        : isBoarding
            ? AppColors.sky
            : isOnTime
                ? AppColors.success
                : AppColors.muted;
    final pillLabel = isDelayed
        ? 'Delayed${flight.delayMinutes != null ? " +${flight.delayMinutes}m" : ""}'
        : isBoarding
            ? 'Boarding'
            : isOnTime
                ? 'On time'
                : _capitalise(flight.status);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: hairline, width: 1),
        boxShadow: AppShadows.hero,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gold accent bar at top
          Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.gold, AppColors.goldSoft, AppColors.gold],
              ),
            ),
          ),

          // ── Header: airline + flight + status ────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BOARDING PASS',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: AppColors.muted,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        flight.airline,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.dText : AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        flight.flightNumber,
                        style: AppTypography.mono(
                          fontSize: 13,
                          weight: FontWeight.w500,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: pillBg,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pillText,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        pillLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: pillText,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Route row ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Departure
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.departureAirport,
                        style: AppTypography.mono(
                          fontSize: 40,
                          weight: FontWeight.w700,
                          color: isDark ? AppColors.dText : AppColors.ink,
                        ).copyWith(letterSpacing: -1.0),
                      ),
                      Text(
                        flight.departureCity,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Plane icon in centre
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.flight_rounded,
                        size: 22,
                        color: AppColors.sky,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '→',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrival
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        flight.arrivalAirport,
                        style: AppTypography.mono(
                          fontSize: 40,
                          weight: FontWeight.w700,
                          color: isDark ? AppColors.dText : AppColors.ink,
                        ).copyWith(letterSpacing: -1.0),
                      ),
                      Text(
                        flight.arrivalCity,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Time row ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeFormat.format(flight.departureTime),
                  style: AppTypography.mono(
                    fontSize: 16,
                    weight: FontWeight.w500,
                    color: isDark ? AppColors.dText : AppColors.ink,
                  ),
                ),
                Text(
                  dateFormat.format(flight.departureTime),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
                Text(
                  timeFormat.format(flight.arrivalTime),
                  style: AppTypography.mono(
                    fontSize: 16,
                    weight: FontWeight.w500,
                    color: isDark ? AppColors.dText : AppColors.ink,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Perforation ──────────────────────────────────────────
          SizedBox(
            height: 14,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -7,
                  top: 0,
                  child: _NotchCircle(color: bgColor, borderColor: hairline),
                ),
                Positioned.fill(
                  left: 7,
                  right: 7,
                  child: CustomPaint(
                    painter: _DashedLinePainter(color: hairline),
                  ),
                ),
                Positioned(
                  right: -7,
                  top: 0,
                  child: _NotchCircle(color: bgColor, borderColor: hairline),
                ),
              ],
            ),
          ),

          // ── Meta grid ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Meta(
                        label: 'Passenger',
                        value: 'Passenger',
                      ),
                    ),
                    Expanded(
                      child: Meta(
                        label: 'Boards',
                        value: timeFormat.format(boardingTime),
                      ),
                    ),
                    Expanded(
                      child: Meta(
                        label: 'Seat',
                        value: '—',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Meta(
                        label: 'Gate',
                        value: flight.gate ?? '—',
                      ),
                    ),
                    Expanded(
                      child: Meta(
                        label: 'Terminal',
                        value: flight.terminal ?? '—',
                      ),
                    ),
                    Expanded(
                      child: Meta(
                        label: 'Class',
                        value: 'Economy',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _capitalise(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QR code panel
// ─────────────────────────────────────────────────────────────────────────────

class _QrPanel extends StatelessWidget {
  final bool isDark;
  final String bcbpString;
  final String flightNumber;

  const _QrPanel({
    required this.isDark,
    required this.bcbpString,
    required this.flightNumber,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final panelBg = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: hairline, width: 1),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          // White rounded container for QR (stays white in dark mode for scanner contrast)
          Container(
            width: 236,
            height: 236,
            padding: const EdgeInsets.all(AppSpacing.smMd),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.hairline,
                width: 1,
              ),
            ),
            child: QrImageView(
              data: bcbpString,
              version: QrVersions.auto,
              size: 212,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.ink,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.ink,
              ),
              backgroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Caption
          Text(
            'Scan at the gate',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Encoded reference in mono
          Text(
            flightNumber,
            style: AppTypography.mono(
              fontSize: 12,
              weight: FontWeight.w400,
              color: isDark ? AppColors.dMuted : AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers (copied so this screen is self-contained)
// ─────────────────────────────────────────────────────────────────────────────

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
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dashWidth).clamp(0.0, size.width), y),
        paint,
      );
      x += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
