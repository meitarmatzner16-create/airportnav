import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/shops/presentation/providers/shop_providers.dart';
import 'package:airport_nav/features/lounges/presentation/providers/lounge_providers.dart';
import 'package:airport_nav/features/flight/presentation/providers/flight_providers.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';
import 'package:airport_nav/features/venues/domain/services/venue_search_service.dart';
import 'package:airport_nav/features/venues/domain/taxonomy/venue_taxonomy.dart';

/// Search query state
final venueSearchQueryProvider = StateProvider<String>((ref) => '');

final venueSearchServiceProvider = Provider<VenueSearchService>((ref) {
  return const VenueSearchService();
});

/// All venues for the detected airport (shops + lounges merged), with
/// taxonomy-derived tags attached.
final allVenuesProvider = Provider<List<Venue>>((ref) {
  final airport = ref.watch(detectedAirportProvider);
  final shops = ref.watch(shopsByAirportProvider(airport));
  final lounges = ref.watch(loungesByAirportProvider(airport));

  final venues = <Venue>[];

  for (final s in shops) {
    venues.add(Venue(
      id: s.id,
      name: s.name,
      category: s.category,
      style: s.style,
      tags: VenueTaxonomy.deriveTagsForVenue(
        name: s.name,
        category: s.category,
        style: s.style,
      ),
      items: VenueTaxonomy.deriveItemsForVenue(name: s.name),
      airportCode: s.airportCode,
      terminal: s.terminal,
      floor: s.floor,
      location: s.location,
      rating: s.rating,
      openingHours: s.openingHours,
      description: s.description,
      type: VenueType.shop,
      logoUrl: _logoUrl(s.name),
    ));
  }

  for (final l in lounges) {
    venues.add(Venue(
      id: l.id,
      name: l.name,
      category: 'lounge',
      style: l.style,
      tags: VenueTaxonomy.deriveTagsForVenue(
        name: l.name,
        category: 'lounge',
        style: l.style,
        extraHints: l.amenities,
      ),
      items: VenueTaxonomy.deriveItemsForVenue(name: l.name),
      airportCode: l.airportCode,
      terminal: l.terminal,
      floor: l.floor,
      location: l.location,
      rating: l.rating,
      openingHours: l.openingHours,
      description: l.entryConditions,
      type: VenueType.lounge,
      logoUrl: _logoUrl(l.name),
    ));
  }

  venues.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return venues;
});

/// Venues grouped by first letter for the alphabetical browse
final venuesByLetterProvider = Provider<Map<String, List<Venue>>>((ref) {
  final venues = ref.watch(allVenuesProvider);
  final grouped = <String, List<Venue>>{};
  for (final v in venues) {
    final letter = v.name[0].toUpperCase();
    grouped.putIfAbsent(letter, () => []).add(v);
  }
  return grouped;
});

/// Full search result — exposes matches, suggestions, and the parsed intent.
final venueSearchProvider = Provider<VenueSearchResult>((ref) {
  final query = ref.watch(venueSearchQueryProvider);
  final venues = ref.watch(allVenuesProvider);
  final service = ref.watch(venueSearchServiceProvider);
  return service.search(query, venues);
});

/// Logo URL via the brand catalog → Clearbit Logo API.
String? _logoUrl(String name) {
  final domain = VenueTaxonomy.logoDomainFor(name);
  if (domain == null) return null;
  return 'https://logo.clearbit.com/$domain?size=128';
}
