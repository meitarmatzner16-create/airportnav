import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/flight.dart';
import '../providers/flight_providers.dart';

const _gutter = AppSpacing.gutter;
const _sectionGap = AppSpacing.sectionGap;

/// Full-screen flight board — choose the active flight.
/// Route: /flights  (top-level, no bottom nav shell)
class FlightsBoardScreen extends ConsumerWidget {
  const FlightsBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final detectedAirport = ref.watch(detectedAirportProvider);
    final upcomingFlights = ref.watch(upcomingFlightsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ── Title block ──────────────────────────────────────────
            ScreenHeader(
              greeting: _timeGreeting(),
              title: 'Departing soon',
              subtitle: 'Choose your flight',
              bottomPadding: _sectionGap,
              actions: [
                TonalPill(
                  label: 'Home',
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                ),
                TonalPill(
                  label: detectedAirport,
                  icon: Icons.gps_fixed_rounded,
                ),
              ],
            ),

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
                    onTap: () {
                      ref.read(selectedFlightProvider.notifier).state = flight;
                      context.pop();
                    },
                  ),
                ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  static String _timeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Flight card for the board
// ─────────────────────────────────────────────────────────────────────────────

class _BoardFlightCard extends StatelessWidget {
  final Flight flight;
  final bool isDark;
  final VoidCallback onTap;

  const _BoardFlightCard({
    required this.flight,
    required this.isDark,
    required this.onTap,
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
    final cardBg = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: hairline, width: 1),
            boxShadow: AppShadows.card,
          ),
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
                        color: isDark
                            ? AppColors.skyAlpha15
                            : AppColors.skyAlpha10,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(Icons.flight_rounded,
                          color: isDark ? AppColors.dSky : AppColors.sky,
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

                // ── Footer row: gate + "Select →" ────────────────────
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

