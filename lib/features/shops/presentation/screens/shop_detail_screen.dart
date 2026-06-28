import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/features/shops/presentation/providers/shop_providers.dart';

class ShopDetailScreen extends ConsumerWidget {
  final String shopId;

  const ShopDetailScreen({
    super.key,
    required this.shopId,
  });

  String _categoryLabel(String category) {
    switch (category) {
      case 'dining':
        return 'Dining';
      case 'retail':
        return 'Retail';
      case 'duty_free':
        return 'Duty Free';
      case 'convenience':
        return 'Convenience';
      case 'luxury':
        return 'Luxury';
      case 'electronics':
        return 'Electronics';
      default:
        return category;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'dining':
        return Colors.orange;
      case 'retail':
        return Colors.blue;
      case 'duty_free':
        return Colors.purple;
      case 'convenience':
        return Colors.green;
      case 'luxury':
        return Colors.amber.shade800;
      case 'electronics':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'dining':
        return Icons.restaurant;
      case 'retail':
        return Icons.shopping_bag;
      case 'duty_free':
        return Icons.local_offer;
      case 'convenience':
        return Icons.store;
      case 'luxury':
        return Icons.diamond;
      case 'electronics':
        return Icons.devices;
      default:
        return Icons.storefront;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shop = ref.watch(shopByIdProvider(shopId));

    if (shop == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shop Not Found')),
        body: const Center(
          child: Text('The requested shop could not be found.'),
        ),
      );
    }

    final categoryColor = _categoryColor(shop.category);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Color((categoryColor.value & 0x00FFFFFF) | 0x26000000),
                child: Center(
                  child: Icon(
                    _categoryIcon(shop.category),
                    size: 80,
                    color: Color((categoryColor.value & 0x00FFFFFF) | 0x80000000),
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
                    shop.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Category badge and rating
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color((categoryColor.value & 0x00FFFFFF) | 0x1A000000),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Color((categoryColor.value & 0x00FFFFFF) | 0x80000000)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_categoryIcon(shop.category),
                                size: 14, color: categoryColor),
                            const SizedBox(width: 4),
                            Text(
                              _categoryLabel(shop.category),
                              style: TextStyle(
                                fontSize: 13,
                                color: categoryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Stars
                      Row(
                        children: List.generate(5, (index) {
                          final starValue = index + 1;
                          if (shop.rating >= starValue) {
                            return const Icon(Icons.star,
                                size: 18, color: Colors.amber);
                          } else if (shop.rating >= starValue - 0.5) {
                            return const Icon(Icons.star_half,
                                size: 18, color: Colors.amber);
                          }
                          return const Icon(Icons.star_border,
                              size: 18, color: Colors.amber);
                        }),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        shop.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Location & terminal
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    value: shop.location,
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.flight,
                    label: 'Terminal',
                    value: '${shop.terminal} - ${shop.airportCode}',
                  ),
                  const SizedBox(height: 10),
                  // Opening hours
                  _InfoRow(
                    icon: Icons.access_time,
                    label: 'Hours',
                    value: shop.openingHours,
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Description
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    shop.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
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
