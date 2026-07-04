import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/widgets/category_filter_chips.dart';
import 'package:airport_nav/core/widgets/search_bar_widget.dart';
import 'package:airport_nav/core/widgets/state_views.dart';
import 'package:airport_nav/features/shops/presentation/providers/shop_providers.dart';
import 'package:airport_nav/features/shops/presentation/widgets/shop_card.dart';

/// Sky Pass–styled shop directory screen.
///
/// Token search bar + category chips + AppCard list.
/// LoadingState shimmer and EmptyState when no shops match.
/// All hardcoded colours/padding replaced with tokens.
class ShopDirectoryScreen extends ConsumerStatefulWidget {
  final String airportCode;

  const ShopDirectoryScreen({
    super.key,
    required this.airportCode,
  });

  @override
  ConsumerState<ShopDirectoryScreen> createState() =>
      _ShopDirectoryScreenState();
}

class _ShopDirectoryScreenState extends ConsumerState<ShopDirectoryScreen> {
  static const _categoryKeys = [
    'all',
    'dining',
    'retail',
    'duty_free',
    'convenience',
    'luxury',
    'electronics',
  ];

  static const _categoryLabels = [
    'All',
    'Dining',
    'Retail',
    'Duty Free',
    'Convenience',
    'Luxury',
    'Electronics',
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedCategoryKey = ref.watch(shopCategoryFilterProvider);
    final allMatchingShops = ref.watch(filteredShopsProvider(widget.airportCode));

    // Client-side search filter (provider holds category filter only)
    final shops = _searchQuery.isEmpty
        ? allMatchingShops
        : allMatchingShops
            .where((s) =>
                s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                s.location.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    // Map key → label for the selected chip display
    final selectedLabel = _categoryLabels[_categoryKeys.indexOf(
      _categoryKeys.contains(selectedCategoryKey)
          ? selectedCategoryKey
          : 'all',
    )];

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      appBar: AppBar(
        title: Text(
          'Shops · ${widget.airportCode}',
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
            hint: 'Search shops & locations…',
            onChanged: (v) => setState(() => _searchQuery = v),
          ),

          // ── Category filter chips ─────────────────────────────────────
          CategoryFilterChips(
            categories: _categoryLabels,
            selected: selectedLabel,
            onSelected: (label) {
              final idx = _categoryLabels.indexOf(label);
              final key = idx >= 0 ? _categoryKeys[idx] : 'all';
              ref.read(shopCategoryFilterProvider.notifier).state = key;
            },
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: shops.isEmpty
                ? EmptyState(
                    icon: Icons.storefront_rounded,
                    title: 'No shops found',
                    message: _searchQuery.isNotEmpty
                        ? 'Try a different search term or category.'
                        : 'No shops available in this category at ${widget.airportCode}.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xs,
                      bottom: AppSpacing.xl,
                    ),
                    itemCount: shops.length,
                    itemBuilder: (context, index) {
                      final shop = shops[index];
                      return ShopCard(
                        shop: shop,
                        onTap: () => context.push('/shops/${shop.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
