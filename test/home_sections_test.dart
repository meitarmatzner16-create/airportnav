import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/features/flight/domain/entities/flight.dart';
import 'package:airport_nav/features/home/presentation/widgets/assistant_entry_card.dart';
import 'package:airport_nav/features/home/presentation/widgets/live_departures_section.dart';
import 'package:airport_nav/features/home/presentation/widgets/upcoming_flight_card.dart';

Flight _sample() => Flight(
      id: 'fl-003',
      flightNumber: 'AA 2468',
      airline: 'American Airlines',
      airlineLogo: '',
      departureAirport: 'JFK',
      departureCity: 'New York',
      arrivalAirport: 'ORD',
      arrivalCity: 'Chicago',
      departureTime: DateTime.now().add(const Duration(hours: 1, minutes: 45)),
      arrivalTime: DateTime.now().add(const Duration(hours: 4, minutes: 25)),
      status: 'on_time',
      gate: 'C18',
      terminal: '4',
    );

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 360,
          child: SingleChildScrollView(child: child),
        ),
      ),
    );

void main() {
  testWidgets('LiveDeparturesSection builds without throwing', (tester) async {
    await tester.pumpWidget(_host(LiveDeparturesSection(
      flights: [_sample()],
      selectedFlightId: 'fl-003',
      onSelect: (_) {},
      onSeeAll: () {},
    )));
    expect(tester.takeException(), isNull);
  });

  testWidgets('UpcomingFlightCard builds without throwing', (tester) async {
    await tester.pumpWidget(_host(UpcomingFlightCard(
      flight: _sample(),
      onTap: () {},
    )));
    expect(tester.takeException(), isNull);
  });

  testWidgets('AssistantEntryCard builds without throwing', (tester) async {
    await tester.pumpWidget(_host(AssistantEntryCard(onTap: () {})));
    expect(tester.takeException(), isNull);
  });
}
