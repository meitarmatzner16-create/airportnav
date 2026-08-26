import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/features/flight/domain/entities/flight.dart';
import 'package:airport_nav/features/journey/data/journey_mock.dart';
import 'package:airport_nav/features/journey/domain/entities/journey.dart';
import 'package:airport_nav/features/journey/domain/entities/journey_step.dart';

final _now = DateTime(2026, 7, 31, 10, 3);

Flight _flight({String? gate = 'C18', String? terminal = '4'}) => Flight(
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
      gate: gate,
      terminal: terminal,
    );

void main() {
  test('with no flight the journey waits on step one', () {
    final j = buildDepartingJourney(pinnedNow: _now);
    expect(j.awaitingFlight, isTrue);
    expect(j.currentIndex, 0);
    expect(j.steps.first.kind, StepKind.flight);
    expect(j.stage, JourneyStage.departing);
  });

  test('choosing a flight moves off step one and builds the full spine', () {
    final j = buildDepartingJourney(pinnedNow: _now, flight: _flight());
    expect(j.awaitingFlight, isFalse);
    expect(j.currentIndex, 1);
    expect(
      j.steps.map((s) => s.kind).toList(),
      [
        StepKind.flight,
        StepKind.checkIn,
        StepKind.bagDrop,
        StepKind.security,
        StepKind.gate,
        StepKind.boarding,
      ],
    );
  });

  test('the gate step names the real gate', () {
    final j = buildDepartingJourney(pinnedNow: _now, flight: _flight());
    final gate = j.steps.firstWhere((s) => s.kind == StepKind.gate);
    expect(gate.title, 'Gate C18');
  });

  test('queue lengths move with the tick', () {
    final a = buildDepartingJourney(pinnedNow: _now, flight: _flight(), tick: 0);
    final b = buildDepartingJourney(pinnedNow: _now, flight: _flight(), tick: 5);
    final qa = a.steps.firstWhere((s) => s.kind == StepKind.security).queueMinutes;
    final qb = b.steps.firstWhere((s) => s.kind == StepKind.security).queueMinutes;
    expect(qa, isNot(equals(qb)));
  });

  test('the gate change fires at the scripted tick and moves the gate', () {
    final before = buildDepartingJourney(pinnedNow: _now, flight: _flight(), tick: 1);
    final after = buildDepartingJourney(pinnedNow: _now, flight: _flight(), tick: 7);
    expect(before.disruption, isNull);
    expect(after.disruption, isNotNull);
    expect(after.disruption!.newGate, isNotNull);
    expect(after.effectiveGate, after.disruption!.newGate);
    expect(after.effectiveGate, isNot('C18'));
  });

  group('terminalLabel', () {
    test('prefixes a bare number', () => expect(terminalLabel('4'), 'Terminal 4'));
    test('leaves a written name alone',
        () => expect(terminalLabel('Tom Bradley International'), 'Tom Bradley International'));
    test('handles null', () => expect(terminalLabel(null), 'Terminal'));
  });
}
