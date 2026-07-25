import 'package:flutter/material.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/offers/domain/entities/offer.dart';

/// Premium minimal offer card. White card with a soft hairline border and
/// a single accent-tinted icon disc - no per-category gradients, no
/// decorative chrome. The discount itself is the visual anchor.
class OfferCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback? onTap;

  const OfferCard({
    super.key,
    required this.offer,
    this.onTap,
  });

  IconData _categoryIcon() {
    switch (offer.category) {
      case 'dining':
        return Icons.restaurant_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'lounge':
        return Icons.airline_seat_individual_suite_rounded;
      case 'travel':
        return Icons.directions_car_rounded;
      case 'duty_free':
        return Icons.storefront_rounded;
      default:
        return Icons.local_offer_rounded;
    }
  }

  String _categoryLabel() {
    switch (offer.category) {
      case 'dining':
        return 'Dining';
      case 'shopping':
        return 'Shopping';
      case 'lounge':
        return 'Lounge';
      case 'travel':
        return 'Travel';
      case 'duty_free':
        return 'Duty Free';
      default:
        return 'Offer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysLeft = offer.validUntil.difference(DateTime.now()).inDays;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.hairline, width: 1),
            boxShadow: AppShadows.card,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.mdLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row - accent icon disc + tiny category label
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.accentAlpha10,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(
                        _categoryIcon(),
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.smMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _categoryLabel().toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            offer.merchant,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Discount as the visual anchor
                Text(
                  offer.discount,
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Title
                Text(
                  offer.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    if (offer.isValid && daysLeft <= 7)
                      _StatusPill(
                        label: daysLeft <= 0 ? 'Last day' : '$daysLeft days left',
                        color: AppColors.warning,
                      )
                    else if (!offer.isValid)
                      _StatusPill(
                        label: 'Expired',
                        color: AppColors.error,
                      )
                    else
                      _StatusPill(
                        label: 'Active',
                        color: AppColors.success,
                      ),
                    const Spacer(),
                    Text(
                      offer.airportCode,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
        ),
      ],
    );
  }
}
