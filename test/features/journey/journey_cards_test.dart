import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/flight/domain/entities/flight.dart';
import 'package:airport_nav/features/journey/domain/entities/journey.dart';
import 'package:airport_nav/features/journey/domain/entities/journey_step.dart';
import 'package:airport_nav/features/journey/presentation/widgets/current_step_card.dart';
import 'package:airport_nav/features/journey/presentation/widgets/free_time_strip.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

Flight _flight() => Flight(
      id: 'fl-003',
      flightNumber: 'AA 2468',
      airline: 'American Airlines',
      airlineLogo: 'assets/airlines/aa.png',
      departureAirport: 'JFK',
      departureCity: 'New York',
      arrivalAirport: 'ORD',
      arrivalCity: 'Chicago',
      departureTime: DateTime(2026, 7, 31, 11, 20),
      arrivalTime: DateTime(2026, 7, 31, 13, 25),
      status: 'on_time',
      gate: 'C18',
      terminal: '4',
    );

Journey _journey() => Journey(
      stage: JourneyStage.departing,
      flight: _flight(),
      currentIndex: 1,
      pinnedNow: DateTime(2026, 7, 31, 10, 3),
      steps: [
        const JourneyStep(kind: StepKind.flight, title: 'Flight', where: 'x'),
        JourneyStep(
          kind: StepKind.security,
          title: 'Head to Security',
          where: 'Terminal 4 · Main checkpoint · Lane B',
          note: 'Fast Track open - your ticket qualifies',
          deadline: DateTime(2026, 7, 31, 10, 35),
          queueMinutes: 12,
          walkMinutes: 4,
        ),
        const JourneyStep(
          kind: StepKind.gate,
          title: 'Gate C18',
          where: 'Terminal 4 · Concourse C',
          walkMinutes: 12,
        ),
      ],
    );

Venue _venue({
  required String id,
  required String name,
  required int walk,
  int? visit,
  String category = 'dining',
}) =>
    Venue(
      id: id,
      name: name,
      category: category,
      style: 'casual',
      airportCode: 'JFK',
      terminal: '4',
      floor: 1,
      location: 'Concourse C',
      rating: 4.4,
      openingHours: '24h',
      description: 'x',
      type: VenueType.shop,
      walkMinutes: walk,
      avgVisitMinutes: visit,
    );

void main() {
  group('CurrentStepCard', () {
    testWidgets('shows where, the note and the three stats', (t) async {
      await t.pumpWidget(_wrap(CurrentStepCard(journey: _journey())));
      await t.pump(const Duration(milliseconds: 50));

      expect(find.text('Head to Security'), findsOneWidget);
      expect(find.text('Terminal 4 · Main checkpoint · Lane B'), findsOneWidget);
      expect(find.textContaining('Fast Track'), findsOneWidget);
      expect(find.text('12 min'), findsOneWidget);
      expect(find.text('4 min'), findsOneWidget);
      expect(find.text('Queue'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('omits the queue stat when there is no queue', (t) async {
      final j = _journey().copyWith(steps: [
        const JourneyStep(kind: StepKind.flight, title: 'Flight', where: 'x'),
        const JourneyStep(
          kind: StepKind.gate,
          title: 'Gate C18',
          where: 'Concourse C',
          walkMinutes: 12,
        ),
      ]);
      await t.pumpWidget(_wrap(CurrentStepCard(journey: j)));
      await t.pump(const Duration(milliseconds: 50));

      expect(find.text('Queue'), findsNothing);
      expect(find.text('Walk'), findsOneWidget);
    });
  });

  group('venueCostMinutes', () {
    test('counts the walk both ways plus the visit', () {
      expect(venueCostMinutes(_venue(id: 'a', name: 'A', walk: 4, visit: 20)), 28);
    });

    test('falls back to a category dwell when the visit is unknown', () {
      final v = _venue(id: 'b', name: 'B', walk: 3, category: 'lounge');
      expect(v.avgVisitMinutes, isNull);
      expect(venueCostMinutes(v), 6 + defaultDwellFor('lounge'));
    });

    test('every category has a dwell above zero', () {
      for (final c in ['dining', 'lounge', 'shopping', 'services', 'unknown']) {
        expect(defaultDwellFor(c), greaterThan(0));
      }
    });
  });

  group('FreeTimeStrip', () {
    testWidgets('shows only venues that fit the free time', (t) async {
      await t.pumpWidget(_wrap(FreeTimeStrip(
        freeTime: const Duration(minutes: 25),
        venues: [
          _venue(id: 'near', name: 'Blue Bottle', walk: 2, visit: 10),
          _venue(id: 'far', name: 'Far Lounge', walk: 30, visit: 60),
        ],
      )));
      await t.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('25'), findsWidgets);
      expect(find.text('Blue Bottle'), findsOneWidget);
      expect(find.text('Far Lounge'), findsNothing);
    });

    testWidgets('turns urgent when free time is negative', (t) async {
      await t.pumpWidget(_wrap(FreeTimeStrip(
        freeTime: const Duration(minutes: -6),
        venues: [_venue(id: 'near', name: 'Blue Bottle', walk: 2, visit: 10)],
      )));
      await t.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('behind'), findsOneWidget);
      expect(find.text('Blue Bottle'), findsNothing);
    });

    testWidgets('renders nothing when free time is unknown', (t) async {
      await t.pumpWidget(_wrap(const FreeTimeStrip(freeTime: null, venues: [])));
      await t.pump(const Duration(milliseconds: 50));

      expect(t.takeException(), isNull);
    });
  });
}
