import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/features/airport/presentation/providers/airport_providers.dart';
import 'package:airport_nav/features/airport/presentation/widgets/airport_card.dart';

class AirportListScreen extends ConsumerWidget {
  const AirportListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final airports = ref.watch(filteredAirportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Airports'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (value) {
                ref.read(airportSearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: 'Search airports, cities, or codes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Expanded(
            child: airports.isEmpty
                ? const Center(
                    child: Text(
                      'No airports found.',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    padding: const EdgeInsets.all(16),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                    children: airports
                        .map(
                          (airport) => AirportCard(
                            airport: airport,
                            onTap: () {
                              context.go(
                                '/explore/airport/${airport.iataCode}',
                              );
                            },
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
