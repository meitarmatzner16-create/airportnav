import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/widgets/app_card.dart';
import 'package:airport_nav/core/widgets/category_filter_chips.dart';
import 'package:airport_nav/core/widgets/screen_header.dart';
import 'package:airport_nav/core/widgets/section_header.dart';
import 'package:airport_nav/core/widgets/state_views.dart';
import 'package:airport_nav/features/offers/presentation/providers/offer_providers.dart';
import 'package:airport_nav/features/offers/presentation/widgets/offer_card.dart';
import 'package:airport_nav/features/flight/presentation/providers/flight_providers.dart';

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  static const _categoryKeys = ['all', 'dining', 'shopping', 'lounge', 'duty_free', 'travel'];
  static const _categoryLabels = ['All', 'Dining', 'Shopping', 'Lounge', 'Duty Free', 'Travel'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(offerCategoryFilterProvider);
    final filteredOffers = ref.watch(filteredOffersProvider);
    final airlineOffers = ref.watch(airlineOffersProvider);
    final selectedFlight = ref.watch(selectedFlightProvider);
    final detectedAirport = ref.watch(detectedAirportProvider);

    final airportCode = selectedFlight?.departureAirport ?? detectedAirport;
    final airline = selectedFlight?.airline;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.dBg
          : AppColors.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Screen header ────────────────────────────────────────
            ScreenHeader(
              title: 'Offers',
              subtitle: selectedFlight != null
                  ? 'Personalised for ${selectedFlight.flightNumber} · $airportCode'
                  : 'Deals at $airportCode',
            ),

            // ── Flight context strip ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                0,
                AppSpacing.gutter,
                AppSpacing.md,
              ),
              child: selectedFlight != null
                  ? _FlightContextCard(
                      airline: selectedFlight.airline,
                      flightNumber: selectedFlight.flightNumber,
                      airportCode: airportCode,
                    )
                  : _NoFlightHint(),
            ),

            // ── Category filter chips ────────────────────────────────
            CategoryFilterChips(
              categories: _categoryLabels,
              selected: _categoryLabels[_categoryKeys.indexOf(
                _categoryKeys.contains(selectedCategory) ? selectedCategory : 'all',
              )],
              onSelected: (label) {
                final idx = _categoryLabels.indexOf(label);
                if (idx >= 0) {
                  ref.read(offerCategoryFilterProvider.notifier).state =
                      _categoryKeys[idx];
                }
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Content ──────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  0,
                  AppSpacing.gutter,
                  AppSpacing.xxl,
                ),
                children: [
                  // Airline exclusive section
                  if (airlineOffers.isNotEmpty &&
                      selectedCategory == 'all' &&
                      airline != null) ...[
                    SectionHeader(
                      title: 'Exclusive for $airline',
                      actionText: null,
                    ),
                    const SizedBox(height: AppSpacing.smMd),
                    SizedBox(
                      height: 230,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: airlineOffers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: AppSpacing.smMd),
                        itemBuilder: (context, index) {
                          final offer = airlineOffers[index];
                          return SizedBox(
                            width: 280,
                            child: AppCard(
                              padding: EdgeInsets.zero,
                              child: OfferCard(offer: offer),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    SectionHeader(title: 'All deals at $airportCode'),
                    const SizedBox(height: AppSpacing.smMd),
                  ],

                  if (airlineOffers.isEmpty && selectedCategory == 'all') ...[
                    SectionHeader(title: 'Deals at $airportCode'),
                    const SizedBox(height: AppSpacing.smMd),
                  ],

                  if (filteredOffers.isEmpty)
                    const EmptyState(
                      icon: Icons.local_offer_outlined,
                      title: 'No offers yet',
                      message: 'Check back closer to your flight',
                    )
                  else
                    ...filteredOffers
                        .where((o) =>
                            selectedCategory != 'all' ||
                            !airlineOffers.any((ao) => ao.id == o.id))
                        .map(
                          (offer) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: AppCard(
                              padding: EdgeInsets.zero,
                              child: OfferCard(offer: offer),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
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
          colors: [AppColors.sky, AppColors.sky2],
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
    final isDark = theme.brightness == Brightness.dark;
    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.smMd),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: AppSpacing.iconSm,
              color: isDark ? AppColors.dSky : AppColors.sky),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Pick a flight on Home for personalized deals',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
