import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/journey/domain/entities/journey.dart';
import 'package:airport_nav/features/journey/domain/entities/journey_step.dart';
import 'package:airport_nav/features/journey/presentation/providers/journey_providers.dart';
import 'package:airport_nav/features/journey/presentation/screens/journey_steps_screen.dart';

Journey _journey() => Journey(
      stage: JourneyStage.departing,
      currentIndex: 2,
      pinnedNow: DateTime(2026, 7, 31, 10, 3),
      steps: const [
        JourneyStep(kind: StepKind.flight, title: 'Flight', where: 'AA 2468'),
        JourneyStep(kind: StepKind.checkIn, title: 'Check in', where: 'Zone 3'),
        JourneyStep(
          kind: StepKind.security,
          title: 'Head to Security',
          where: 'Lane B',
          queueMinutes: 12,
          walkMinutes: 4,
        ),
        JourneyStep(kind: StepKind.gate, title: 'Gate C18', where: 'Concourse C'),
        JourneyStep(kind: StepKind.boarding, title: 'Boarding', where: 'Group 4'),
      ],
    );

void main() {
  testWidgets('renders every step with its location', (t) async {
    t.view.physicalSize = const Size(375, 1200);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    await t.pumpWidget(ProviderScope(
      overrides: [journeyProvider.overrideWithValue(_journey())],
      child: MaterialApp(
        theme: AppTheme.light,
        home: const JourneyStepsScreen(),
      ),
    ));
    await t.pump(const Duration(milliseconds: 200));

    expect(find.text('Check in'), findsOneWidget);
    expect(find.text('Head to Security'), findsOneWidget);
    expect(find.text('Gate C18'), findsOneWidget);
    expect(find.text('Boarding'), findsOneWidget);
    expect(find.text('NOW'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
