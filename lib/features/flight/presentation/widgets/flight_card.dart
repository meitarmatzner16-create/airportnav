import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/flight.dart';
import 'flight_status_badge.dart';

/// Sky Pass–styled flight row card.
///
/// Uses AppCard surface (white/dSurface, hairline border, card shadow).
/// Flight number and times rendered in .mono.
/// FlightStatusBadge delegates to the kit StatusBadge.
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
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: AppCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Airline + flight number + status ──────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        flight.airline,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        flight.flightNumber,
                        style: AppTypography.mono(
                          fontSize: 12,
                          weight: FontWeight.w700,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                FlightStatusBadge(
                  status: flight.status,
                  delayMinutes: flight.delayMinutes,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.smMd),

            // ── Route row ─────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Departure
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flight.departureAirport,
                        style: AppTypography.mono(
                          fontSize: 20,
                          weight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        flight.departureCity,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeFormat.format(flight.departureTime),
                        style: AppTypography.mono(
                          fontSize: 16,
                          weight: FontWeight.w700,
                          color: isDark ? AppColors.dSky : AppColors.sky,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow divider
                Padding(
                  padding: const EdgeInsets.only(
                    top: 4,
                    left: AppSpacing.sm,
                    right: AppSpacing.sm,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: mutedColor,
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
                        style: AppTypography.mono(
                          fontSize: 20,
                          weight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        flight.arrivalCity,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: mutedColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeFormat.format(flight.arrivalTime),
                        style: AppTypography.mono(
                          fontSize: 16,
                          weight: FontWeight.w700,
                          color: isDark ? AppColors.dSky : AppColors.sky,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Gate / Terminal / Delay ───────────────────────────────
            if (flight.gate != null ||
                flight.terminal != null ||
                flight.delayMinutes != null) ...[
              const SizedBox(height: AppSpacing.smMd),
              Row(
                children: [
                  if (flight.terminal != null)
                    _InfoChip(
                      label: 'T${flight.terminal}',
                      icon: Icons.business_rounded,
                      muted: mutedColor,
                    ),
                  if (flight.terminal != null && flight.gate != null)
                    const SizedBox(width: AppSpacing.sm),
                  if (flight.gate != null)
                    _InfoChip(
                      label: 'Gate ${flight.gate}',
                      icon: Icons.door_front_door_outlined,
                      muted: mutedColor,
                    ),
                  if (flight.delayMinutes != null) ...[
                    const Spacer(),
                    Text(
                      '+${flight.delayMinutes} min',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color muted;

  const _InfoChip({
    required this.label,
    required this.icon,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSpacing.iconXs + 2, color: muted),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: muted,
              ),
        ),
      ],
    );
  }
}
