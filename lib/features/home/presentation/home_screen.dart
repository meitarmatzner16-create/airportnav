import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../features/flight/domain/entities/flight.dart';
import '../../../features/flight/presentation/providers/flight_providers.dart';
import 'widgets/assistant_entry_card.dart';
import 'widgets/home_header.dart';
import 'widgets/home_hero_banner.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/live_departures_section.dart';
import 'widgets/quick_start_section.dart';
import 'widgets/upcoming_flight_card.dart';

const _gutter = AppSpacing.gutter;
const _sectionGap = AppSpacing.sectionGap;

/// AirportNav home — a live departures board that turns a chosen flight into
/// personalized navigation, quick actions, and an assistant entry.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _airports = ['JFK', 'LAX', 'LHR', 'CDG', 'DXB', 'SIN', 'NRT', 'SFO'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detectedAirport = ref.watch(detectedAirportProvider);
    final upcoming = ref.watch(upcomingFlightsProvider);
    final selected = ref.watch(selectedFlightProvider);
    final displayFlight = _displayFlight(selected, upcoming);

    void snack(String message) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: AppSpacing.smMd),
            // ── Header ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: HomeHeader(
                airport: detectedAirport,
                airports: _airports,
                onAirportChanged: (v) =>
                    ref.read(detectedAirportProvider.notifier).state = v,
                onNotifications: () => snack("You're all caught up."),
                onProfile: () => context.go('/more'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // ── Search ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: HomeSearchBar(
                hint: 'Search flight, destination or airline',
                onTap: () => context.push('/home/flight-search'),
                onScan: () => snack('Boarding-pass scan is coming soon.'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // ── Hero banner ───────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: _gutter),
              child: HomeHeroBanner(),
            ),
            const SizedBox(height: _sectionGap),
            // ── Quick Start ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: QuickStartSection(
                items: [
                  QuickStartItem(
                    icon: Icons.flight_rounded,
                    title: 'Find My Flight',
                    subtitle: 'See live departures',
                    onTap: () => context.go('/flights'),
                  ),
                  QuickStartItem(
                    icon: Icons.near_me_rounded,
                    title: 'Navigate',
                    subtitle: 'Get to your gate',
                    onTap: () => context.go('/map'),
                  ),
                  QuickStartItem(
                    icon: Icons.restaurant_rounded,
                    title: 'Food & Drinks',
                    subtitle: 'Near your gate',
                    onTap: () => context.go('/venues'),
                  ),
                  QuickStartItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Shops',
                    subtitle: 'On your route',
                    onTap: () => context.go('/venues'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _sectionGap),
            // ── Live Departures ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: LiveDeparturesSection(
                flights: upcoming,
                selectedFlightId: displayFlight?.id,
                onSelect: (f) =>
                    ref.read(selectedFlightProvider.notifier).state = f,
                onSeeAll: () => context.go('/flights'),
              ),
            ),
            const SizedBox(height: _sectionGap),
            // ── Your Upcoming Flight ──────────────────────────────────
            if (displayFlight != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _gutter),
                child: UpcomingFlightCard(
                  flight: displayFlight,
                  onTap: () => context.push('/boarding-pass'),
                ),
              ),
              const SizedBox(height: _sectionGap),
            ],
            // ── Assistant ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: AssistantEntryCard(
                onTap: () => context.go('/voice-chat'),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  /// Explicit selection wins; otherwise default to the wireframe's featured
  /// flight (AA 2468) if present, else the soonest departure.
  Flight? _displayFlight(Flight? selected, List<Flight> upcoming) {
    if (selected != null) return selected;
    if (upcoming.isEmpty) return null;
    return upcoming.firstWhere(
      (f) => f.flightNumber == 'AA 2468',
      orElse: () => upcoming.first,
    );
  }
}
