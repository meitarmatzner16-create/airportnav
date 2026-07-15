import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/constants/app_typography.dart';
import 'package:airport_nav/core/widgets/app_buttons.dart';
import 'package:airport_nav/core/widgets/gold_divider.dart';
import 'package:airport_nav/core/widgets/gradient_hero.dart';
import 'package:airport_nav/core/widgets/info_row.dart';
import 'package:airport_nav/core/widgets/rating_stars.dart';
import 'package:airport_nav/core/widgets/state_views.dart';
import 'package:airport_nav/features/shops/presentation/providers/shop_providers.dart';

/// Sky Pass–styled shop detail screen.
///
/// Header: [GradientHero] (category-tinted via token map) + large icon watermark.
/// Body: name (headlineLarge ink) · category chip + [RatingStars] + mono rating ·
///       [InfoRow]s · [GoldDivider] · About · [PrimaryButton].
/// All colours from tokens. Light/dark via brightness checks.
class ShopDetailScreen extends ConsumerWidget {
  final String shopId;

  const ShopDetailScreen({
    super.key,
    required this.shopId,
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

  /// Maps category → gradient color pair using Sky Pass tokens.
  static List<Color> _heroGradient(String category) {
    return switch (category) {
      'dining' => [AppColors.gradientDiningStart, AppColors.gradientDiningEnd],
      'luxury' => [AppColors.ink, AppColors.gradientShoppingStart],
      'duty_free' => [AppColors.gradientDutyFreeStart, AppColors.gradientDutyFreeEnd],
      'retail' => [AppColors.gradientShoppingStart, AppColors.gradientShoppingEnd],
      'electronics' => [AppColors.sky, AppColors.ink],
      'convenience' => [AppColors.gradientTravelStart, AppColors.gradientTravelEnd],
      _ => [AppColors.sky, AppColors.sky2],
    };
  }

  /// Returns [chipBg, chipFg] using Sky Pass tokens.
  static (Color, Color) _chipColors(String category, bool isDark) {
    return switch (category) {
      'luxury' => (AppColors.inkAlpha10, isDark ? AppColors.dText : AppColors.ink),
      'dining' => (AppColors.skyAlpha10, isDark ? AppColors.dSky : AppColors.sky),
      'retail' => (AppColors.inkAlpha10, isDark ? AppColors.dText : AppColors.ink),
      _ => (AppColors.skyAlpha15, isDark ? AppColors.dSky : AppColors.sky2),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(shopByIdProvider(shopId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (shop == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
        appBar: AppBar(title: const Text('Shop Not Found')),
        body: const ErrorState(message: 'The requested shop could not be found.'),
      );
    }

    final inkColor = isDark ? AppColors.dText : AppColors.ink;
    final mutedColor = isDark ? AppColors.dMuted : AppColors.muted;
    final (chipBg, chipFg) = _chipColors(shop.category, isDark);
    final heroColors = _heroGradient(shop.category);

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: CustomScrollView(
        slivers: [
          // ── Gradient hero header ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: GradientHero(
                height: 220,
                colors: heroColors,
                child: Center(
                  child: Icon(
                    _categoryIcon(shop.category),
                    size: 80,
                    color: Colors.white.withAlpha(51), // large watermark
                  ),
                ),
              ),
            ),
          ),

          // ── Body content ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // Shop name
                  Text(
                    shop.name,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: inkColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.smMd),

                  // Category chip + RatingStars + mono rating
                  Row(
                    children: [
                      // Category chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.smMd,
                          vertical: AppSpacing.xs,
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
                              size: AppSpacing.iconSm,
                              color: chipFg,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              _categoryLabel(shop.category),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: chipFg,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.smMd),

                      // Star rating
                      RatingStars(rating: shop.rating, size: 16),
                      const SizedBox(width: AppSpacing.xs),

                      // Mono rating value
                      Text(
                        shop.rating.toStringAsFixed(1),
                        style: AppTypography.mono(
                          fontSize: 13,
                          weight: FontWeight.w700,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Info rows ─────────────────────────────────────────
                  InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: shop.location,
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  InfoRow(
                    icon: Icons.flight_rounded,
                    label: 'Terminal',
                    value: '${shop.terminal} · ${shop.airportCode}',
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Hours',
                    value: shop.openingHours,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Gold divider ───────────────────────────────────────
                  const GoldDivider(),
                  const SizedBox(height: AppSpacing.lg),

                  // ── About section ──────────────────────────────────────
                  Text(
                    'About',
                    style: theme.textTheme.titleLarge?.copyWith(color: inkColor),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    shop.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: mutedColor,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // ── Show on map button ─────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Show on map',
                      icon: Icons.map_rounded,
                      onPressed: () => context.push('/map'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
