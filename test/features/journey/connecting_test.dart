import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/features/flight/data/datasources/flight_mock_datasource.dart';
import 'package:airport_nav/features/journey/data/journey_mock.dart';
import 'package:airport_nav/features/journey/domain/entities/journey.dart';
import 'package:airport_nav/features/journey/domain/entities/journey_step.dart';

void main() {
  test('at least one inbound lands before a JFK departure leaves', () {
    final all = FlightMockDatasource().getAllFlights();
    final arrivals = all.where((f) => f.arrivalAirport == 'JFK').toList();
    final departures = all.where((f) => f.departureAirport == 'JFK').toList();

    expect(arrivals, isNotEmpty);
    expect(departures, isNotEmpty);

    final connectable = arrivals.any((a) => departures.any((d) => d
        .departureTime
        .isAfter(a.arrivalTime.add(const Duration(minutes: 45)))));
    expect(connectable, isTrue,
        reason:
            'a connection needs an inbound that lands before an outbound leaves');
  });

  test('the connecting spine reuses the shape but swaps the first steps', () {
    final all = FlightMockDatasource().getAllFlights();
    final inbound = all.firstWhere((f) => f.id == 'fl-016');
    final outbound = all.firstWhere((f) => f.departureAirport == 'JFK');

    final j = buildConnectingJourney(
      pinnedNow: DateTime(2026, 7, 31, 10, 3),
      flight: outbound,
      inbound: inbound,
    );

    expect(j.stage, JourneyStage.connecting);
    expect(j.inboundFlight, isNotNull);
    expect(j.awaitingFlight, isFalse);
    expect(
      j.steps.map((s) => s.kind).toList(),
      [
        StepKind.flight,
        StepKind.arrive,
        StepKind.transfer,
        StepKind.security,
        StepKind.gate,
        StepKind.boarding,
      ],
    );
    // The arrive step names the flight you actually landed on.
    final arrive = j.steps.firstWhere((s) => s.kind == StepKind.arrive);
    expect(arrive.note, contains('AA 106'));
  });

  test('connecting waits on step one until BOTH flights are chosen', () {
    final all = FlightMockDatasource().getAllFlights();
    final inbound = all.firstWhere((f) => f.id == 'fl-016');
    final outbound = all.firstWhere((f) => f.departureAirport == 'JFK');
    final now = DateTime(2026, 7, 31, 10, 3);

    expect(buildConnectingJourney(pinnedNow: now).awaitingFlight, isTrue);
    expect(
      buildConnectingJourney(pinnedNow: now, flight: outbound).awaitingFlight,
      isTrue,
      reason: 'outbound alone is not a connection',
    );
    expect(
      buildConnectingJourney(pinnedNow: now, inbound: inbound).awaitingFlight,
      isTrue,
      reason: 'inbound alone is not a connection',
    );
    expect(
      buildConnectingJourney(pinnedNow: now, flight: outbound, inbound: inbound)
          .awaitingFlight,
      isFalse,
    );
  });
}
