import 'package:flutter/material.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/widgets/app_card.dart';
import 'package:airport_nav/core/widgets/venue_image.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';

/// Explore list card: styled image + name + category/location + rating/visit/
/// open state, with a walk-time pill and a route button. Taps to detail.
class ExploreVenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback onTap;
  final VoidCallback? onRoute;

  const ExploreVenueCard({
    super.key,
    required this.venue,
    required this.onTap,
    this.onRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final walk = venue.walkMinutes;
    final visit = venue.avgVisitMinutes ?? walk;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.smMd),
      child: Row(
        children: [
          VenueImage(venue: venue, size: 56, radius: BorderRadius.circular(14)),
          const SizedBox(width: AppSpacing.smMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        venue.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (walk != null) ...[
                      const SizedBox(width: 8),
                      _WalkPill(minutes: walk),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${venue.categoryLabel} · ${venue.location}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 13, color: AppColors.star),
                    const SizedBox(width: 3),
                    Text(
                      venue.rating.toStringAsFixed(1),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (visit != null) ...[
                      const _Dot(),
                      Text('~${visit}m',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: AppColors.muted)),
                    ],
                    const _Dot(),
                    Text(
                      venue.isOpenNow ? 'Open' : 'Closed',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: venue.isOpenNow ? AppColors.success : AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _RouteButton(onTap: onRoute ?? onTap),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Text('·', style: TextStyle(color: AppColors.muted, height: 1.0)),
      );
}

class _WalkPill extends StatelessWidget {
  final int minutes;
  const _WalkPill({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_walk_rounded, size: 12, color: AppColors.muted),
          const SizedBox(width: 2),
          Text('${minutes}m',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.ink, fontWeight: FontWeight.w700, fontSize: 11)),
        ],
      ),
    );
  }
}

class _RouteButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RouteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.skyAlpha10,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.alt_route_rounded, size: 18, color: AppColors.sky),
        ),
      ),
    );
  }
}
