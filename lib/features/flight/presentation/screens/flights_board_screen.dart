import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/flight.dart';
import '../providers/flight_providers.dart';

const _gutter = AppSpacing.gutter;
const _sectionGap = AppSpacing.sectionGap;

/// Full-screen flight board - choose the active flight.
/// Route: /flights  (top-level, no bottom nav shell)
class FlightsBoardScreen extends ConsumerWidget {
  const FlightsBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final detectedAirport = ref.watch(detectedAirportProvider);
    final upcomingFlights = ref.watch(upcomingFlightsProvider);
    final selectedFlight = ref.watch(selectedFlightProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Header - same shape as Home / Explore / Map ──────────
            Padding(
              padding: const EdgeInsets.fromLTRB(_gutter, 12, _gutter, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Departing soon',
                            style: theme.textTheme.displaySmall),
                        const SizedBox(height: 2),
                        Text(
                          '${upcomingFlights.length} flights · $detectedAirport · next 3.5h',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  _AirportChip(code: detectedAirport),
                ],
              ),
            ),
            const SizedBox(height: _sectionGap),

            // ── Flight list or empty state ───────────────────────────
            if (upcomingFlights.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    _gutter, 0, _gutter, _sectionGap),
                child: EmptyState(
                  icon: Icons.flight_takeoff_rounded,
                  title: 'No upcoming flights',
                  message: 'Nothing departing $detectedAirport in the next 3.5h',
                ),
              )
            else
              for (final flight in upcomingFlights)
                Padding(
                  padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 12),
                  child: _BoardFlightCard(
                    flight: flight,
                    isDark: isDark,
                    selected: flight.id == selectedFlight?.id,
                    // Select in place so the choice is visibly confirmed -
                    // navigating away immediately meant the user never saw it
                    // land. The snackbar offers the way onward.
                    onTap: () {
                      ref.read(selectedFlightProvider.notifier).state = flight;
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                                '${flight.flightNumber} is now your flight'),
                            duration: const Duration(seconds: 3),
                            action: SnackBarAction(
                              label: 'View',
                              textColor: Colors.white,
                              onPressed: () => context.go('/home'),
                            ),
                          ),
                        );
                    },
                  ),
                ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

}

/// Airport indicator, styled to match the chip on the Map header.
class _AirportChip extends StatelessWidget {
  final String code;
  const _AirportChip({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.gps_fixed_rounded, size: 15, color: AppColors.muted),
          const SizedBox(width: 6),
          Text(
            code,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Flight card for the board
// ─────────────────────────────────────────────────────────────────────────────

class _BoardFlightCard extends StatelessWidget {
  final Flight flight;
  final bool isDark;
  final bool selected;
  final VoidCallback onTap;

  const _BoardFlightCard({
    required this.flight,
    required this.isDark,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    final now = DateTime.now();
    final minutesUntil = flight.departureTime.difference(now).inMinutes;
    final timeUntil = minutesUntil >= 60
        ? '${minutesUntil ~/ 60}h ${minutesUntil % 60}m'
        : '${minutesUntil}m';
    final urgent = minutesUntil <= 60;
    final cardBg = selected
        ? (isDark ? AppColors.skyAlpha15 : AppColors.skyTint)
        : (isDark ? AppColors.dSurface : AppColors.card);
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;

    // Shadow on the outer Container so it follows the rounded corners -
    // an `Ink` decoration paints into the Material canvas and squares off.
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: selected
            ? Border.all(color: AppColors.sky, width: 2)
            : (isDark ? Border.all(color: hairline, width: 1) : null),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // ── Header row: icon + flight number + status ────────
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.sky
                            : (isDark
                                ? AppColors.skyAlpha15
                                : AppColors.skyAlpha10),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(
                          selected
                              ? Icons.check_rounded
                              : Icons.flight_rounded,
                          color: selected
                              ? Colors.white
                              : (isDark ? AppColors.dSky : AppColors.sky),
                          size: 18),
                    ),
                    const SizedBox(width: AppSpacing.smMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.flightNumber,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.dText : AppColors.ink,
                            ),
                          ),
                          Text(
                            flight.airline,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      status: flight.status,
                      delayMinutes: flight.delayMinutes,
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.smMd),

                // ── Route row: DEP ←──→ ARR ──────────────────────────
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight.departureAirport,
                          style: AppTypography.mono(
                            fontSize: 18,
                            weight: FontWeight.w700,
                            color: isDark ? AppColors.dText : AppColors.ink,
                          ),
                        ),
                        Text(
                          timeFormat.format(flight.departureTime),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: urgent
                                    ? AppColors.errorAlpha15
                                    : AppColors.skyAlpha10,
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusFull),
                              ),
                              child: Text(
                                'in $timeUntil',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: urgent
                                      ? AppColors.error
                                      : isDark
                                          ? AppColors.dSky
                                          : AppColors.sky,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      height: 1,
                                      color: isDark
                                          ? AppColors.dHairline
                                          : AppColors.hairline),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  child: Icon(
                                    Icons.flight_takeoff_rounded,
                                    size: 14,
                                    color: isDark
                                        ? AppColors.dMuted
                                        : AppColors.muted,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                      height: 1,
                                      color: isDark
                                          ? AppColors.dHairline
                                          : AppColors.hairline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          flight.arrivalAirport,
                          style: AppTypography.mono(
                            fontSize: 18,
                            weight: FontWeight.w700,
                            color: isDark ? AppColors.dText : AppColors.ink,
                          ),
                        ),
                        Text(
                          flight.arrivalCity,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.smMd),

                // ── Footer row: gate + select / selected state ───────
                Row(
                  children: [
                    if (flight.gate != null) ...[
                      Icon(
                        Icons.door_sliding_rounded,
                        size: 14,
                        color: isDark ? AppColors.dMuted : AppColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Gate ${flight.gate}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(width: AppSpacing.smMd),
                    ],
                    const Spacer(),
                    if (selected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.sky,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_rounded,
                                color: Colors.white, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              'Your flight',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Select',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isDark ? AppColors.dSky : AppColors.sky,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: isDark ? AppColors.dSky : AppColors.sky,
                            size: 16,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

