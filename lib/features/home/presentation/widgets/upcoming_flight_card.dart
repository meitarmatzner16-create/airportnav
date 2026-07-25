import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/airline_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../flight/domain/entities/flight.dart';

/// Rough gate-to-walk estimate (mock) - near gates (A) are closer than far (D).
int estimatedWalkMinutes(String? gate) {
  if (gate == null || gate.isEmpty) return 10;
  switch (gate[0].toUpperCase()) {
    case 'A':
      return 8;
    case 'B':
      return 10;
    case 'C':
      return 12;
    case 'D':
      return 14;
    default:
      return 12;
  }
}

/// "Your Upcoming Flight" - prominent summary for the selected flight:
/// destination, boards-in countdown, and a four-up stat row.
class UpcomingFlightCard extends StatelessWidget {
  final Flight flight;
  final VoidCallback onTap;

  const UpcomingFlightCard({
    super.key,
    required this.flight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final mutedColor = isDark ? AppColors.dMuted : AppColors.muted;

    final boarding = flight.departureTime.subtract(const Duration(minutes: 30));
    final boardsIn = boarding.difference(DateTime.now());
    final boardsInLabel = boardsIn.isNegative
        ? 'now'
        : boardsIn.inMinutes >= 60
            ? '${boardsIn.inHours}h ${boardsIn.inMinutes % 60}m'
            : '${boardsIn.inMinutes}m';
    final clock = DateFormat('h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Your Upcoming Flight'),
        const SizedBox(height: AppSpacing.smMd),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Ink(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: isDark ? Border.all(color: hairline, width: 1) : null,
                boxShadow: isDark ? null : AppShadows.card,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    // ── Top: destination + boards-in ──────────────────
                    Row(
                      children: [
                        AirlineTile(
                            flightNumber: flight.flightNumber, size: 48),
                        const SizedBox(width: AppSpacing.smMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${flight.arrivalCity} (${flight.arrivalAirport})',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                flight.flightNumber,
                                style: AppTypography.mono(
                                  fontSize: 12.5,
                                  weight: FontWeight.w600,
                                  color: mutedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Boards in',
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(color: mutedColor)),
                            const SizedBox(height: 1),
                            Text(
                              boardsInLabel,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                              ),
                            ),
                            Text(clock.format(boarding),
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(color: mutedColor)),
                          ],
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(Icons.chevron_right_rounded,
                            size: 22, color: mutedColor),
                      ],
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Divider(height: 1, color: hairline),
                    ),
                    // ── Bottom: four stats ────────────────────────────
                    Row(
                      children: [
                        _Stat(
                          icon: Icons.meeting_room_outlined,
                          label: 'Gate',
                          value: flight.gate ?? '-',
                        ),
                        _Stat(
                          icon: Icons.schedule_rounded,
                          label: 'Departs',
                          value: clock.format(flight.departureTime),
                        ),
                        _Stat(
                          icon: Icons.directions_walk_rounded,
                          label: 'Est. Walk',
                          value: '${estimatedWalkMinutes(flight.gate)} min',
                        ),
                        _Stat(
                          icon: Icons.apartment_rounded,
                          label: 'Terminal',
                          value: 'T${flight.terminal ?? '-'}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Stat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final mutedColor = isDark ? AppColors.dMuted : AppColors.muted;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: mutedColor),
          const SizedBox(height: 6),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(color: mutedColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 1),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
