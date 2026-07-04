import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';
import 'package:airport_nav/features/venues/domain/services/venue_search_service.dart';
import 'package:airport_nav/features/venues/domain/taxonomy/venue_taxonomy.dart';
import 'package:airport_nav/features/venues/presentation/providers/venue_providers.dart';
import 'package:airport_nav/core/widgets/app_card.dart';
import 'package:airport_nav/core/widgets/screen_header.dart';
import 'package:airport_nav/core/widgets/section_header.dart';
import 'package:airport_nav/core/widgets/state_views.dart';
import 'package:airport_nav/features/flight/presentation/providers/flight_providers.dart';

class VenuesScreen extends ConsumerStatefulWidget {
  const VenuesScreen({super.key});

  @override
  ConsumerState<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends ConsumerState<VenuesScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(venueSearchQueryProvider);
    final allVenues = ref.watch(allVenuesProvider);
    final byLetter = ref.watch(venuesByLetterProvider);
    final searchResult = ref.watch(venueSearchProvider);
    final airport = ref.watch(detectedAirportProvider);
    final isSearching = query.isNotEmpty;

    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
       child: Column(
        children: [
          // ── Screen header ────────────────────────────────────────
          ScreenHeader(
            title: 'Venues',
            subtitle: isSearching
                ? '${searchResult.matches.length} result${searchResult.matches.length == 1 ? '' : 's'}'
                : '${allVenues.length} at $airport',
            bottomPadding: AppSpacing.smMd,
            actions: [
              TonalPill(
                label: 'Map',
                icon: Icons.map_rounded,
                onTap: () => context.push('/map'),
              ),
            ],
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.gutter,
                0, AppSpacing.gutter, AppSpacing.smMd),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: (value) {
                ref.read(venueSearchQueryProvider.notifier).state = value;
              },
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search venues, brands, food…',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.smMd, right: 8),
                  child: Icon(Icons.search_rounded,
                      color: AppColors.onSurfaceVariant, size: 20),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 40, minHeight: 40),
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
                    : null,
              ),
            ),
          ),


          // Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: isSearching
                  ? _SearchResultsView(
                      key: ValueKey('search-$query'),
                      query: query,
                      result: searchResult,
                    )
                  : _AlphabeticalListView(
                      key: const ValueKey('browse'), byLetter: byLetter),
            ),
          ),
        ],
       ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Alphabetical browse (default state)
// ─────────────────────────────────────────────────────
class _AlphabeticalListView extends StatelessWidget {
  final Map<String, List<Venue>> byLetter;

  const _AlphabeticalListView({super.key, required this.byLetter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final letters = byLetter.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xxl),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        final venues = byLetter[letter]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: AppSpacing.smMd, bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Text(
                    letter,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isDark ? AppColors.dSky : AppColors.sky,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.hairline,
                    ),
                  ),
                ],
              ),
            ),
            ...venues.map((v) => _VenueListTile(venue: v)),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────
// Search results view
// ─────────────────────────────────────────────────────
class _SearchResultsView extends StatelessWidget {
  final String query;
  final VenueSearchResult result;

  const _SearchResultsView({
    super.key,
    required this.query,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final matches = result.matches;
    final suggestions = result.suggestions;
    final intent = result.intent;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.xxl),
      children: [
        if (matches.isNotEmpty) ...[
          SectionHeader(title: 'Found'),
          const SizedBox(height: AppSpacing.sm),
          ...matches.map((v) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.smMd),
                child: _VenueResultCard(venue: v),
              )),
        ],

        if (matches.isEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          EmptyState(
            icon: Icons.search_off_rounded,
            title: '"$query" not found here',
            message: result.hasIntent
                ? 'Here are similar venues you might like'
                : 'Try a different venue, brand, or category',
          ),
          if (result.hasIntent) ...[
            const SizedBox(height: AppSpacing.smMd),
            _IntentBanner(intent: intent),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],

        if (suggestions.isNotEmpty) ...[
          if (matches.isNotEmpty) const SizedBox(height: AppSpacing.smMd),
          SectionHeader(
            title: matches.isNotEmpty ? 'Similar venues' : 'You might like',
          ),
          const SizedBox(height: AppSpacing.sm),
          ...suggestions.map((s) => _VenueListTile(
                venue: s.venue,
                matchedTags: s.matchedTags,
                matchedItems: s.matchedItems,
              )),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
// "Looks like you want" banner — shown when no exact match
// but the query mapped to a category/tag/brand.
// ─────────────────────────────────────────────────────
class _IntentBanner extends StatelessWidget {
  final QueryIntent intent;

  const _IntentBanner({required this.intent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final parts = <String>[];
    if (intent.category != null) {
      parts.add(VenueTaxonomy.labelForCategory(intent.category!));
    }
    parts.addAll(intent.tags.map(VenueTaxonomy.labelForTag));
    if (parts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.smMd),
      decoration: BoxDecoration(
        color: AppColors.skyAlpha10,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.skyAlpha15, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_rounded,
                  size: 14, color: AppColors.sky),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  intent.brand != null
                      ? 'Looks like you want ${intent.brand}'
                      : 'Looks like you want',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.sky,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: parts.map((p) => _IntentChip(label: p)).toList(),
          ),
        ],
      ),
    );
  }
}

