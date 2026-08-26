import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/features/flight/domain/entities/flight.dart';
import 'package:airport_nav/features/journey/domain/entities/journey.dart';
import 'package:airport_nav/features/journey/domain/entities/journey_step.dart';

final _now = DateTime(2026, 7, 31, 10, 3);

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

JourneyStep _step(StepKind kind, {int queue = 0, int walk = 0}) => JourneyStep(
      kind: kind,
      title: kind.name,
      where: 'somewhere',
      queueMinutes: queue,
      walkMinutes: walk,
    );

Journey _journey({int currentIndex = 3}) => Journey(
      stage: JourneyStage.departing,
      flight: _flight(),
      pinnedNow: _now,
      currentIndex: currentIndex,
      steps: [
        _step(StepKind.flight),
        _step(StepKind.checkIn, queue: 6, walk: 3),
        _step(StepKind.bagDrop, queue: 4, walk: 1),
        _step(StepKind.security, queue: 12, walk: 4),
        _step(StepKind.gate, walk: 12),
        _step(StepKind.boarding),
      ],
    );

void main() {
  group('Journey status', () {
    test('statusOf derives from currentIndex alone', () {
      final j = _journey(currentIndex: 3);
      expect(j.statusOf(0), StepStatus.done);
      expect(j.statusOf(2), StepStatus.done);
      expect(j.statusOf(3), StepStatus.current);
      expect(j.statusOf(4), StepStatus.upcoming);
    });

    test('currentStep and nextStep track currentIndex', () {
      final j = _journey(currentIndex: 3);
      expect(j.currentStep.kind, StepKind.security);
      expect(j.nextStep!.kind, StepKind.gate);
    });

    test('nextStep is null on the last step', () {
      expect(_journey(currentIndex: 5).nextStep, isNull);
    });
  });

  group('Journey timing', () {
    test('boarding is 30 minutes before departure', () {
      expect(_journey().boardingTime, DateTime(2026, 7, 31, 10, 50));
    });

    test('gate closes 15 minutes before departure', () {
      expect(_journey().gateClosesAt, DateTime(2026, 7, 31, 11, 5));
    });

    test('projectedGateArrival sums remaining queue and walk from pinnedNow', () {
      // security 12+4, gate 0+12, boarding 0 => 28 minutes from 10:03
      expect(_journey().projectedGateArrival, DateTime(2026, 7, 31, 10, 31));
    });

    test('freeTime is boarding minus projected arrival', () {
      expect(_journey().freeTime, const Duration(minutes: 19));
    });

    test('freeTime goes negative when the queues eat the buffer', () {
      final j = _journey().copyWith(steps: [
        _step(StepKind.flight),
        _step(StepKind.checkIn),
        _step(StepKind.bagDrop),
        _step(StepKind.security, queue: 45, walk: 4),
        _step(StepKind.gate, walk: 12),
        _step(StepKind.boarding),
      ]);
      expect(j.freeTime!.isNegative, isTrue);
      expect(j.freeTime, const Duration(minutes: -14));
    });

    test('timings are null before a flight is chosen', () {
      final j = _journey(currentIndex: 0).copyWith(clearFlight: true);
      expect(j.boardingTime, isNull);
      expect(j.freeTime, isNull);
    });
  });
}
