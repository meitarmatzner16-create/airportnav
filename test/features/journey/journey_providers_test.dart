import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/features/flight/domain/entities/flight.dart';
import 'package:airport_nav/features/flight/presentation/providers/flight_providers.dart';
import 'package:airport_nav/features/journey/domain/entities/journey.dart';
import 'package:airport_nav/features/journey/domain/entities/journey_step.dart';
import 'package:airport_nav/features/journey/presentation/providers/journey_providers.dart';

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

void main() {
  test('journey is null until a stage is chosen', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(journeyProvider), isNull);
  });

  test('choosing departing yields a journey awaiting a flight', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(journeyStageProvider.notifier).state = JourneyStage.departing;
    final j = c.read(journeyProvider);
    expect(j, isNotNull);
    expect(j!.awaitingFlight, isTrue);
  });

  test('selecting a flight builds the full spine', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(journeyStageProvider.notifier).state = JourneyStage.departing;
    c.read(selectedFlightProvider.notifier).state = _flight();
    final j = c.read(journeyProvider)!;
    expect(j.awaitingFlight, isFalse);
    expect(j.steps.length, 6);
    expect(j.currentStep.kind, StepKind.checkIn);
  });

  test('advancing the tick advances the journey', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(journeyStageProvider.notifier).state = JourneyStage.departing;
    c.read(selectedFlightProvider.notifier).state = _flight();
    c.read(journeyTickValueProvider.notifier).state = 8;
    expect(c.read(journeyProvider)!.currentStep.kind, StepKind.bagDrop);
  });

  test('journeyProvider can be overridden with a value', () {
    final fixed = Journey(
      stage: JourneyStage.departing,
      steps: const [
        JourneyStep(kind: StepKind.security, title: 'Security', where: 'Lane B'),
      ],
      currentIndex: 0,
      pinnedNow: DateTime(2026, 7, 31, 10, 3),
    );
    final c = ProviderContainer(
      overrides: [journeyProvider.overrideWithValue(fixed)],
    );
    addTearDown(c.dispose);
    expect(c.read(journeyProvider)!.currentStep.title, 'Security');
  });
}
