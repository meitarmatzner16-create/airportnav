import 'package:flutter/material.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/features/map/domain/entities/map_floor.dart';

class PoiMarker extends StatelessWidget {
  final PointOfInterest poi;
  final VoidCallback? onTap;
  final bool isSelected;

  const PoiMarker({
    super.key,
    required this.poi,
    this.onTap,
    this.isSelected = false,
  });

  /// Returns [fill, shadow] color pair using Sky Pass tokens.
  (Color, Color) _categoryColors() {
    return switch (poi.category) {
      'gate' => (AppColors.sky, AppColors.skyAlpha20),
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
    final (categoryFill, categoryShadow) = _categoryColors();
    final fillColor = isSelected ? AppColors.sky : categoryFill;
    final shadowColor = isSelected ? AppColors.skyAlpha20 : categoryShadow;
    final size = isSelected ? 36.0 : 28.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: fillColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : AppColors.whiteAlpha80,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _categoryIcon(),
              color: Colors.white,
              size: isSelected ? 18 : 14,
            ),
          ),
          if (isSelected) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                poi.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
