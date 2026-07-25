import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';
import 'package:airport_nav/features/venues/domain/entities/venue_details.dart';
import 'package:airport_nav/features/venues/domain/catalog/venue_details_catalog.dart';
import 'package:airport_nav/features/venues/presentation/providers/explore_providers.dart';

Venue _v({
  required String name,
  required String category,
  VenueType type = VenueType.shop,
  int? walk,
}) =>
    Venue(
      id: name,
      name: name,
      category: category,
      style: 'casual',
      airportCode: 'JFK',
      terminal: '4',
      floor: 1,
      location: 'Concourse B',
      rating: 4.0,
      openingHours: '24h',
      description: 'x',
      type: type,
      walkMinutes: walk,
    );

void main() {
  test('enrichVenue derives a walk time when absent', () {
    final e = enrichVenue(_v(name: 'Nowhere Kiosk', category: 'convenience'));
    expect(e.walkMinutes, isNotNull);
    expect(e.walkMinutes! >= 2 && e.walkMinutes! <= 12, isTrue);
  });

  test('enrichVenue applies the catalog patch for a known venue', () {
    final e = enrichVenue(_v(name: 'Centurion Lounge', category: 'lounge', type: VenueType.lounge));
    expect(e.amenities.contains(Amenity.shower), isTrue);
    expect(e.amenities.contains(Amenity.napRoom), isTrue);
    expect(e.access?.entryCost, contains('walk-in'));
  });

  test('ExploreFilter.lounge matches only lounges', () {
    final lounge = _v(name: 'A', category: 'lounge', type: VenueType.lounge);
    final food = _v(name: 'B', category: 'dining');
    expect(ExploreFilter.lounge.matches(lounge), isTrue);
    expect(ExploreFilter.lounge.matches(food), isFalse);
    expect(ExploreFilter.all.matches(food), isTrue);
  });

  test('ExploreFilter.shop matches retail-family categories', () {
    expect(ExploreFilter.shop.matches(_v(name: 'C', category: 'retail')), isTrue);
    expect(ExploreFilter.shop.matches(_v(name: 'D', category: 'luxury')), isTrue);
    expect(ExploreFilter.shop.matches(_v(name: 'E', category: 'dining')), isFalse);
  });
}
