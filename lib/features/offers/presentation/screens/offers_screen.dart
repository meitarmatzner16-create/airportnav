import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/features/offers/presentation/providers/offer_providers.dart';
import 'package:airport_nav/features/offers/presentation/widgets/offer_card.dart';
import 'package:airport_nav/features/flight/presentation/providers/flight_providers.dart';

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  static const _categories = [
    {'key': 'all', 'label': 'All'},
    {'key': 'dining', 'label': 'Dining'},
    {'key': 'shopping', 'label': 'Shopping'},
    {'key': 'lounge', 'label': 'Lounge'},
    {'key': 'duty_free', 'label': 'Duty Free'},
    {'key': 'travel', 'label': 'Travel'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(offerCategoryFilterProvider);
    final filteredOffers = ref.watch(filteredOffersProvider);
    final airlineOffers = ref.watch(airlineOffersProvider);
    final selectedFlight = ref.watch(selectedFlightProvider);
    final detectedAirport = ref.watch(detectedAirportProvider);
    final theme = Theme.of(context);

    final airportCode = selectedFlight?.departureAirport ?? detectedAirport;
    final airline = selectedFlight?.airline;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.local_offer_rounded,
                color: AppColors.accent, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Offers',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Flight context strip
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.xs,
              AppSpacing.gutter,
              0,
            ),
            child: selectedFlight != null
                ? _FlightContextCard(
                    airline: selectedFlight.airline,
                    flightNumber: selectedFlight.flightNumber,
                    airportCode: airportCode,
                  )
                : _NoFlightHint(),
          ),

          const SizedBox(height: AppSpacing.md),

          // Category filter chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = selectedCategory == cat['key'];
                return _FilterPill(
                  label: cat['label']!,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(offerCategoryFilterProvider.notifier).state =
                        cat['key']!;
                  },
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                0,
                AppSpacing.gutter,
                AppSpacing.xxl,
              ),
              children: [
                if (airlineOffers.isNotEmpty &&
                    selectedCategory == 'all' &&
                    airline != null) ...[
                  _SectionHeader(
                    title: 'Exclusive for $airline',
                    subtitle:
                        'Curated for ${selectedFlight!.flightNumber} passengers',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 230,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: airlineOffers.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.smMd),
                      itemBuilder: (context, index) {
                        final offer = airlineOffers[index];
                        return SizedBox(
                          width: 280,
                          child: OfferCard(offer: offer),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionHeader(title: 'All deals at $airportCode'),
                  const SizedBox(height: AppSpacing.md),
                ],

                if (airlineOffers.isEmpty && selectedCategory == 'all') ...[
                  _SectionHeader(title: 'Deals at $airportCode'),
                  const SizedBox(height: AppSpacing.md),
                ],

                if (filteredOffers.isEmpty)
                  _OffersEmptyState()
                else
                  ...filteredOffers
                      .where((o) =>
                          selectedCategory != 'all' ||
                          !airlineOffers.any((ao) => ao.id == o.id))
                      .map(
                        (offer) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: OfferCard(offer: offer),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _FlightContextCard extends StatelessWidget {
  final String airline;
  final String flightNumber;
  final String airportCode;

  const _FlightContextCard({
    required this.airline,
    required this.flightNumber,
    required this.airportCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.smMd),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.whiteAlpha20,
            ),
            child: const Icon(Icons.flight_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Showing deals for $airline',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.whiteAlpha80,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  '$flightNumber · $airportCode',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoFlightHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.smMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: AppSpacing.iconSm, color: AppColors.accent),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Pick a flight on Home for personalized deals',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.hairline,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: isSelected ? Colors.white : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _OffersEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
            ),
            child: const Icon(Icons.local_offer_outlined,
                size: 28, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.smMd),
          Text(
            'No offers yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Check back closer to your flight',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
