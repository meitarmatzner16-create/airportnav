import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/features/flight/domain/entities/flight.dart';
import 'package:airport_nav/features/home/presentation/widgets/live_departures_section.dart';
import 'package:airport_nav/features/home/presentation/widgets/quick_start_section.dart';
import 'package:airport_nav/features/home/presentation/widgets/upcoming_flight_card.dart';

Flight _flight({
  String id = 'f1',
  String number = 'DL 1234',
  String city = 'Atlanta',
  String code = 'ATL',
  String? gate = 'A12',
}) {
  final now = DateTime.now().add(const Duration(hours: 1));
  return Flight(
    id: id,
    flightNumber: number,
    airline: 'Delta',
    airlineLogo: '',
    departureAirport: 'JFK',
    departureCity: 'New York',
    arrivalAirport: code,
    arrivalCity: city,
    departureTime: now,
    arrivalTime: now.add(const Duration(hours: 2)),
    status: 'on_time',
    gate: gate,
    terminal: '4',
  );
}

void main() {
  testWidgets('Quick Start keeps its labels but drops the tiny subtitles',
      (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: QuickStartSection(items: [
          QuickStartItem(
              icon: Icons.flight_rounded, label: 'Find My Flight', onTap: () {}),
          QuickStartItem(
              icon: Icons.near_me_rounded, label: 'Navigate', onTap: () {}),
          QuickStartItem(
              icon: Icons.restaurant_rounded,
              label: 'Food & Drinks',
              onTap: () {}),
          QuickStartItem(
              icon: Icons.shopping_bag_outlined, label: 'Shops', onTap: () {}),
        ]),
      ),
    ));
    await t.pump();

    for (final w in ['Find My Flight', 'Navigate', 'Food & Drinks', 'Shops']) {
      expect(find.text(w), findsOneWidget);
    }
    // Only the tiny subtitle line is gone.
    expect(find.text('See live departures'), findsNothing);
    expect(find.text('Get to your gate'), findsNothing);
    expect(find.text('Near your gate'), findsNothing);
    expect(find.text('On your route'), findsNothing);
  });

  testWidgets('Live Departures keeps its column headers and facts', (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LiveDeparturesSection(
          flights: [_flight()],
          selectedFlightId: null,
          onSelect: (_) {},
          onSeeAll: () {},
        ),
      ),
    ));
    await t.pump();

    // Column headers present.
    for (final h in ['FLIGHT', 'DESTINATION', 'TIME', 'GATE', 'STATUS']) {
      expect(find.text(h), findsOneWidget);
    }
    // Facts present.
    expect(find.text('DL 1234'), findsOneWidget);
    expect(find.text('Atlanta (ATL)'), findsOneWidget);
    expect(find.text('A12'), findsOneWidget);
  });

  testWidgets('UpcomingFlightCard shows all four stats with large values',
      (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: UpcomingFlightCard(
            flight: _flight(
                id: 'f2',
                number: 'AA 2468',
                city: 'Chicago',
                code: 'ORD',
                gate: 'C18'),
            onTap: () {},
          ),
        ),
      ),
    ));
    await t.pump();

    for (final label in ['Gate', 'Departs', 'Est. walk', 'Terminal']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('C18'), findsOneWidget);
    expect(find.text('T4'), findsOneWidget);
  });

  testWidgets('home flight surfaces lay out at 320dp with no overflow',
      (t) async {
    t.view.physicalSize = const Size(320, 900);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(children: [
            LiveDeparturesSection(
              flights: [
                _flight(),
                _flight(
                    id: 'f3',
                    number: 'B6 789',
                    city: 'Boston',
                    code: 'BOS',
                    gate: 'B24'),
              ],
              selectedFlightId: 'f3',
              onSelect: (_) {},
              onSeeAll: () {},
            ),
            UpcomingFlightCard(flight: _flight(), onTap: () {}),
          ]),
        ),
      ),
    ));
    await t.pump();
    expect(t.takeException(), isNull);
  });
}
