import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../venues/domain/entities/venue.dart';

/// How long a traveller typically spends somewhere, when the catalog does not
/// say. Only 10 venues carry an authored avgVisitMinutes; without a fallback
/// the fit calculation silently collapses to walk time alone.
int defaultDwellFor(String category) => switch (category.toLowerCase()) {
      'lounge' => 40,
      'dining' => 25,
      'cafe' => 15,
      'shopping' => 12,
      'services' => 10,
      _ => 15,
    };

/// Walk there, spend time, walk back. The return leg is the part people forget.
/// A venue with no walk time cannot be promised to fit, so it never does.
int venueCostMinutes(Venue v) {
  final walk = v.walkMinutes;
  if (walk == null) return 1 << 20;
  return (walk * 2) + (v.avgVisitMinutes ?? defaultDwellFor(v.category));
}

/// "You'll have 25 free minutes" - and only the places that actually fit.
class FreeTimeStrip extends StatelessWidget {
  final Duration? freeTime;
  final List<Venue> venues;
  final void Function(Venue)? onTap;

  const FreeTimeStrip({
    super.key,
    required this.freeTime,
    required this.venues,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final free = freeTime;
    if (free == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;

    if (free.isNegative) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.statusDelayedAlpha15,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.statusDelayed, width: 1),
        ),
        padding: const EdgeInsets.all(AppSpacing.smMd),
        child: Row(
          children: [
            const Icon(Icons.running_with_errors_rounded,
                size: 18, color: AppColors.statusDelayed),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                "You're ${free.inMinutes.abs()} min behind - skip the stop and go straight through.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.statusDelayed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final fits =
        venues.where((v) => venueCostMinutes(v) <= free.inMinutes).toList()
          ..sort((a, b) => (a.walkMinutes ?? 0).compareTo(b.walkMinutes ?? 0));
    if (fits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "You'll have ${free.inMinutes} free minutes",
          style: theme.textTheme.labelSmall?.copyWith(
            color: muted,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (var i = 0; i < fits.length && i < 3; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(child: _VenueTile(venue: fits[i], onTap: onTap)),
            ],
          ],
        ),
      ],
    );
  }
}

class _VenueTile extends StatelessWidget {
  final Venue venue;
  final void Function(Venue)? onTap;

  const _VenueTile({required this.venue, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;

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
          onTap: onTap == null ? null : () => onTap!(venue),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.smMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${venue.walkMinutes ?? '-'} min',
                  style: AppTypography.mono(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
