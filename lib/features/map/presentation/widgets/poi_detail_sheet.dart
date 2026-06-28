import 'package:flutter/material.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
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

  Color _categoryColor() {
    switch (poi.category) {
      case 'gate':
        return AppColors.primary;
      case 'shop':
        return const Color(0xFF7C3AED);
      case 'lounge':
        return const Color(0xFF0891B2);
      case 'restaurant':
        return const Color(0xFFFF6B35);
      case 'restroom':
        return AppColors.onSurfaceVariant;
      case 'info':
        return AppColors.success;
      case 'security':
        return AppColors.error;
      case 'immigration':
        return AppColors.warning;
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  String _categoryLabel() {
    switch (poi.category) {
      case 'gate':
        return 'Gate';
      case 'shop':
        return 'Shop';
      case 'lounge':
        return 'Lounge';
      case 'restaurant':
        return 'Restaurant';
      case 'restroom':
        return 'Restroom';
      case 'info':
        return 'Information';
      case 'security':
        return 'Security';
      case 'immigration':
        return 'Immigration';
      default:
        return poi.category;
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
    final theme = Theme.of(context);
    final color = _categoryColor();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              // Category icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color((color.value & 0x00FFFFFF) | 0x26000000),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  _categoryIcon(),
                  color: color,
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
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Color((color.value & 0x00FFFFFF) | 0x1A000000),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Text(
                        _categoryLabel(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
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
                  icon: const Icon(Icons.close),
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
                backgroundColor: AppColors.accent,
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
