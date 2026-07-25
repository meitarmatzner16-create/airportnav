import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/search_bar_widget.dart';
import '../../../../core/widgets/state_views.dart';
import '../providers/flight_providers.dart';
import '../widgets/flight_card.dart';

/// Sky Pass-styled flight search screen.
///
/// Token SearchBarWidget + FlightCard list (AppCard aesthetic + StatusBadge).
/// EmptyState for no results. All hardcoded colors/padding replaced with tokens.
class FlightSearchScreen extends ConsumerStatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  ConsumerState<FlightSearchScreen> createState() =>
      _FlightSearchScreenState();
}

class _FlightSearchScreenState extends ConsumerState<FlightSearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(flightSearchProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final flights = ref.watch(filteredFlightsProvider);
    final query = ref.watch(flightSearchProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      appBar: AppBar(
        title: Text(
          'Search Flights',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: isDark ? AppColors.dText : AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ────────────────────────────────────────────────
          SearchBarWidget(
            hint: 'Search by flight number or city…',
            controller: _searchController,
            onChanged: (value) {
              ref.read(flightSearchProvider.notifier).state = value;
            },
          ),

          // ── Results count ─────────────────────────────────────────────
          if (query.isNotEmpty && flights.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(
                '${flights.length} flight${flights.length == 1 ? '' : 's'} found',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.dMuted : AppColors.muted,
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.xs),

          // ── Flight list / empty ───────────────────────────────────────
          Expanded(
            child: flights.isEmpty
                ? EmptyState(
                    icon: Icons.flight_rounded,
                    title: 'No flights found',
                    message: query.isNotEmpty
                        ? 'Try a different flight number or destination.'
                        : 'Enter a flight number or city to search.',
                  )
                : ListView.builder(
                    itemCount: flights.length,
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    itemBuilder: (context, index) {
                      final flight = flights[index];
                      return FlightCard(
                        flight: flight,
                        onTap: () {
                          context.go('/home/flight/${flight.id}');
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
