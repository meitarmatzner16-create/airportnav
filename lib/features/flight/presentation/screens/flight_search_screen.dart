import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../providers/flight_providers.dart';
import '../widgets/flight_card.dart';

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
    final flights = ref.watch(filteredFlightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Flights'),
        elevation: AppSpacing.appBarElevation,
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref.read(flightSearchProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search by flight number or city...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(flightSearchProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${flights.length} flight${flights.length == 1 ? '' : 's'} found',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Flight list
          Expanded(
            child: flights.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.flight_outlined,
                          size: 64,
                          color: const Color(0x805E6272),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No flights found',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Try searching with a different query',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: flights.length,
                    padding:
                        const EdgeInsets.only(bottom: AppSpacing.xl),
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
