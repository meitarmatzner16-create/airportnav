import 'package:flutter/material.dart';
import 'package:airport_nav/features/shops/domain/entities/shop.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;

  const ShopCard({
    super.key,
    required this.shop,
    required this.onTap,
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

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(shop.category);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Image placeholder
            Container(
              width: 100,
              height: 110,
              color: Color((categoryColor.value & 0x00FFFFFF) | 0x26000000),
              child: Icon(
                _categoryIcon(shop.category),
                size: 40,
                color: categoryColor,
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      shop.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Category tag and rating
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color((categoryColor.value & 0x00FFFFFF) | 0x1A000000),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Color((categoryColor.value & 0x00FFFFFF) | 0x80000000)),
                          ),
                          child: Text(
                            _categoryLabel(shop.category),
                            style: TextStyle(
                              fontSize: 11,
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          shop.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            shop.location,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Hours
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          shop.openingHours,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
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
}
