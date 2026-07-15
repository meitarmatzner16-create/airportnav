import 'package:flutter/material.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/widgets/app_card.dart';
import 'package:airport_nav/core/widgets/rating_stars.dart';
import 'package:airport_nav/features/lounges/domain/entities/lounge.dart';

/// Sky Pass–styled lounge row card.
///
/// Uses [AppCard] for the white/hairline/radiusLg/soft-shadow surface.
/// Access-type chip uses token colors. [RatingStars] gold. Public API unchanged.
class LoungeCard extends StatelessWidget {
  final Lounge lounge;
  final VoidCallback onTap;

  const LoungeCard({
    super.key,
    required this.lounge,
    required this.onTap,
  });

  // ── Access-type helpers ───────────────────────────────────────────────────

  static String _accessTypeLabel(String accessType) {
    return switch (accessType) {
      'priority_pass' => 'Priority Pass',
      'airline_lounge' => 'Airline Lounge',
      'pay_per_use' => 'Pay Per Use',
      'membership' => 'Membership',
      _ => accessType,
    };
  }

  /// Returns [iconBg, iconFg, chipBg, chipFg] from Sky Pass tokens.
  static (Color, Color, Color, Color) _accessColors(String accessType, bool isDark) {
    return switch (accessType) {
      'priority_pass' => (
          AppColors.successAlpha15,
          isDark ? AppColors.dSky : AppColors.gradientLoungeStart,
          AppColors.successAlpha15,
          isDark ? AppColors.dSky : AppColors.gradientLoungeStart,
        ),
      'airline_lounge' => (
          AppColors.inkAlpha10,
          isDark ? AppColors.dText : AppColors.ink,
          AppColors.inkAlpha10,
          isDark ? AppColors.dText : AppColors.ink,
        ),
      'pay_per_use' => (
          AppColors.skyAlpha10,
          isDark ? AppColors.dSky : AppColors.sky,
          AppColors.skyAlpha10,
          isDark ? AppColors.dSky : AppColors.sky,
        ),
      'membership' => (
          AppColors.inkAlpha10,
          isDark ? AppColors.dText : AppColors.ink,
          AppColors.inkAlpha10,
          isDark ? AppColors.dText : AppColors.ink,
        ),
      _ => (
          AppColors.skyAlpha10,
          isDark ? AppColors.dSky : AppColors.sky2,
          AppColors.skyAlpha10,
          isDark ? AppColors.dSky : AppColors.sky2,
        ),
    };
  }

  // ── Amenity helpers ───────────────────────────────────────────────────────

  static IconData _amenityIcon(String amenity) {
    return switch (amenity) {
      'wifi' => Icons.wifi_rounded,
      'shower' => Icons.shower_rounded,
      'food' => Icons.restaurant_rounded,
      'bar' => Icons.local_bar_rounded,
      'spa' => Icons.spa_rounded,
      'sleep_pods' => Icons.airline_seat_flat_rounded,
      'business_center' => Icons.business_center_rounded,
      _ => Icons.check_circle_outline_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inkColor = isDark ? AppColors.dText : AppColors.ink;
    final mutedColor = isDark ? AppColors.dMuted : AppColors.muted;
    final (iconBg, iconFg, chipBg, chipFg) = _accessColors(lounge.accessType, isDark);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: icon · name/badge · price ───────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lounge icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  Icons.airline_seat_recline_extra_rounded,
                  color: iconFg,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.smMd),

              // Name + access chip + rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lounge.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: inkColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        // Access-type chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            _accessTypeLabel(lounge.accessType),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: chipFg,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),

                        // Rating stars (small)
                        RatingStars(rating: lounge.rating, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          lounge.rating.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Price badge
              const SizedBox(width: AppSpacing.sm),
              if (lounge.price != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.smMd,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successAlpha15,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    '${lounge.currency} ${lounge.price!.toStringAsFixed(0)}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark ? AppColors.dSky : AppColors.success,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.smMd,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.skyAlpha10,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    'Included',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark ? AppColors.dSky : AppColors.sky,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.smMd),

          // ── Amenity icon row ──────────────────────────────────────────
          Wrap(
            spacing: AppSpacing.smMd,
            runSpacing: AppSpacing.xs,
            children: lounge.amenities.map((amenity) {
              return Tooltip(
                message: amenity.replaceAll('_', ' '),
                child: Icon(
                  _amenityIcon(amenity),
                  size: 16,
                  color: mutedColor,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Location & hours ──────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 13, color: mutedColor),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  lounge.location,
                  style: theme.textTheme.labelSmall?.copyWith(color: mutedColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.access_time_rounded, size: 13, color: mutedColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                lounge.openingHours,
                style: theme.textTheme.labelSmall?.copyWith(color: mutedColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
