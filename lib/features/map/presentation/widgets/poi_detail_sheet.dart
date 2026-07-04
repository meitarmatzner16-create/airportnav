import 'package:flutter/material.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/map/domain/entities/map_floor.dart';

class PoiDetailSheet extends StatelessWidget {
  final PointOfInterest poi;
  final VoidCallback? onNavigate;
  final VoidCallback? onClose;

  const PoiDetailSheet({
    super.key,
    required this.poi,
    this.onNavigate,
    this.onClose,
  });

  /// Returns [accent, tintBg] color pair using Sky Pass tokens.
  (Color, Color) _categoryColors() {
    return switch (poi.category) {
      'gate' => (AppColors.sky, AppColors.skyAlpha10),
      'shop' => (AppColors.ink, AppColors.inkAlpha10),
      'lounge' => (AppColors.gradientLoungeStart, AppColors.successAlpha15),
      'restaurant' => (AppColors.gradientDiningStart, AppColors.warningAlpha15),
      'restroom' => (AppColors.muted, AppColors.inkAlpha10),
      'info' => (AppColors.success, AppColors.successAlpha15),
      'security' => (AppColors.error, AppColors.errorAlpha15),
      'immigration' => (AppColors.warning, AppColors.warningAlpha15),
      _ => (AppColors.muted, AppColors.inkAlpha10),
    };
  }

  String _categoryLabel() {
    return switch (poi.category) {
      'gate' => 'Gate',
      'shop' => 'Shop',
      'lounge' => 'Lounge',
      'restaurant' => 'Restaurant',
      'restroom' => 'Restroom',
      'info' => 'Information',
      'security' => 'Security',
      'immigration' => 'Immigration',
      _ => poi.category,
    };
  }

  IconData _categoryIcon() {
    return switch (poi.category) {
      'gate' => Icons.flight_takeoff,
      'shop' => Icons.store,
      'lounge' => Icons.airline_seat_individual_suite,
      'restaurant' => Icons.restaurant,
      'restroom' => Icons.wc,
      'info' => Icons.info_outline,
      'security' => Icons.security,
      'immigration' => Icons.badge,
      _ => Icons.place,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final (accentColor, tintBg) = _categoryColors();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.dSurface : AppColors.card,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dHairline : AppColors.hairline,
            width: 1,
          ),
        ),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.dHairline : AppColors.hairline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              // Category icon disc
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tintBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  _categoryIcon(),
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Name and category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      poi.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.dText : AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: tintBg,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        _categoryLabel(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Close button
              if (onClose != null)
                IconButton(
                  onPressed: onClose,
                  icon: Icon(
                    Icons.close,
                    color: isDark ? AppColors.dMuted : AppColors.muted,
                  ),
                  iconSize: 20,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Navigate button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onNavigate,
              icon: const Icon(Icons.navigation, size: 18),
              label: const Text('Navigate Here'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sky,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 4),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