class _IntentChip extends StatelessWidget {
  final String label;
  const _IntentChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.skyAlpha10,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.skyAlpha15, width: 1),
      ),
      child: Text(label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.sky,
              fontWeight: FontWeight.w600,
              fontSize: 11)),
    );
  }
}

// ─────────────────────────────────────────────────────
// Venue result card (detailed, for matches)
// ─────────────────────────────────────────────────────
class _VenueResultCard extends StatelessWidget {
  final Venue venue;

  const _VenueResultCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Row(
          children: [
            _VenueLogo(venue: venue, size: 48),
            const SizedBox(width: AppSpacing.smMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(venue.name,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _CategoryChip(label: venue.categoryLabel),
                      const SizedBox(width: 6),
                      _StyleChip(style: venue.style),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.layers_rounded,
                          size: AppSpacing.iconXs,
                          color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text('Floor ${venue.floor}',
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(width: 10),
                      const Icon(Icons.business_rounded,
                          size: AppSpacing.iconXs,
                          color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(venue.terminal,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: AppColors.onSurfaceVariant)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: AppSpacing.iconXs,
                          color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Text(venue.openingHours,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            // Rating chip
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warningAlpha15,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 12, color: AppColors.star),
                  const SizedBox(width: 3),
                  Text(venue.rating.toStringAsFixed(1),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Venue list tile (compact, for browse + suggestions).
// When matchedTags is non-empty, renders a row of chips to explain
// *why* this venue is being suggested.
// ─────────────────────────────────────────────────────
class _VenueListTile extends StatelessWidget {
  final Venue venue;
  final Set<String> matchedTags;
  final Set<String> matchedItems;

  const _VenueListTile({
    required this.venue,
    this.matchedTags = const {},
    this.matchedItems = const {},
  });

  String _humanize(String key) {
    return key
        .split(RegExp(r'[_ ]'))
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Build a unified list of "why" chips: items first (most specific),
    // then tags. Cap to 3 to keep the row breathable.
    final whyChips = <Widget>[];
    for (final item in matchedItems.take(2)) {
      whyChips.add(_TagChip(
        label: _humanize(item),
        accent: true,
      ));
    }
    for (final tag in matchedTags.take(3 - whyChips.length)) {
      whyChips.add(_TagChip(
        label: VenueTaxonomy.labelForTag(tag),
      ));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.smMd, horizontal: AppSpacing.xs),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.hairline, width: 1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _VenueLogo(venue: venue, size: 40),
          const SizedBox(width: AppSpacing.smMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 2),
                Text(
                  '${venue.categoryLabel} · Floor ${venue.floor}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (whyChips.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: whyChips,
                  ),
                ],
              ],
            ),
          ),
          // Rating
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    size: 12, color: AppColors.star),
                const SizedBox(width: 3),
                Text(venue.rating.toStringAsFixed(1),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool accent;
  const _TagChip({required this.label, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: accent ? AppColors.accentAlpha10 : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: accent ? AppColors.accent : AppColors.onSurface,
                fontWeight: FontWeight.w600,
              )),
    );
  }
}

// ─────────────────────────────────────────────────────
// Small widgets
// ─────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _StyleChip extends StatelessWidget {
  final String style;
  const _StyleChip({required this.style});

  String get _label {
    switch (style) {
      case 'luxury':
        return 'Luxury';
      case 'fancy':
        return 'Fancy';
      case 'casual':
        return 'Casual';
      case 'street_vibes':
        return 'Street Vibes';
      case 'fast_food':
        return 'Fast Food';
      default:
        return style;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text('· $_label',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w500));
  }
}

// ─────────────────────────────────────────────────────
// Venue logo with network image + letter fallback
// ─────────────────────────────────────────────────────
class _VenueLogo extends StatelessWidget {
  final Venue venue;
  final double size;

  const _VenueLogo({required this.venue, this.size = 36});

  @override
  Widget build(BuildContext context) {
    if (venue.logoUrl != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(size * 0.28),
          border: Border.all(color: AppColors.hairline, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          venue.logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _LetterFallback(venue: venue, size: size),
        ),
      );
    }
    return _LetterFallback(venue: venue, size: size);
  }
}

class _LetterFallback extends StatelessWidget {
  final Venue venue;
  final double size;

  const _LetterFallback({required this.venue, required this.size});

  @override
  Widget build(BuildContext context) {
    final letter = venue.name[0].toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: AppColors.sky,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.42,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}
