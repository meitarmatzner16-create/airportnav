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

  Color _categoryColor() {
    switch (poi.category) {
      case 'gate':
        return const Color(0xFF1565C0);
      case 'shop':
        return const Color(0xFF7C3AED);
      case 'lounge':
        return const Color(0xFF0891B2);
      case 'restaurant':
        return const Color(0xFFFF6B35);
      case 'restroom':
        return const Color(0xFF6B7280);
      case 'info':
        return const Color(0xFF059669);
      case 'security':
        return const Color(0xFFDC2626);
      case 'immigration':
        return const Color(0xFFEAB308);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _categoryIcon() {
    switch (poi.category) {
      case 'gate':
        return Icons.flight_takeoff;
      case 'shop':
        return Icons.store;
      case 'lounge':
        return Icons.airline_seat_individual_suite;
      case 'restaurant':
        return Icons.restaurant;
      case 'restroom':
        return Icons.wc;
      case 'info':
        return Icons.info_outline;
      case 'security':
        return Icons.security;
      case 'immigration':
        return Icons.badge;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor();
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
              color: isSelected ? AppColors.accent : Color((color.value & 0x00FFFFFF) | 0xD9000000),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white70,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? const Color(0x661FC5A5) : Color((color.value & 0x00FFFFFF) | 0x66000000),
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
                color: Colors.black87,
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
