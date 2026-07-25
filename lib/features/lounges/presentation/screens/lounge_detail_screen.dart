import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/constants/app_typography.dart';
import 'package:airport_nav/core/widgets/app_buttons.dart';
import 'package:airport_nav/core/widgets/app_card.dart';
import 'package:airport_nav/core/widgets/gold_divider.dart';
import 'package:airport_nav/core/widgets/gradient_hero.dart';
import 'package:airport_nav/core/widgets/info_row.dart';
import 'package:airport_nav/core/widgets/rating_stars.dart';
import 'package:airport_nav/core/widgets/state_views.dart';
import 'package:airport_nav/features/lounges/presentation/providers/lounge_providers.dart';

/// Sky Pass-styled lounge detail screen.
///
/// Header: [GradientHero] (access-type tinted via token map) + lounge icon watermark.
/// Body: name (headlineLarge ink) · access-type chip + [RatingStars] + mono rating ·
///       price/complimentary [AppCard] · Amenities Wrap of skyTint circles ·
///       [GoldDivider] · Entry Conditions (titleLarge + bodyMedium) ·
///       [InfoRow]s · [PrimaryButton].
/// All colours from tokens. Light/dark via brightness checks.
class LoungeDetailScreen extends ConsumerWidget {
  final String loungeId;

  const LoungeDetailScreen({
    super.key,
    required this.loungeId,
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

  /// Maps access type → gradient color pair using Sky Pass tokens.
  static List<Color> _heroGradient(String accessType) {
    return switch (accessType) {
      'priority_pass' => [AppColors.gradientLoungeStart, AppColors.gradientLoungeEnd],
      'airline_lounge' => [AppColors.ink, AppColors.sky],
      'pay_per_use' => [AppColors.gradientShoppingStart, AppColors.gradientShoppingEnd],
      'membership' => [AppColors.gradientTravelStart, AppColors.gradientTravelEnd],
      _ => [AppColors.sky, AppColors.sky2],
    };
  }

  /// Returns [chipBg, chipFg] using Sky Pass tokens.
  static (Color, Color) _chipColors(String accessType, bool isDark) {
    return switch (accessType) {
      'priority_pass' => (AppColors.successAlpha15, isDark ? AppColors.dSky : AppColors.gradientLoungeStart),
      'airline_lounge' => (AppColors.inkAlpha10, isDark ? AppColors.dText : AppColors.ink),
      'pay_per_use' => (AppColors.skyAlpha10, isDark ? AppColors.dSky : AppColors.sky),
      'membership' => (AppColors.inkAlpha10, isDark ? AppColors.dText : AppColors.ink),
      _ => (AppColors.skyAlpha15, isDark ? AppColors.dSky : AppColors.sky2),
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

  static String _amenityLabel(String amenity) {
    return switch (amenity) {
      'wifi' => 'Wi-Fi',
      'shower' => 'Showers',
      'food' => 'Food',
      'bar' => 'Bar',
      'spa' => 'Spa',
      'sleep_pods' => 'Sleep Pods',
      'business_center' => 'Business',
      _ => amenity.replaceAll('_', ' '),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lounge = ref.watch(loungeByIdProvider(loungeId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (lounge == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
        appBar: AppBar(title: const Text('Lounge Not Found')),
        body: const ErrorState(message: 'The requested lounge could not be found.'),
      );
    }

    final inkColor = isDark ? AppColors.dText : AppColors.ink;
    final mutedColor = isDark ? AppColors.dMuted : AppColors.muted;
    final skyTintColor = isDark ? AppColors.dSurfaceVariant : AppColors.skyTint;
    final skyIconColor = isDark ? AppColors.dSky : AppColors.sky;
    final (chipBg, chipFg) = _chipColors(lounge.accessType, isDark);
    final heroColors = _heroGradient(lounge.accessType);

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
                    Icons.airline_seat_recline_extra_rounded,
                    size: 88,
                    color: Colors.white.withAlpha(51), // watermark
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

                  // Lounge name
                  Text(
                    lounge.name,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: inkColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.smMd),

                  // Access-type chip + RatingStars + mono rating
                  Row(
                    children: [
                      // Access-type chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.smMd,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: chipBg,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          _accessTypeLabel(lounge.accessType),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: chipFg,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.smMd),

                      // Star rating
                      RatingStars(rating: lounge.rating, size: 16),
                      const SizedBox(width: AppSpacing.xs),

                      // Mono rating value
                      Text(
                        lounge.rating.toStringAsFixed(1),
                        style: AppTypography.mono(
                          fontSize: 13,
                          weight: FontWeight.w700,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Price / complimentary banner ──────────────────────
                  if (lounge.price != null)
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.smMd,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.smMd),
                          Icon(
                            Icons.payments_outlined,
                            size: 18,
                            color: isDark ? AppColors.dSky : AppColors.success,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              '${lounge.currency} ${lounge.price!.toStringAsFixed(0)} per visit',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: inkColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.smMd,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.sky,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.smMd),
                          Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                            color: skyIconColor,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Complimentary with eligible access',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: inkColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Amenities ─────────────────────────────────────────
                  Text(
                    'Amenities',
                    style: theme.textTheme.titleLarge?.copyWith(color: inkColor),
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  Wrap(
                    spacing: AppSpacing.smMd,
                    runSpacing: AppSpacing.smMd,
                    children: lounge.amenities.map((amenity) {
                      return Container(
                        width: 88,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.smMd,
                          horizontal: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.dSurface : AppColors.card,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(
                            color: isDark ? AppColors.dHairline : AppColors.hairline,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: skyTintColor,
                              ),
                              child: Icon(
                                _amenityIcon(amenity),
                                size: 18,
                                color: skyIconColor,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              _amenityLabel(amenity),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: mutedColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Gold divider ───────────────────────────────────────
                  const GoldDivider(),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Entry conditions ───────────────────────────────────
                  Text(
                    'Entry Conditions',
                    style: theme.textTheme.titleLarge?.copyWith(color: inkColor),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    lounge.entryConditions,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: mutedColor,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Info rows ─────────────────────────────────────────
                  InfoRow(
                    icon: Icons.access_time_rounded,
                    label: 'Opening Hours',
                    value: lounge.openingHours,
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: lounge.location,
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  InfoRow(
                    icon: Icons.flight_rounded,
                    label: 'Terminal',
                    value: '${lounge.terminal} · ${lounge.airportCode}',
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
