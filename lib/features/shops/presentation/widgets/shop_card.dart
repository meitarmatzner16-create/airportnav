import 'package:flutter/material.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/widgets/app_card.dart';
import 'package:airport_nav/core/widgets/rating_stars.dart';
import 'package:airport_nav/features/shops/domain/entities/shop.dart';

/// Sky Pass–styled shop row card.
///
/// Uses [AppCard] (white, hairline, radiusLg, soft shadow).
/// Category chip uses token colors. [RatingStars] uses gold.
/// Keeps the same public API: `shop` + `onTap`.
class ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;

  const ShopCard({
    super.key,
    required this.shop,
    required this.onTap,
  });

  // ── Category helpers ──────────────────────────────────────────────────────

  static String _categoryLabel(String category) {
    return switch (category) {
      'dining' => 'Dining',
      'retail' => 'Retail',
      'duty_free' => 'Duty Free',
      'convenience' => 'Convenience',
      'luxury' => 'Luxury',
      'electronics' => 'Electronics',
      _ => category,
    };
  }

  static IconData _categoryIcon(String category) {
    return switch (category) {
      'dining' => Icons.restaurant_rounded,
      'retail' => Icons.shopping_bag_rounded,
      'duty_free' => Icons.local_offer_rounded,
      'convenience' => Icons.store_rounded,
      'luxury' => Icons.diamond_rounded,
      'electronics' => Icons.devices_rounded,
      _ => Icons.storefront_rounded,
    };
  }

  /// Returns the chip tint pair [bg, fg] using Sky Pass tokens.
  static (Color, Color) _categoryChipColors(String category, bool isDark) {
    return switch (category) {
      'dining' => (AppColors.skyAlpha10, isDark ? AppColors.dSky : AppColors.sky),
      'retail' => (AppColors.inkAlpha10, isDark ? AppColors.dText : AppColors.ink),
      'duty_free' => (AppColors.skyAlpha15, isDark ? AppColors.dSky : AppColors.sky2),
      'convenience' => (AppColors.skyAlpha10, isDark ? AppColors.dSky : AppColors.sky),
      'luxury' => (AppColors.goldAlpha15, isDark ? AppColors.dGold : AppColors.goldText),
      'electronics' => (AppColors.skyAlpha15, isDark ? AppColors.dSky : AppColors.sky),
      _ => (AppColors.inkAlpha10, isDark ? AppColors.dMuted : AppColors.muted),
    };
  }

  /// Returns gradient colors for the thumbnail strip.
  static List<Color> _categoryGradient(String category) {
    return switch (category) {
      'dining' => [AppColors.gradientDiningStart, AppColors.gradientDiningEnd],
      'luxury' => [AppColors.ink, AppColors.gradientShoppingStart],
      'duty_free' => [AppColors.gradientDutyFreeStart, AppColors.gradientDutyFreeEnd],
      'retail' => [AppColors.gradientShoppingStart, AppColors.gradientShoppingEnd],
      _ => [AppColors.sky, AppColors.sky2],
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final (chipBg, chipFg) = _categoryChipColors(shop.category, isDark);
    final gradientColors = _categoryGradient(shop.category);
    final mutedColor = isDark ? AppColors.dMuted : AppColors.muted;
    final inkColor = isDark ? AppColors.dText : AppColors.ink;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: onTap,
        child: Row(
          children: [
            // ── Gradient thumbnail strip ─────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusLg),
                bottomLeft: Radius.circular(AppSpacing.radiusLg),
              ),
              child: Container(
                width: 88,
                height: 108,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
                child: Icon(
                  _categoryIcon(shop.category),
                  size: 36,
                  color: Colors.white.withAlpha(204), // .8 opacity
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.smMd,
                  AppSpacing.smMd,
                  AppSpacing.sm,
                  AppSpacing.smMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      shop.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: inkColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Category chip + rating
                    Row(
                      children: [
                        // Category chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _categoryIcon(shop.category),
                                size: AppSpacing.iconXs,
                                color: chipFg,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _categoryLabel(shop.category),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: chipFg,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),

                        // Stars
                        RatingStars(rating: shop.rating, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          shop.rating.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs + 2),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: AppSpacing.iconXs,
                          color: mutedColor,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            shop.location,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: mutedColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Hours
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: AppSpacing.iconXs,
                          color: mutedColor,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          shop.openingHours,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Chevron ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
