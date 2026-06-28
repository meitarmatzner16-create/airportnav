import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/flight.dart';
import 'flight_status_badge.dart';

class FlightCard extends StatelessWidget {
  final Flight flight;
  final VoidCallback? onTap;

  const FlightCard({
    super.key,
    required this.flight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final theme = Theme.of(context);

    return Card(
      elevation: AppSpacing.cardElevation,
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Airline & flight number row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${flight.airline}  ${flight.flightNumber}',
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  FlightStatusBadge(status: flight.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Route row
              Row(
                children: [
                  // Departure
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight.departureAirport,
                          style: theme.textTheme.headlineSmall,
                        ),
                        Text(
                          flight.departureCity,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeFormat.format(flight.departureTime),
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColors.onSurfaceVariant,
                      size: AppSpacing.iconMd,
                    ),
                  ),

                  // Arrival
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          flight.arrivalAirport,
                          style: theme.textTheme.headlineSmall,
                        ),
                        Text(
                          flight.arrivalCity,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeFormat.format(flight.arrivalTime),
                          style: theme.textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Gate / Terminal info
              if (flight.gate != null || flight.terminal != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    if (flight.terminal != null)
                      _infoChip(
                        context,
                        'Terminal ${flight.terminal}',
                        Icons.business,
                      ),
                    if (flight.terminal != null && flight.gate != null)
                      const SizedBox(width: AppSpacing.sm),
                    if (flight.gate != null)
                      _infoChip(
                        context,
                        'Gate ${flight.gate}',
                        Icons.door_front_door_outlined,
                      ),
                    if (flight.delayMinutes != null) ...[
                      const Spacer(),
                      Text(
                        '+${flight.delayMinutes} min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFD97706),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(BuildContext context, String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
