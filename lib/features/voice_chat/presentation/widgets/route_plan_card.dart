import 'package:flutter/material.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/voice_chat/domain/entities/chat_message.dart';

/// Premium minimal route plan: a clean white card with a tight neutral
/// timeline. The accent color is reserved for the total-time pill so it
/// doesn't compete with the rest of the screen.
class RoutePlanCard extends StatelessWidget {
  final RoutePlan plan;

  const RoutePlanCard({super.key, required this.plan});

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'dining':
        return Icons.restaurant_rounded;
      case 'duty_free':
        return Icons.local_offer_rounded;
      case 'luxury':
        return Icons.diamond_rounded;
      case 'electronics':
        return Icons.devices_rounded;
      case 'convenience':
        return Icons.local_convenience_store_rounded;
      case 'retail':
        return Icons.shopping_bag_rounded;
      case 'lounge':
        return Icons.airline_seat_individual_suite_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  String _styleLabel(String style) {
    switch (style) {
      case 'luxury':
        return 'Luxury';
      case 'fancy':
        return 'Fancy';
      case 'casual':
        return 'Casual';
      case 'street_vibes':
        return 'Street Vibes';
      case 'fast_food':
        return 'Fast Food';
      default:
        return style;
    }
  }

  IconData _directionIcon(String icon) {
    switch (icon) {
      case 'turn_left':
        return Icons.turn_left_rounded;
      case 'turn_right':
        return Icons.turn_right_rounded;
      case 'straight':
        return Icons.straight_rounded;
      case 'escalator_up':
        return Icons.arrow_upward_rounded;
      case 'escalator_down':
        return Icons.arrow_downward_rounded;
      case 'elevator_up':
      case 'elevator_down':
        return Icons.elevator_rounded;
      case 'destination':
        return Icons.flag_rounded;
      default:
        return Icons.navigation_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final hairline = isDark ? AppColors.hairlineDark : AppColors.hairline;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xs,
        AppSpacing.gutter,
        AppSpacing.smMd,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: hairline, width: 1),
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header — neutral row with title and a single accent pill.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.smMd,
                AppSpacing.md,
                AppSpacing.smMd,
              ),
              child: Row(
                children: [
                  Text(
                    'Your route',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 2,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentAlpha10,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded,
                            color: AppColors.accent, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${plan.totalMinutes} min',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: hairline),
            // Stops timeline
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                children: List.generate(plan.stops.length, (index) {
                  final stop = plan.stops[index];
                  return _StopRow(
                    stop: stop,
                    isFirst: index == 0,
                    isLast: index == plan.stops.length - 1,
                    icon: _categoryIcon(stop.category),
                    styleLabel: _styleLabel(stop.style),
                    directionIcon: _directionIcon,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  final RouteStop stop;
  final bool isFirst;
  final bool isLast;
  final IconData icon;
  final String styleLabel;
  final IconData Function(String) directionIcon;

  const _StopRow({
    required this.stop,
    required this.isFirst,
    required this.isLast,
    required this.icon,
    required this.styleLabel,
    required this.directionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline rail
        SizedBox(
          width: 32,
          child: Column(
            children: [
              if (!isFirst)
                Container(
                  width: 2,
                  height: stop.directions.isNotEmpty ? 12 : 8,
                  color: AppColors.hairline,
                ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceVariant,
                ),
                child: const Icon(Icons.circle, color: Colors.transparent, size: 0),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.hairline),
                ),
            ],
          ),
        ),
        // The icon overlay sits at the dot center via Stack.
        const SizedBox(width: AppSpacing.smMd),
        // Stop content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isFirst && stop.walkMinutes > 0) ...[
                  Row(
                    children: [
                      const Icon(Icons.directions_walk_rounded,
                          size: 12, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Walk ${stop.walkMinutes} min',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (stop.directions.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    ...stop.directions.map((step) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 1),
                          child: Row(
                            children: [
                              Icon(
                                directionIcon(step.icon),
                                size: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  step.instruction,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                  const SizedBox(height: AppSpacing.sm + 2),
                ],
                // Stop name + meta
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.accentAlpha10,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(icon, color: AppColors.accent, size: 14),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        stop.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$styleLabel · Floor ${stop.floor} · ${stop.location}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Stay ~${stop.stayMinutes} min',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
