import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/widgets/gradient_hero.dart';
import 'package:airport_nav/core/widgets/state_views.dart';
import 'package:airport_nav/features/offers/presentation/providers/offer_providers.dart';

class OfferDetailScreen extends ConsumerWidget {
  final String offerId;

  const OfferDetailScreen({super.key, required this.offerId});

  /// Maps category → [start, end] gradient colors using Sky Pass tokens.
  static List<Color> _heroGradient(String category) {
    return switch (category) {
      'dining' => [AppColors.gradientDiningStart, AppColors.gradientDiningEnd],
      'shopping' => [AppColors.gradientShoppingStart, AppColors.gradientShoppingEnd],
      'lounge' => [AppColors.gradientLoungeStart, AppColors.gradientLoungeEnd],
      'travel' => [AppColors.gradientTravelStart, AppColors.gradientTravelEnd],
      'duty_free' => [AppColors.gradientDutyFreeStart, AppColors.gradientDutyFreeEnd],
      _ => [AppColors.sky, AppColors.sky2],
    };
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
    final isDark = theme.brightness == Brightness.dark;

    if (offer == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
        appBar: AppBar(title: const Text('Offer')),
        body: const ErrorState(message: 'The requested offer could not be found.'),
      );
    }

    final now = DateTime.now();
    final daysLeft = offer.validUntil.difference(now).inDays;
    final hoursLeft = offer.validUntil.difference(now).inHours;
    final heroColors = _heroGradient(offer.category);

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: CustomScrollView(
        slivers: [
          // Gradient hero header via GradientHero token
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: GradientHero(
                height: 200,
                colors: heroColors,
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
                          color: AppColors.whiteAlpha80,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              title: Text(
                offer.merchant,
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
            ),
          ),
          // Content
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter, vertical: AppSpacing.md),
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
                      color: AppColors.skyAlpha10,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: AppColors.skyAlpha20,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          offer.promoCode!,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: isDark ? AppColors.dSky : AppColors.ink,
                            fontWeight: FontWeight.w600,
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
                            foregroundColor: isDark ? AppColors.dSky : AppColors.sky,
                            side: BorderSide(color: isDark ? AppColors.dSky : AppColors.sky),
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
                    color: isDark ? AppColors.dSurface : AppColors.skyTint,
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
                            color: AppColors.warningAlpha15,
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
                            color: AppColors.errorAlpha15,
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
                          color: isDark ? AppColors.dSky : AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      backgroundColor: AppColors.skyAlpha10,
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
    final isDark = theme.brightness == Brightness.dark;

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
                  color: isDark ? AppColors.dMuted : AppColors.muted,
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
              color: isDark ? AppColors.dSurface : AppColors.skyTint,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Text(
              widget.termsAndConditions,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.dMuted : AppColors.muted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
