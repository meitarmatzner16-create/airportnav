import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/features/lounges/presentation/providers/lounge_providers.dart';

class LoungeDetailScreen extends ConsumerWidget {
  final String loungeId;

  const LoungeDetailScreen({
    super.key,
    required this.loungeId,
  });

  Color _accessTypeColor(String accessType) {
    switch (accessType) {
      case 'priority_pass':
        return Colors.indigo;
      case 'airline_lounge':
        return Colors.blue.shade700;
      case 'pay_per_use':
        return Colors.green.shade700;
      case 'membership':
        return Colors.purple.shade700;
      default:
        return Colors.grey;
    }
  }

  String _accessTypeLabel(String accessType) {
    switch (accessType) {
      case 'priority_pass':
        return 'Priority Pass';
      case 'airline_lounge':
        return 'Airline Lounge';
      case 'pay_per_use':
        return 'Pay Per Use';
      case 'membership':
        return 'Membership';
      default:
        return accessType;
    }
  }

  IconData _amenityIcon(String amenity) {
    switch (amenity) {
      case 'wifi':
        return Icons.wifi;
      case 'shower':
        return Icons.shower;
      case 'food':
        return Icons.restaurant;
      case 'bar':
        return Icons.local_bar;
      case 'spa':
        return Icons.spa;
      case 'sleep_pods':
        return Icons.airline_seat_flat;
      case 'business_center':
        return Icons.business_center;
      default:
        return Icons.check_circle_outline;
    }
  }

  String _amenityLabel(String amenity) {
    switch (amenity) {
      case 'wifi':
        return 'Wi-Fi';
      case 'shower':
        return 'Showers';
      case 'food':
        return 'Food';
      case 'bar':
        return 'Bar';
      case 'spa':
        return 'Spa';
      case 'sleep_pods':
        return 'Sleep Pods';
      case 'business_center':
        return 'Business Center';
      default:
        return amenity;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lounge = ref.watch(loungeByIdProvider(loungeId));

    if (lounge == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lounge Not Found')),
        body: const Center(
          child: Text('The requested lounge could not be found.'),
        ),
      );
    }

    final accessColor = _accessTypeColor(lounge.accessType);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Color((accessColor.value & 0x00FFFFFF) | 0x1A000000),
                child: Center(
                  child: Icon(
                    Icons.airline_seat_recline_extra,
                    size: 80,
                    color: Color((accessColor.value & 0x00FFFFFF) | 0x66000000),
                  ),
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    lounge.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Access badge and rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color((accessColor.value & 0x00FFFFFF) | 0x1A000000),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Color((accessColor.value & 0x00FFFFFF) | 0x80000000)),
                        ),
                        child: Text(
                          _accessTypeLabel(lounge.accessType),
                          style: TextStyle(
                            fontSize: 13,
                            color: accessColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          if (lounge.rating >= starValue) {
                            return const Icon(Icons.star,
                                size: 18, color: Colors.amber);
                          } else if (lounge.rating >= starValue - 0.5) {
                            return const Icon(Icons.star_half,
                                size: 18, color: Colors.amber);
                          }
                          return const Icon(Icons.star_border,
                              size: 18, color: Colors.amber);
                        }),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lounge.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Price
                  if (lounge.price != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.payments_outlined,
                              size: 18, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Text(
                            '${lounge.currency} ${lounge.price!.toStringAsFixed(0)} per visit',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 18, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Complimentary with eligible access',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  // Amenities grid
                  const Text(
                    'Amenities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: lounge.amenities.map((amenity) {
                      return Container(
                        width: 95,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _amenityIcon(amenity),
                              size: 26,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _amenityLabel(amenity),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Entry conditions
                  const Text(
                    'Entry Conditions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lounge.entryConditions,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Opening hours
                  _InfoRow(
                    icon: Icons.access_time,
                    label: 'Opening Hours',
                    value: lounge.openingHours,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: lounge.location,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.flight,
                    label: 'Terminal',
                    value: '${lounge.terminal} - ${lounge.airportCode}',
                  ),
                  const SizedBox(height: 28),
                  // Show on Map button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push('/map');
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('Show on Map'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }
}
