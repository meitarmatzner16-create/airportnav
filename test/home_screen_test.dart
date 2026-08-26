import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/home/presentation/home_screen.dart';
import 'package:airport_nav/features/journey/domain/entities/journey.dart';
import 'package:airport_nav/features/journey/domain/entities/journey_step.dart';
import 'package:airport_nav/features/journey/presentation/providers/journey_providers.dart';

Journey _running() => Journey(
      stage: JourneyStage.departing,
      currentIndex: 1,
      pinnedNow: DateTime(2026, 7, 31, 10, 3),
      steps: const [
        JourneyStep(kind: StepKind.flight, title: 'Flight', where: 'x'),
        JourneyStep(
          kind: StepKind.security,
          title: 'Head to Security',
          where: 'Lane B',
          queueMinutes: 12,
        ),
        JourneyStep(kind: StepKind.gate, title: 'Gate C18', where: 'Concourse C'),
      ],
    );

Widget _app({Journey? journey}) => ProviderScope(
      overrides: [journeyProvider.overrideWithValue(journey)],
      child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
    );

void main() {
  testWidgets('asks the question and offers three stages', (tester) async {
    tester.view.physicalSize = const Size(375, 1700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 50));

    expect(tester.takeException(), isNull);
    expect(find.textContaining('What are you doing today'), findsOneWidget);
    expect(find.text('Departing'), findsOneWidget);
    expect(find.text('Connecting'), findsOneWidget);
    expect(find.text('Arrived'), findsOneWidget);
  });

  testWidgets('the active stage card carries live status', (tester) async {
    tester.view.physicalSize = const Size(375, 1700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(journey: _running()));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.textContaining('Head to Security'), findsOneWidget);
    expect(find.text('2 of 3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the airport picker survives the redesign', (tester) async {
    tester.view.physicalSize = const Size(375, 1700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app());
    await tester.pump(const Duration(milliseconds: 50));

    // It is the app's only writer of detectedAirportProvider.
    expect(find.byType(DropdownButton<String>), findsOneWidget);
  });
}
