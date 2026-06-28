import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/features/shops/presentation/providers/shop_providers.dart';
import 'package:airport_nav/features/shops/presentation/widgets/shop_card.dart';

class ShopDirectoryScreen extends ConsumerWidget {
  final String airportCode;

  const ShopDirectoryScreen({
    super.key,
    required this.airportCode,
  });

  static const _categories = [
    {'key': 'all', 'label': 'All'},
    {'key': 'dining', 'label': 'Dining'},
    {'key': 'retail', 'label': 'Retail'},
    {'key': 'duty_free', 'label': 'Duty Free'},
    {'key': 'convenience', 'label': 'Convenience'},
    {'key': 'luxury', 'label': 'Luxury'},
    {'key': 'electronics', 'label': 'Electronics'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(shopCategoryFilterProvider);
    final shops = ref.watch(filteredShopsProvider(airportCode));

    return Scaffold(
      appBar: AppBar(
        title: Text('Shops at $airportCode'),
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = selectedCategory == category['key'];
                return FilterChip(
                  label: Text(category['label']!),
                  selected: isSelected,
                  onSelected: (_) {
                    ref.read(shopCategoryFilterProvider.notifier).state =
                        category['key']!;
                  },
                  selectedColor: AppColors.accentAlpha20,
                  checkmarkColor: AppColors.accent,
                );
              },
            ),
          ),
          // Shop list
          Expanded(
            child: shops.isEmpty
                ? const Center(
                    child: Text(
                      'No shops found for this category.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: shops.length,
                    itemBuilder: (context, index) {
                      final shop = shops[index];
                      return ShopCard(
                        shop: shop,
                        onTap: () {
                          context.push('/shops/${shop.id}');
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
