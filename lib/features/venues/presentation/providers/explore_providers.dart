import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';
import 'package:airport_nav/features/venues/presentation/providers/venue_providers.dart';

/// Category buckets shown as filter chips on the Explore page.
enum ExploreFilter { all, food, coffee, lounge, shop, dutyFree }

extension ExploreFilterX on ExploreFilter {
  String get label => switch (this) {
        ExploreFilter.all => 'All',
        ExploreFilter.food => 'Food',
        ExploreFilter.coffee => 'Coffee',
        ExploreFilter.lounge => 'Lounge',
        ExploreFilter.shop => 'Shop',
        ExploreFilter.dutyFree => 'Duty-Free',
      };

  bool matches(Venue v) => switch (this) {
        ExploreFilter.all => true,
        ExploreFilter.food => v.category == 'dining',
        ExploreFilter.coffee => v.tags.contains('coffee') ||
            v.tags.contains('cafe') ||
            v.items.any((i) => i.toLowerCase().contains('coffee')) ||
            v.name.toLowerCase().contains('coffee'),
        ExploreFilter.lounge =>
          v.type == VenueType.lounge || v.category == 'lounge',
        ExploreFilter.shop => const {'retail', 'luxury', 'electronics', 'convenience'}
            .contains(v.category),
        ExploreFilter.dutyFree => v.category == 'duty_free',
      };
}

/// Currently-selected Explore filter chip.
final exploreFilterProvider = StateProvider<ExploreFilter>((ref) => ExploreFilter.all);

/// Venues for the Explore list: filtered by the active chip + sorted by walk
/// time ascending (unknown walk times sort last).
final exploreVenuesProvider = Provider<List<Venue>>((ref) {
  final filter = ref.watch(exploreFilterProvider);
  final venues = [...ref.watch(allVenuesProvider)].where(filter.matches).toList();
  venues.sort((a, b) {
    final wa = a.walkMinutes ?? 9999;
    final wb = b.walkMinutes ?? 9999;
    return wa.compareTo(wb);
  });
  return venues;
});

/// Look up a single venue by id (for the detail route).
final venueByIdProvider = Provider.family<Venue?, String>((ref, id) {
  for (final v in ref.watch(allVenuesProvider)) {
    if (v.id == id) return v;
  }
  return null;
});

/// Favorited venue ids (in-memory for now).
final favoriteVenuesProvider = StateProvider<Set<String>>((ref) => <String>{});

/// Toggle a venue's favorite state.
void toggleFavorite(WidgetRef ref, String id) {
  final controller = ref.read(favoriteVenuesProvider.notifier);
  final next = {...controller.state};
  if (next.contains(id)) {
    next.remove(id);
  } else {
    next.add(id);
  }
  controller.state = next;
}
