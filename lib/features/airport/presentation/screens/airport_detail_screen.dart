import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/features/airport/presentation/providers/airport_providers.dart';

class AirportDetailScreen extends ConsumerWidget {
  final String airportCode;

  const AirportDetailScreen({super.key, required this.airportCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final airport = ref.watch(airportByCodeProvider(airportCode));

    if (airport == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Airport not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero section
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          airport.iataCode,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          airport.name,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${airport.city}, ${airport.country}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.whiteAlpha80,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weather card
                  if (airport.weather != null)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              _weatherIcon(airport.weather!.icon),
                              size: 40,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${airport.weather!.tempCelsius.toStringAsFixed(0)} C',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  airport.weather!.condition
                                      .substring(0, 1)
                                      .toUpperCase() +
                                      airport.weather!.condition.substring(1),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Text(
                              'Current Weather',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Facilities grid
                  const Text(
                    'Facilities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: airport.facilities.map((facility) {
                      return Chip(
                        avatar: Icon(
                          _facilityIcon(facility),
                          size: 18,
                          color: AppColors.primary,
                        ),
                        label: Text(
                          _facilityLabel(facility),
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppColors.surfaceVariant,
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Terminals list
                  const Text(
                    'Terminals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: airport.terminals.map((terminal) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAlpha10,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0x4D131137),
                          ),
                        ),
                        child: Text(
                          'Terminal $terminal',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Action buttons row
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.shopping_bag_outlined,
                          label: 'Shops',
                          onTap: () {
                            context.go(
                              '/explore/airport/${airport.iataCode}/shops',
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.airline_seat_individual_suite_outlined,
                          label: 'Lounges',
                          onTap: () {
                            context.go(
                              '/explore/airport/${airport.iataCode}/lounges',
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.map_outlined,
                          label: 'Map',
                          onTap: () {
                            context.go('/map');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _weatherIcon(String icon) {
    switch (icon) {
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'cloud':
        return Icons.cloud;
      case 'grain':
        return Icons.grain;
      case 'ac_unit':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }

  IconData _facilityIcon(String facility) {
    switch (facility) {
      case 'wifi':
        return Icons.wifi;
      case 'lounges':
        return Icons.airline_seat_individual_suite;
      case 'shopping':
        return Icons.shopping_bag;
      case 'dining':
        return Icons.restaurant;
      case 'currency_exchange':
        return Icons.currency_exchange;
      case 'prayer_room':
        return Icons.mosque;
      case 'medical':
        return Icons.local_hospital;
      case 'parking':
        return Icons.local_parking;
      default:
        return Icons.info;
    }
  }

  String _facilityLabel(String facility) {
    switch (facility) {
      case 'wifi':
        return 'Wi-Fi';
      case 'lounges':
        return 'Lounges';
      case 'shopping':
        return 'Shopping';
      case 'dining':
        return 'Dining';
      case 'currency_exchange':
        return 'Currency Exchange';
      case 'prayer_room':
        return 'Prayer Room';
      case 'medical':
        return 'Medical';
      case 'parking':
        return 'Parking';
      default:
        return facility;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
