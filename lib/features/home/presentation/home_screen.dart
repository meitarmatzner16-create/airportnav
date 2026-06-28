import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/flight/domain/entities/flight.dart';
import '../../../features/flight/presentation/providers/flight_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _airports = ['JFK', 'LAX', 'LHR', 'CDG', 'DXB', 'SIN', 'NRT', 'SFO'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final detectedAirport = ref.watch(detectedAirportProvider);
    final upcomingFlights = ref.watch(upcomingFlightsProvider);
    final selectedFlight = ref.watch(selectedFlightProvider);
    final availableMinutes = ref.watch(availableTimeMinutesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryLight, AppColors.primary],
                ),
              ),
              child: const Icon(Icons.flight_rounded, size: 18, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.smMd),
            Text(
              'AirportNav',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        actions: [
          _AirportSelector(
            value: detectedAirport,
            onChanged: (value) {
              ref.read(detectedAirportProvider.notifier).state = value;
              ref.read(selectedFlightProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.smMd,
          AppSpacing.gutter,
          AppSpacing.xxl,
        ),
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: selectedFlight != null
                ? Padding(
                    key: ValueKey(selectedFlight.id),
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: _SelectedFlightCard(
                      flight: selectedFlight,
                      availableMinutes: availableMinutes ?? 0,
                      onClear: () {
                        ref.read(selectedFlightProvider.notifier).state = null;
                      },
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey('no_flight')),
          ),
          _SectionHeader(
            title: 'Departing soon',
            subtitle: selectedFlight == null
                ? 'Select your flight for personalized routes & offers'
                : 'Tap another flight to switch',
          ),
          const SizedBox(height: AppSpacing.md),
          if (upcomingFlights.isEmpty)
            _EmptyState(airport: detectedAirport)
          else
            ...upcomingFlights.map((flight) {
              final isSelected = selectedFlight?.id == flight.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.smMd),
                child: _FlightCard(
                  flight: flight,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(selectedFlightProvider.notifier).state = flight;
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selected flight hero card
// ─────────────────────────────────────────────────────────────────────────────
class _SelectedFlightCard extends StatelessWidget {
  final Flight flight;
  final int availableMinutes;
  final VoidCallback onClear;

  const _SelectedFlightCard({
    required this.flight,
    required this.availableMinutes,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat('HH:mm');
    final hours = availableMinutes ~/ 60;
    final mins = availableMinutes % 60;
    final timeLeft = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: AppShadows.lifted,
      ),
      padding: const EdgeInsets.all(AppSpacing.xl - 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'YOUR FLIGHT',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.whiteAlpha80,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),
              const Spacer(),
              _StatusBadge(
                status: flight.status,
                delayMinutes: flight.delayMinutes,
                onDark: true,
              ),
              const SizedBox(width: AppSpacing.sm),
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.whiteAlpha15,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${flight.flightNumber} · ${flight.airline}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.whiteAlpha80,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.smMd),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(flight.departureAirport,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        )),
                    Text(timeFormat.format(flight.departureTime),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.whiteAlpha80,
                        )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smMd),
                child: Column(
                  children: [
                    const Icon(Icons.flight_rounded,
                        color: Colors.white, size: 18),
                    const SizedBox(height: 4),
                    Container(
                      width: 60,
                      height: 1,
                      color: AppColors.whiteAlpha25,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(flight.arrivalAirport,
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        )),
                    Text(flight.arrivalCity,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.whiteAlpha80,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.smMd - 2),
            decoration: BoxDecoration(
              color: AppColors.whiteAlpha15,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.whiteAlpha20, width: 1),
            ),
            child: Row(
              children: [
                if (flight.gate != null) ...[
                  _InfoTile(
                    icon: Icons.door_sliding_rounded,
                    label: 'Gate',
                    value: flight.gate!,
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: AppColors.whiteAlpha20,
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.smMd),
                  ),
                ],
                Expanded(
                  child: _InfoTile(
                    icon: Icons.schedule_rounded,
                    label: 'Until gate',
                    value: timeLeft,
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

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: AppColors.whiteAlpha80, size: 16),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.whiteAlpha80,
                  letterSpacing: 0.4,
                )),
            Text(value,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Upcoming flight card
// ─────────────────────────────────────────────────────────────────────────────
class _FlightCard extends StatelessWidget {
  final Flight flight;
  final bool isSelected;
  final VoidCallback onTap;

  const _FlightCard({
    required this.flight,
    required this.isSelected,
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.hairline,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected ? AppShadows.cardHover : AppShadows.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryAlpha10,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Icon(Icons.flight_rounded,
                          color: AppColors.primary, size: 18),
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
                            ),
                          ),
                          Text(
                            flight.airline,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(
                      status: flight.status,
                      delayMinutes: flight.delayMinutes,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.smMd),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(flight.departureAirport,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        Text(timeFormat.format(flight.departureTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            )),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smMd),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm, vertical: 2),
                              decoration: BoxDecoration(
                                color: urgent
                                    ? AppColors.errorAlpha15
                                    : AppColors.surfaceVariant,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusFull),
                              ),
                              child: Text(
                                'in $timeUntil',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: urgent
                                      ? AppColors.error
                                      : AppColors.onSurfaceVariant,
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
                                    color: AppColors.hairline,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.flight_takeoff_rounded,
                                      size: 14, color: AppColors.onSurfaceVariant),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: AppColors.hairline,
                                  ),
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
                        Text(flight.arrivalAirport,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                        Text(flight.arrivalCity,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            )),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.smMd),
                Row(
                  children: [
                    if (flight.gate != null) ...[
                      const Icon(Icons.door_sliding_rounded,
                          size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('Gate ${flight.gate}',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant)),
                      const SizedBox(width: AppSpacing.smMd),
                    ],
                    if (flight.terminal != null) ...[
                      const Icon(Icons.business_rounded,
                          size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(flight.terminal!,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant)),
                      ),
                    ],
                    const Spacer(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isSelected
                          ? Container(
                              key: const ValueKey('selected'),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.smMd, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius:
                                    BorderRadius.circular(AppSpacing.radiusFull),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_rounded,
                                      color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text('Selected',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                            )
                          : Row(
                              key: const ValueKey('tap_to_select'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Select',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(width: 2),
                                const Icon(Icons.chevron_right_rounded,
                                    color: AppColors.accent, size: 16),
                              ],
                            ),
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
// Helper widgets
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String airport;
  const _EmptyState({required this.airport});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
            ),
            child: const Icon(Icons.flight_takeoff_rounded,
                size: 30, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.smMd),
          Text(
            'No upcoming flights',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Nothing departing $airport in the next 3.5h',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AirportSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _AirportSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smMd, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentAlpha10,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.accentAlpha20, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.gps_fixed_rounded,
              size: 14, color: AppColors.accent),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              icon: const Icon(Icons.arrow_drop_down_rounded,
                  size: 18, color: AppColors.accent),
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              items: [
                for (final a in HomeScreen._airports)
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

class _StatusBadge extends StatelessWidget {
  final String status;
  final int? delayMinutes;
  final bool onDark;

  const _StatusBadge({
    required this.status,
    this.delayMinutes,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color, bgColor) = switch (status) {
      'boarding' => ('Boarding', AppColors.statusBoarding, AppColors.accentAlpha15),
      'on_time' => ('On time', AppColors.statusOnTime, AppColors.successAlpha15),
      'delayed' => ('Delayed ${delayMinutes ?? ""}m', AppColors.statusDelayed, AppColors.warningAlpha15),
      'cancelled' => ('Cancelled', AppColors.statusCancelled, AppColors.errorAlpha15),
      'scheduled' => ('Scheduled', AppColors.info, AppColors.primaryAlpha10),
      'landed' => ('Landed', AppColors.statusLanded, AppColors.primaryAlpha10),
      _ => (status, AppColors.onSurfaceVariant, AppColors.primaryAlpha10),
    };

    final textColor = onDark ? Colors.white : color;
    final containerBg = onDark ? AppColors.whiteAlpha20 : bgColor;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2, vertical: 4),
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: textColor,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
