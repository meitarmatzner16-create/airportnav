import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/core/widgets/venue_image.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';

Venue _v(String id, String cat) => Venue(
      id: id,
      name: id,
      category: cat,
      style: 'casual',
      airportCode: 'JFK',
      terminal: '4',
      floor: 1,
      location: 'B',
      rating: 4,
      openingHours: '24h',
      description: 'x',
      type: VenueType.shop,
    );

void main() {
  test('gradient + seed are deterministic per venue', () {
    final v = _v('shake-shack', 'dining');
    expect(VenueImage.seedOf(v), VenueImage.seedOf(_v('shake-shack', 'dining')));
    expect(VenueImage.gradientFor(v), VenueImage.gradientFor(_v('shake-shack', 'dining')));
    expect(VenueImage.gradientFor(v).length, 2);
  });

  testWidgets('renders without error', (t) async {
    await t.pumpWidget(MaterialApp(
        home: Scaffold(body: VenueImage(venue: _v('a', 'lounge'), height: 120))));
    expect(find.byType(VenueImage), findsOneWidget);
  });
}
