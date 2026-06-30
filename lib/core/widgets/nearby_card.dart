import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../../features/venues/domain/entities/venue.dart';

// Neutral placeholder bg
const _surface2 = Color(0xFFEEF1F4);
// Muted tertiary (ink @ ~60%)
const _muted2 = Color(0xFF9AA1B0);

/// Horizontally-scrolled venue card used in the "Near your gate" section.
/// Fixed width: 192px. Radius: 18px (radiusXl).
class NearbyCard extends StatelessWidget {
  final Venue venue;
  final int walkMinutes;
  final VoidCallback? onTap;

  const NearbyCard({
    super.key,
    required this.venue,
    this.walkMinutes = 3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;
    final placeholderBg = isDark ? AppColors.dSurfaceVariant : _surface2;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 192,
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: hairline, width: 1),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Image placeholder ─────────────────────────────────
              SizedBox(
                height: 100,
                child: Stack(
                  children: [
                    // Background
                    Container(
                      height: 100,
                      color: placeholderBg,
                      child: Center(
                        child: Icon(
                          _categoryIcon(venue.category),
                          size: 42,
                          color: isDark ? AppColors.dMuted : AppColors.muted,
                        ),
                      ),
                    ),
                    // Walk pill – top-left
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          // semi-transparent dark bg for legibility
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.directions_walk_rounded,
                                size: 11, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              '$walkMinutes min',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      venue.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.dText : AppColors.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Area / location
                    Text(
                      venue.location,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Star + rating + duration stub
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 13,
                            color: isDark ? AppColors.dGold : AppColors.gold),
                        const SizedBox(width: 3),
                        Text(
                          venue.rating.toStringAsFixed(1),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.dText : AppColors.ink,
                          ),
                        ),
                        Text(
                          ' · ${_estimateDuration(venue.category)}m',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 11.5,
                            color: _muted2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _categoryIcon(String category) {
    return switch (category) {
      'food' || 'dining' => Icons.restaurant_rounded,
      'coffee' || 'cafe' => Icons.local_cafe_rounded,
      'lounge' => Icons.weekend_rounded,
      'luxury' || 'fashion' => Icons.shopping_bag_rounded,
      'spa' || 'wellness' => Icons.spa_rounded,
      'pharmacy' || 'health' => Icons.local_pharmacy_rounded,
      'duty_free' || 'duty-free' => Icons.redeem_rounded,
      _ => Icons.store_rounded,
    };
  }

  static int _estimateDuration(String category) {
    return switch (category) {
      'lounge' => 30,
      'spa' || 'wellness' => 20,
      'food' || 'dining' => 15,
      _ => 10,
    };
  }
}
