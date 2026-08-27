import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/airline_tile.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../flight/domain/entities/flight.dart';
import '../../../flight/presentation/providers/flight_providers.dart';
import '../../../venues/presentation/providers/venue_providers.dart';
import '../../domain/entities/journey.dart';
import '../providers/journey_providers.dart';
import '../widgets/current_step_card.dart';
import '../widgets/disruption_banner.dart';
import '../widgets/free_time_strip.dart';
import '../widgets/journey_spine.dart';

const _gutter = AppSpacing.gutter;

/// One page for the whole journey. The spine is constant; the body is whatever
/// the current step needs - a flight list at step one, step cards after that.
class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final journey = ref.watch(journeyProvider);
    final editing = ref.watch(flightEditingProvider);

    // Keeps the ticker alive for exactly as long as this screen is mounted.
    ref.watch(journeyTickerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
        child: journey == null
            ? _NoStage(onPick: () => context.go('/home'))
            : ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: AppSpacing.smMd),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 0),
                    child: _Header(journey: journey),
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _gutter),
                    child: JourneySpine(
                      journey: journey,
                      onTap: () => context.push('/journey/steps'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (journey.awaitingFlight || editing)
                    journey.stage == JourneyStage.connecting
                        ? _ConnectionPicker(journey: journey, editing: editing)
                        : _FlightPicker(journey: journey)
                  else
                    _StepBody(journey: journey),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  final Journey journey;
  const _Header({required this.journey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final flight = journey.flight;
    final clock = DateFormat('H:mm');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.go('/home'),
                child: Text(
                  '‹ Home',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDark ? AppColors.dSky : AppColors.sky,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                flight == null
                    ? (journey.stage == JourneyStage.connecting
                        ? 'Connecting'
                        : 'Departing')
                    : '${flight.flightNumber} · ${flight.arrivalCity}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 2),
              Text(
                flight == null
                    ? 'Choose your flight to begin'
                    : '${flight.departureAirport} · departs ${clock.format(flight.departureTime)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
              // The board stays one tap away - people change their minds,
              // and committing to a flight forever would punish them for it.
              // A connection has TWO flights, so it reopens the two-column
              // picker; the departures board alone could never swap the
              // inbound.
              if (flight != null) ...[
                const SizedBox(height: 4),
                InkWell(
                  onTap: () {
                    if (journey.stage == JourneyStage.connecting) {
                      ref.read(flightEditingProvider.notifier).state = true;
                    } else {
                      context.push('/flights');
                    }
                  },
                  child: Text(
                    journey.stage == JourneyStage.connecting
                        ? 'Change flights ›'
                        : 'Change flight ›',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isDark ? AppColors.dSky : AppColors.sky,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (flight != null) ...[
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(status: flight.status, delayMinutes: flight.delayMinutes),
        ],
      ],
    );
  }
}

/// Step one. The board is the body of the page, not a separate destination.
class _FlightPicker extends ConsumerWidget {
  final Journey journey;
  const _FlightPicker({required this.journey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final flights = ref.watch(upcomingFlightsProvider);
    final step = journey.currentStep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step 1 of ${journey.steps.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isDark ? AppColors.dSky : AppColors.sky,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              Text(step.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(step.where,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (flights.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: _gutter),
            child: EmptyState(
              icon: Icons.flight_takeoff_rounded,
              title: 'No upcoming flights',
              message: 'Nothing departing in the next few hours.',
            ),
          )
        else
          for (final f in flights)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(_gutter, 0, _gutter, AppSpacing.sm),
              child: _FlightRow(
                flight: f,
                onTap: () =>
                    ref.read(selectedFlightProvider.notifier).state = f,
              ),
            ),
      ],
    );
  }
}

class _FlightRow extends StatelessWidget {
  final Flight flight;
  final VoidCallback onTap;

  const _FlightRow({required this.flight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final clock = DateFormat('H:mm');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.dSurface : AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.dHairline : AppColors.hairline,
          width: 1,
        ),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.smMd),
            child: Row(
              children: [
                AirlineTile(flightNumber: flight.flightNumber, size: 34),
                const SizedBox(width: AppSpacing.smMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${flight.arrivalCity} (${flight.arrivalAirport})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(flight.flightNumber,
                          style: AppTypography.mono(fontSize: 11, color: muted)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      clock.format(flight.departureTime),
                      style: AppTypography.mono(
                        fontSize: 14,
                        weight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text('Gate ${flight.gate ?? '-'}',
                        style:
                            theme.textTheme.labelSmall?.copyWith(color: muted)),
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

/// Step one of a connection: two columns of the board, side by side.
/// Left is the flight you came in on; right is the one you leave on.
/// The journey builds itself the moment both are chosen.
class _ConnectionPicker extends ConsumerWidget {
  final Journey journey;
  final bool editing;
  const _ConnectionPicker({required this.journey, this.editing = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final arrivals = ref.watch(arrivingFlightsProvider);
    final departures = ref.watch(upcomingFlightsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!editing) ...[
            Text(
              'Step 1 of ${journey.steps.length}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? AppColors.dSky : AppColors.sky,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            Text('Which flights connect?', style: theme.textTheme.titleLarge),
            const SizedBox(height: 2),
            Text('Pick the flight you came in on and the one you leave on.',
                style: theme.textTheme.bodySmall?.copyWith(color: muted)),
          ] else ...[
            Text('Change your flights', style: theme.textTheme.titleLarge),
            const SizedBox(height: 2),
            Text('Tap either column to swap - your journey rebuilds around it.',
                style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            const SizedBox(height: AppSpacing.smMd),
            PrimaryButton(
              label: 'Done',
              icon: Icons.check_rounded,
              onPressed: () =>
                  ref.read(flightEditingProvider.notifier).state = false,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PickColumn(
                  header: 'I arrived on',
                  flights: arrivals,
                  selectedId: journey.inboundFlight?.id,
                  isArrival: true,
                  emptyMessage: 'No recent arrivals here.',
                  onPick: (f) => ref
                      .read(selectedInboundFlightProvider.notifier)
                      .state = f,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _PickColumn(
                  header: 'My next flight',
                  flights: departures,
                  selectedId: journey.flight?.id,
                  isArrival: false,
                  emptyMessage: 'No departures soon.',
                  onPick: (f) =>
                      ref.read(selectedFlightProvider.notifier).state = f,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PickColumn extends StatelessWidget {
  final String header;
  final List<Flight> flights;
  final String? selectedId;
  final bool isArrival;
  final String emptyMessage;
  final void Function(Flight) onPick;

  const _PickColumn({
    required this.header,
    required this.flights,
    required this.selectedId,
    required this.isArrival,
    required this.emptyMessage,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: muted,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (flights.isEmpty)
          Text(emptyMessage,
              style: theme.textTheme.bodySmall?.copyWith(color: muted))
        else
          for (final f in flights) ...[
            _MiniFlightTile(
              flight: f,
              selected: f.id == selectedId,
              isArrival: isArrival,
              onTap: () => onPick(f),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
      ],
    );
  }
}

/// A board row squeezed to half-width: airline tile, number, place, time.
class _MiniFlightTile extends StatelessWidget {
  final Flight flight;
  final bool selected;
  final bool isArrival;
  final VoidCallback onTap;

  const _MiniFlightTile({
    required this.flight,
    required this.selected,
    required this.isArrival,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final sky = isDark ? AppColors.dSky : AppColors.sky;
    final clock = DateFormat('H:mm');
    final place = isArrival
        ? 'from ${flight.departureCity}'
        : 'to ${flight.arrivalCity}';
    final time = isArrival ? flight.arrivalTime : flight.departureTime;

    return Container(
      decoration: BoxDecoration(
        color: selected
            ? (isDark ? AppColors.skyAlpha15 : AppColors.skyTint)
            : (isDark ? AppColors.dSurface : AppColors.card),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: selected
            ? Border.all(color: sky, width: 2)
            : Border.all(
                color: isDark ? AppColors.dHairline : AppColors.hairline,
                width: 1,
              ),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AirlineTile(flightNumber: flight.flightNumber, size: 22),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        flight.flightNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.mono(
                          fontSize: 11,
                          weight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle_rounded, size: 15, color: sky),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  place,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${isArrival ? 'lands' : 'departs'} ${clock.format(time)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepBody extends ConsumerWidget {
  final Journey journey;
  const _StepBody({required this.journey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venues = ref.watch(allVenuesProvider);
    final next = journey.nextStep;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (journey.disruption != null) ...[
            DisruptionBanner(disruption: journey.disruption!),
            const SizedBox(height: AppSpacing.smMd),
          ],
          CurrentStepCard(journey: journey),
          if (next != null) ...[
            const SizedBox(height: AppSpacing.smMd),
            ThenCard(step: next, gate: journey.effectiveGate),
          ],
          const SizedBox(height: AppSpacing.lg),
          FreeTimeStrip(
            freeTime: journey.freeTime,
            venues: venues,
            onTap: (v) => context.push('/explore/venue/${v.id}'),
          ),
        ],
      ),
    );
  }
}

class _NoStage extends StatelessWidget {
  final VoidCallback onPick;
  const _NoStage({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_gutter),
        child: EmptyState(
          icon: Icons.explore_outlined,
          title: 'No journey yet',
          message:
              'What are you doing today? Pick departing, connecting or arrived on Home.',
          action: PrimaryButton(label: 'Go to Home', onPressed: onPick),
        ),
      ),
    );
  }
}
