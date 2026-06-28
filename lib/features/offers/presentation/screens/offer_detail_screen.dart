import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/features/offers/presentation/providers/offer_providers.dart';

class OfferDetailScreen extends ConsumerWidget {
  final String offerId;

  const OfferDetailScreen({super.key, required this.offerId});

  Color _gradientStartColor(String category) {
    switch (category) {
      case 'dining':
        return const Color(0xFFFF6B35);
      case 'shopping':
        return const Color(0xFF7C3AED);
      case 'lounge':
        return const Color(0xFF0891B2);
      case 'travel':
        return const Color(0xFF059669);
      case 'duty_free':
        return const Color(0xFFDB2777);
      default:
        return AppColors.primary;
    }
  }

  Color _gradientEndColor(String category) {
    switch (category) {
      case 'dining':
        return const Color(0xFFEAB308);
      case 'shopping':
        return const Color(0xFFEC4899);
      case 'lounge':
        return const Color(0xFF6366F1);
      case 'travel':
        return const Color(0xFF2DD4BF);
      case 'duty_free':
        return const Color(0xFFF472B6);
      default:
        return AppColors.primaryLight;
    }
  }

  String _categoryLabel(String category) {
    switch (category) {
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
        return category;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = ref.watch(offerByIdProvider(offerId));
    final theme = Theme.of(context);

    if (offer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Offer')),
        body: const Center(child: Text('Offer not found')),
      );
    }

    final now = DateTime.now();
    final daysLeft = offer.validUntil.difference(now).inDays;
    final hoursLeft = offer.validUntil.difference(now).inHours;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Gradient header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _gradientStartColor(offer.category),
                      _gradientEndColor(offer.category),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        offer.discount,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 36,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _categoryLabel(offer.category),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: Text(
                offer.merchant,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.md),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Title
                Text(
                  offer.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // Merchant
                Text(
                  offer.merchant,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Description
                Text(
                  offer.description,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Promo code
                if (offer.promoCode != null) ...[
                  Text(
                    'Promo Code',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          offer.promoCode!,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Code ${offer.promoCode} copied!'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusSm),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Validity
                Text(
                  'Validity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            '${_formatDate(offer.validFrom)} - ${_formatDate(offer.validUntil)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      if (offer.isValid && daysLeft <= 7) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer,
                                  size: 16, color: AppColors.warning),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                daysLeft <= 0
                                    ? 'Expires in $hoursLeft hours!'
                                    : 'Expires in $daysLeft days!',
                                style:
                                    theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (!offer.isValid) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 16, color: AppColors.error),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'This offer has expired',
                                style:
                                    theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Airport chip
                Row(
                  children: [
                    Text(
                      'Airport',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Chip(
                      label: Text(
                        offer.airportCode,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Terms & Conditions expandable
                _TermsExpansionTile(
                  termsAndConditions: offer.termsAndConditions,
                ),
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _TermsExpansionTile extends StatefulWidget {
  final String termsAndConditions;

  const _TermsExpansionTile({required this.termsAndConditions});

  @override
  State<_TermsExpansionTile> createState() => _TermsExpansionTileState();
}

class _TermsExpansionTileState extends State<_TermsExpansionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Text(
                  'Terms & Conditions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Text(
              widget.termsAndConditions,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
