import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/flight/domain/entities/flight.dart';
import 'package:airport_nav/features/journey/domain/entities/journey.dart';
import 'package:airport_nav/features/journey/domain/entities/journey_step.dart';
import 'package:airport_nav/features/journey/presentation/providers/journey_providers.dart';
import 'package:airport_nav/features/journey/presentation/screens/journey_screen.dart';
import 'package:airport_nav/features/venues/presentation/providers/venue_providers.dart';

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

Journey _awaiting() => Journey(
      stage: JourneyStage.departing,
      currentIndex: 0,
      pinnedNow: _now,
      steps: const [
        JourneyStep(
          kind: StepKind.flight,
          title: 'Which flight are you on?',
          where: 'Pick it once and the whole journey builds around it.',
        ),
      ],
    );

Journey _running() => Journey(
      stage: JourneyStage.departing,
      flight: _flight(),
      currentIndex: 1,
      pinnedNow: _now,
      steps: [
        const JourneyStep(kind: StepKind.flight, title: 'Flight', where: 'x'),
        JourneyStep(
          kind: StepKind.security,
          title: 'Head to Security',
          where: 'Terminal 4 · Main checkpoint · Lane B',
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
        const JourneyStep(
          kind: StepKind.boarding,
          title: 'Boarding',
          where: 'Gate C18 · Group 4',
        ),
      ],
    );

Widget _app(Journey? journey, {List<Override> extra = const []}) =>
    ProviderScope(
      overrides: [
        journeyProvider.overrideWithValue(journey),
        allVenuesProvider.overrideWithValue(const []),
        ...extra,
      ],
      child: MaterialApp(theme: AppTheme.light, home: const JourneyScreen()),
    );

void main() {
  testWidgets('step one asks which flight and lists departures', (t) async {
    t.view.physicalSize = const Size(375, 1400);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    await t.pumpWidget(_app(_awaiting()));
    await t.pump(const Duration(milliseconds: 200));

    expect(find.text('Which flight are you on?'), findsOneWidget);
    expect(find.text('Flight'), findsWidgets, reason: 'spine label');
    expect(t.takeException(), isNull);
  });

  testWidgets('after a flight it shows the current step and the next one',
      (t) async {
    t.view.physicalSize = const Size(375, 1400);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    await t.pumpWidget(_app(_running()));
    await t.pump(const Duration(milliseconds: 200));

    expect(find.text('Head to Security'), findsOneWidget);
    expect(find.text('THEN'), findsOneWidget);
    expect(find.text('Gate C18'), findsWidgets);
    expect(find.text('AA 2468 · Chicago'), findsOneWidget);
    // The board must stay reachable - travellers change their minds.
    expect(find.text('Change flight ›'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('no change-flight link before a flight is chosen', (t) async {
    t.view.physicalSize = const Size(375, 1400);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    await t.pumpWidget(_app(_awaiting()));
    await t.pump(const Duration(milliseconds: 200));

    expect(find.text('Change flight ›'), findsNothing);
  });

  testWidgets('connecting step one shows the two board columns', (t) async {
    t.view.physicalSize = const Size(375, 1400);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    final awaiting = Journey(
      stage: JourneyStage.connecting,
      currentIndex: 0,
      pinnedNow: _now,
      steps: const [
        JourneyStep(
          kind: StepKind.flight,
          title: 'Which flights connect?',
          where: 'Pick the flight you came in on and the one you leave on.',
        ),
      ],
    );

    await t.pumpWidget(_app(awaiting));
    await t.pump(const Duration(milliseconds: 200));

    expect(find.text('Which flights connect?'), findsOneWidget);
    expect(find.text('I ARRIVED ON'), findsOneWidget);
    expect(find.text('MY NEXT FLIGHT'), findsOneWidget);
    // The authored inbound flights populate the arrivals column.
    expect(find.text('AA 106'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('a running connection can reopen the picker and come back',
      (t) async {
    t.view.physicalSize = const Size(375, 1600);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    final running = Journey(
      stage: JourneyStage.connecting,
      flight: _flight(),
      inboundFlight: _flight(),
      currentIndex: 1,
      pinnedNow: _now,
      steps: const [
        JourneyStep(kind: StepKind.flight, title: 'Flight', where: 'x'),
        JourneyStep(
          kind: StepKind.arrive,
          title: 'Get off and follow Transfers',
          where: 'Terminal 8 · arrivals level',
          walkMinutes: 5,
        ),
        JourneyStep(
          kind: StepKind.gate,
          title: 'Gate C18',
          where: 'Concourse C',
          walkMinutes: 12,
        ),
      ],
    );

    await t.pumpWidget(_app(running));
    await t.pump(const Duration(milliseconds: 200));

    // Mid-journey: step body visible, and the link says flights, plural.
    expect(find.text('Get off and follow Transfers'), findsOneWidget);
    expect(find.text('Change flights ›'), findsOneWidget);

    // Reopen the picker without losing the journey.
    await t.tap(find.text('Change flights ›'));
    await t.pump(const Duration(milliseconds: 200));

    expect(find.text('I ARRIVED ON'), findsOneWidget);
    expect(find.text('MY NEXT FLIGHT'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);

    // Done returns to the running journey untouched.
    await t.tap(find.text('Done'));
    await t.pump(const Duration(milliseconds: 200));

    expect(find.text('Get off and follow Transfers'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('with no journey it invites you to pick a stage', (t) async {
    await t.pumpWidget(_app(null));
    await t.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('What are you doing'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
