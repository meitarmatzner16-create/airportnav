import 'package:flutter/material.dart';
import 'package:airport_nav/features/lounges/domain/entities/lounge.dart';

class LoungeCard extends StatelessWidget {
  final Lounge lounge;
  final VoidCallback onTap;

  const LoungeCard({
    super.key,
    required this.lounge,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final accessColor = _accessTypeColor(lounge.accessType);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: name and access badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color((accessColor.value & 0x00FFFFFF) | 0x1A000000),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.airline_seat_recline_extra,
                      color: accessColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lounge.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color((accessColor.value & 0x00FFFFFF) | 0x1A000000),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Color((accessColor.value & 0x00FFFFFF) | 0x66000000)),
                              ),
                              child: Text(
                                _accessTypeLabel(lounge.accessType),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: accessColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              lounge.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price
                  if (lounge.price != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${lounge.currency} ${lounge.price!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Included',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Amenity icons
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: lounge.amenities.map((amenity) {
                  return Tooltip(
                    message: amenity.replaceAll('_', ' '),
                    child: Icon(
                      _amenityIcon(amenity),
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              // Location and hours
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      lounge.location,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.access_time, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    lounge.openingHours,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
