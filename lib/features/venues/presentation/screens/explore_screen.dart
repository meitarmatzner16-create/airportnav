import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/widgets/state_views.dart';
import 'package:airport_nav/features/flight/presentation/providers/flight_providers.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';
import 'package:airport_nav/features/venues/domain/services/venue_search_service.dart';
import 'package:airport_nav/features/venues/presentation/providers/venue_providers.dart';
import 'package:airport_nav/features/venues/presentation/providers/explore_providers.dart';
import 'package:airport_nav/features/venues/presentation/widgets/explore_venue_card.dart';

const _gutter = AppSpacing.gutter;

/// Explore: browse airport venues (food, coffee, lounges, shops) with rich
/// physical detail. Renamed from the old "Search"/Venues tab.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openVenue(Venue v) => context.push('/explore/venue/${v.id}');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final airport = ref.watch(detectedAirportProvider);
    final query = ref.watch(venueSearchQueryProvider);
    final isSearching = query.isNotEmpty;
    final allVenues = ref.watch(allVenuesProvider);
    final exploreVenues = ref.watch(exploreVenuesProvider);
    final searchResult = ref.watch(venueSearchProvider);
    final filter = ref.watch(exploreFilterProvider);

    final openCount = allVenues.where((v) => v.isOpenNow).length;
    final listVenues = isSearching ? searchResult.matches : exploreVenues;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(_gutter, 12, _gutter, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Explore $airport',
                            style: theme.textTheme.displaySmall),
                        const SizedBox(height: 2),
                        Text(
                          '$openCount venues open · Terminal 4 · Concourse B',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  _CircleIconButton(
                    icon: Icons.place_rounded,
                    onTap: () => context.push('/map'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // ── Search + mic ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (v) =>
                    ref.read(venueSearchQueryProvider.notifier).state = v,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Search venues, brands, food…',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.onSurfaceVariant, size: 20),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: AppColors.onSurfaceVariant,
                          onPressed: () {
                            _searchController.clear();
                            ref.read(venueSearchQueryProvider.notifier).state = '';
                            _focusNode.unfocus();
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.mic_none_rounded, size: 20),
                          color: AppColors.sky,
                          tooltip: 'Ask the Assistant',
                          onPressed: () => context.push('/voice-chat'),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ── Filter chips ────────────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: _gutter),
                children: [
                  for (final f in ExploreFilter.values)
                    _FilterChip(
                      label: f.label,
                      icon: _filterIcon(f),
                      selected: f == filter,
                      onTap: () =>
                          ref.read(exploreFilterProvider.notifier).state = f,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── Result bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: Text(
                isSearching
                    ? '${listVenues.length} result${listVenues.length == 1 ? '' : 's'} for "$query"'
                    : '${listVenues.length} results · sorted by walk time',
                style:
                    theme.textTheme.labelMedium?.copyWith(color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 8),
            // ── List ────────────────────────────────────────────────
            Expanded(
              child: (isSearching && listVenues.isEmpty)
                  ? _EmptySearch(
                      query: query,
                      result: searchResult,
                      onOpen: _openVenue,
                      onRoute: () => context.push('/map'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                          _gutter, 0, _gutter, AppSpacing.xxl),
                      itemCount: listVenues.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final v = listVenues[i];
                        return ExploreVenueCard(
                          venue: v,
                          onTap: () => _openVenue(v),
                          onRoute: () => context.push('/map'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _filterIcon(ExploreFilter f) => switch (f) {
        ExploreFilter.all => Icons.grid_view_rounded,
        ExploreFilter.food => Icons.restaurant_rounded,
        ExploreFilter.coffee => Icons.coffee_rounded,
        ExploreFilter.lounge => Icons.weekend_rounded,
        ExploreFilter.shop => Icons.shopping_bag_rounded,
        ExploreFilter.dutyFree => Icons.redeem_rounded,
      };
}

// ─────────────────────────────────────────────────────────────────────
// Empty search state + "you might like" suggestions
// ─────────────────────────────────────────────────────────────────────
class _EmptySearch extends StatelessWidget {
  final String query;
  final VenueSearchResult result;
  final void Function(Venue) onOpen;
  final VoidCallback onRoute;

  const _EmptySearch({
    required this.query,
    required this.result,
    required this.onOpen,
    required this.onRoute,
  });

  @override
  Widget build(BuildContext context) {
    final suggestions = result.suggestions;
    return ListView(
      padding:
          const EdgeInsets.fromLTRB(_gutter, AppSpacing.md, _gutter, AppSpacing.xxl),
      children: [
        EmptyState(
          icon: Icons.search_off_rounded,
          title: '"$query" not found here',
          message: 'Try a different venue, brand, or category',
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('You might like',
                style: Theme.of(context).textTheme.titleSmall),
          ),
          for (final s in suggestions.take(6))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ExploreVenueCard(
                venue: s.venue,
                onTap: () => onOpen(s.venue),
                onRoute: onRoute,
              ),
            ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Small widgets
// ─────────────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = selected ? AppColors.sky : AppColors.ink;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? AppColors.skyTint : AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: selected ? AppColors.sky : AppColors.hairline,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 15, color: fg),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: const CircleBorder(side: BorderSide(color: AppColors.hairline)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: AppColors.ink),
        ),
      ),
    );
  }
}
