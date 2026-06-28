import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../providers/flight_providers.dart';
import '../widgets/flight_status_badge.dart';

class FlightDetailScreen extends ConsumerWidget {
  final String flightId;

  const FlightDetailScreen({super.key, required this.flightId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(flightRepositoryProvider);
    final flight = repository.getFlightById(flightId);
    final savedIds = ref.watch(savedFlightIdsProvider);
    final isSaved = savedIds.contains(flightId);
    final theme = Theme.of(context);

    if (flight == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flight Details')),
        body: const Center(child: Text('Flight not found')),
      );
    }

    final dateFormat = DateFormat('EEE, MMM d');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(flight.flightNumber),
        elevation: AppSpacing.appBarElevation,
        actions: [
          IconButton(
            icon: Icon(
              isSaved ? Icons.favorite : Icons.favorite_border,
              color: isSaved ? Colors.red : null,
            ),
            onPressed: () {
              ref.read(savedFlightIdsProvider.notifier).toggle(flightId);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              elevation: AppSpacing.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // Airline + status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flight.airline,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                flight.flightNumber,
                                style: theme.textTheme.headlineMedium,
                              ),
                            ],
                          ),
                        ),
                        FlightStatusBadge(status: flight.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Departure / Arrival info
                    Row(
                      children: [
                        // Departure
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flight.departureAirport,
                                style: theme.textTheme.displaySmall,
                              ),
                              Text(
                                flight.departureCity,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                timeFormat.format(flight.departureTime),
                                style: theme.textTheme.headlineLarge,
                              ),
                              Text(
                                dateFormat.format(flight.departureTime),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
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
                                style: theme.textTheme.displaySmall,
                              ),
                              Text(
                                flight.arrivalCity,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                timeFormat.format(flight.arrivalTime),
                                style: theme.textTheme.headlineLarge,
                              ),
                              Text(
                                dateFormat.format(flight.arrivalTime),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Flight progress indicator
                    _FlightProgressIndicator(status: flight.status),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Delay info
            if (flight.delayMinutes != null)
              Card(
                elevation: AppSpacing.cardElevation,
                color: const Color(0xFFFEF3C7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFD97706)),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Delayed by ${flight.delayMinutes} minutes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (flight.delayMinutes != null)
              const SizedBox(height: AppSpacing.md),

            // Gate & Terminal card
            Card(
              elevation: AppSpacing.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gate & Terminal',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailTile(
                            icon: Icons.door_front_door_outlined,
                            label: 'Gate',
                            value: flight.gate ?? '--',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _DetailTile(
                            icon: Icons.business,
                            label: 'Terminal',
                            value: flight.terminal ?? '--',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Flight duration card
            Card(
              elevation: AppSpacing.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flight Info',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _DetailTile(
                            icon: Icons.timer_outlined,
                            label: 'Duration',
                            value: _formatDuration(
                              flight.arrivalTime
                                  .difference(flight.departureTime),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _DetailTile(
                            icon: Icons.calendar_today_outlined,
                            label: 'Date',
                            value: dateFormat.format(flight.departureTime),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class _FlightProgressIndicator extends StatelessWidget {
  final String status;

  const _FlightProgressIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final progress = _progressForStatus(status);

    return Row(
      children: [
        // Departure dot
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: progress > 0 ? AppColors.primary : AppColors.outline,
          ),
        ),

        // Line
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 3,
                color: AppColors.outline,
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 3,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // Plane icon
        if (progress > 0 && progress < 1)
          Transform.translate(
            offset: const Offset(0, 0),
            child: const Icon(
              Icons.flight,
              size: 20,
              color: AppColors.primary,
            ),
          ),

        // Arrival line (remaining)
        if (progress > 0 && progress < 1)
          Expanded(
            child: Container(
              height: 3,
              color: AppColors.outline,
            ),
          ),

        // Arrival dot
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: progress >= 1 ? AppColors.primary : AppColors.outline,
          ),
        ),
      ],
    );
  }

  double _progressForStatus(String status) {
    switch (status) {
      case 'scheduled':
        return 0.0;
      case 'boarding':
        return 0.15;
      case 'on_time':
        return 0.5;
      case 'delayed':
        return 0.5;
      case 'landed':
        return 1.0;
      case 'cancelled':
        return 0.0;
      default:
        return 0.0;
    }
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0x80ECEEF2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
