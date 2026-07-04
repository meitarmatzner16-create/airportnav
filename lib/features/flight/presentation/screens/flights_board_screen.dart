import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/flight.dart';
import '../providers/flight_providers.dart';

const _gutter = AppSpacing.gutter;
const _sectionGap = AppSpacing.sectionGap;

/// Full-screen flight board — choose the active flight.
/// Route: /flights  (top-level, no bottom nav shell)
class FlightsBoardScreen extends ConsumerWidget {
  const FlightsBoardScreen({super.key});

  static const _airports = ['JFK', 'LAX', 'LHR', 'CDG', 'DXB', 'SIN', 'NRT', 'SFO'];

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
            // ── Top bar ──────────────────────────────────────────────
            _BoardTopBar(
              detectedAirport: detectedAirport,
              airports: FlightsBoardScreen._airports,
              isDark: isDark,
              onChangeAirport: (v) {
                ref.read(detectedAirportProvider.notifier).state = v;
              },
              onBack: () => context.pop(),
            ),

            // ── Title block ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(_gutter, 8, _gutter, _sectionGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _timeGreeting(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Departing soon',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      color: isDark ? AppColors.dText : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose your flight',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
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
// Board top bar — "← Home" pill + airport chip
// ─────────────────────────────────────────────────────────────────────────────

class _BoardTopBar extends StatelessWidget {
  final String detectedAirport;
  final List<String> airports;
  final bool isDark;
  final ValueChanged<String> onChangeAirport;
  final VoidCallback onBack;

  const _BoardTopBar({
    required this.detectedAirport,
    required this.airports,
    required this.isDark,
    required this.onChangeAirport,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(_gutter, 12, _gutter, 4),
      child: Row(
        children: [
          // ← Home pill
          Semantics(
            label: 'Go back to home',
            button: true,
            child: GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: Container(
                constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.smMd, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.skyAlpha15
                      : AppColors.skyAlpha10,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: isDark
                        ? AppColors.skyAlpha20
                        : AppColors.skyAlpha15,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 12,
                      color: isDark ? AppColors.dSky : AppColors.sky,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Home',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isDark ? AppColors.dSky : AppColors.sky,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),

          // Airport chip
          _BoardAirportChip(
            value: detectedAirport,
            airports: airports,
            isDark: isDark,
            onChanged: onChangeAirport,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Airport selector chip (board-local variant)
// ─────────────────────────────────────────────────────────────────────────────

class _BoardAirportChip extends StatelessWidget {
  final String value;
  final List<String> airports;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _BoardAirportChip({
    required this.value,
    required this.airports,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.smMd, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.skyAlpha15 : AppColors.skyAlpha10,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
            color: isDark ? AppColors.skyAlpha20 : AppColors.skyAlpha15,
            width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gps_fixed_rounded,
              size: 12,
              color: isDark ? AppColors.dSky : AppColors.sky),
          const SizedBox(width: 5),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              icon: Icon(Icons.arrow_drop_down_rounded,
                  size: 16,
                  color: isDark ? AppColors.dSky : AppColors.sky),
              style: theme.textTheme.labelLarge?.copyWith(
                color: isDark ? AppColors.dSky : AppColors.sky,
                fontWeight: FontWeight.w700,
              ),
              dropdownColor: isDark ? AppColors.dSurface : AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              items: [
                for (final a in airports)
                  DropdownMenuItem(value: a, child: Text(a)),
              ],
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Flight card for the board (same visual DNA as home_screen._FlightCard)
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
                    _StatusPill(
                      status: flight.status,
                      delayMinutes: flight.delayMinutes,
                      isDark: isDark,
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

// ─────────────────────────────────────────────────────────────────────────────
// Status pill (local copy — same logic as home_screen)
// ─────────────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final String status;
  final int? delayMinutes;
  final bool isDark;

  const _StatusPill({
    required this.status,
    this.delayMinutes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, textColor, bgColor) = switch (status) {
      'boarding' => ('Boarding', AppColors.sky, AppColors.skyAlpha15),
      'on_time' => ('On time', AppColors.success, AppColors.successAlpha15),
      'delayed' => (
          'Delayed ${delayMinutes ?? ""}m',
          AppColors.warning,
          AppColors.warningAlpha15,
        ),
      'cancelled' => ('Cancelled', AppColors.error, AppColors.errorAlpha15),
      'scheduled' => ('Scheduled', AppColors.muted, AppColors.inkAlpha10),
      'landed' => ('Landed', AppColors.ink, AppColors.inkAlpha10),
      _ => (status, AppColors.muted, AppColors.inkAlpha10),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: textColor),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
