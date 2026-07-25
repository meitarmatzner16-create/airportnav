import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';
import 'package:airport_nav/features/venues/domain/entities/venue_details.dart';
import 'package:airport_nav/features/venues/presentation/providers/venue_providers.dart';
import 'package:airport_nav/features/venues/presentation/screens/venue_detail_screen.dart';

Venue _lounge() => Venue(
      id: 'lng',
      name: 'Sky Lounge',
      category: 'lounge',
      style: 'luxury',
      airportCode: 'JFK',
      terminal: '4',
      floor: 2,
      location: 'Concourse B',
      rating: 4.6,
      openingHours: '24h',
      description: 'Relax before your flight.',
      type: VenueType.lounge,
      amenities: {Amenity.shower, Amenity.napRoom, Amenity.vegan},
      access: const VenueAccess(rules: ['Priority Pass'], entryCost: r'$59 walk-in'),
      walkMinutes: 7,
      nearestGate: 'B23',
    );

Venue _dining() => Venue(
      id: 'din',
      name: 'Sbarro',
      category: 'dining',
      style: 'casual',
      airportCode: 'JFK',
      terminal: '4',
      floor: 1,
      location: 'Food Court',
      rating: 4.3,
      openingHours: '24h',
      description: 'Pizza by the slice.',
      type: VenueType.shop,
      highlights: const [VenueHighlight(name: 'NY cheese slice', price: r'$5.50', note: 'Bestseller')],
      walkMinutes: 4,
    );

void main() {
  testWidgets('lounge detail shows amenity grid + access', (t) async {
    await t.pumpWidget(ProviderScope(
      overrides: [allVenuesProvider.overrideWithValue([_lounge()])],
      child: const MaterialApp(home: VenueDetailScreen(venueId: 'lng')),
    ));
    await t.pump(const Duration(milliseconds: 200));
    expect(find.text("WHAT'S INSIDE"), findsOneWidget);
    expect(find.text('Showers'), findsOneWidget);
    expect(find.text('Nap rooms'), findsOneWidget);
    expect(find.textContaining('walk-in'), findsOneWidget);
  });

  testWidgets('dining detail shows menu highlights, not amenity grid', (t) async {
    await t.pumpWidget(ProviderScope(
      overrides: [allVenuesProvider.overrideWithValue([_dining()])],
      child: const MaterialApp(home: VenueDetailScreen(venueId: 'din')),
    ));
    await t.pump(const Duration(milliseconds: 200));
    expect(find.text('HIGHLIGHTS'), findsOneWidget);
    expect(find.text('NY cheese slice'), findsOneWidget);
    expect(find.text(r'$5.50'), findsOneWidget);
    expect(find.text("WHAT'S INSIDE"), findsNothing);
  });
}
