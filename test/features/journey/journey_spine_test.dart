import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/journey/domain/entities/journey.dart';
import 'package:airport_nav/features/journey/domain/entities/journey_step.dart';
import 'package:airport_nav/features/journey/presentation/widgets/journey_spine.dart';

JourneyStep _s(StepKind k) => JourneyStep(kind: k, title: k.name, where: 'x');

Journey _journey({required int steps, int currentIndex = 2}) => Journey(
      stage: JourneyStage.departing,
      currentIndex: currentIndex,
      pinnedNow: DateTime(2026, 7, 31, 10, 3),
      steps: [
        for (final k in [
          StepKind.flight,
          StepKind.checkIn,
          StepKind.bagDrop,
          StepKind.security,
          StepKind.passport,
          StepKind.gate,
          StepKind.boarding,
        ].take(steps))
          _s(k),
      ],
    );

Widget _wrap(Widget child) =>
    MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

void main() {
  testWidgets('renders one label per step, not a fixed six', (t) async {
    await t.pumpWidget(_wrap(JourneySpine(journey: _journey(steps: 7))));
    await t.pump(const Duration(milliseconds: 50));

    expect(find.text('Flight'), findsOneWidget);
    expect(find.text('Passport'), findsOneWidget);
    expect(find.text('Board'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('a five-step spine renders five labels', (t) async {
    await t.pumpWidget(_wrap(JourneySpine(journey: _journey(steps: 5))));
    await t.pump(const Duration(milliseconds: 50));

    expect(find.text('Passport'), findsOneWidget);
    expect(find.text('Gate'), findsNothing);
    expect(find.text('Security'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('every dot is its own tap target, reporting its index',
      (t) async {
    final tapped = <int>[];
    await t.pumpWidget(_wrap(JourneySpine(
      journey: _journey(steps: 6),
      onStepTap: tapped.add,
    )));
    await t.pump(const Duration(milliseconds: 50));

    // The Flight dot - the traveller's way back to the board.
    await t.tap(find.text('Flight'));
    await t.pump(const Duration(milliseconds: 50));
    expect(tapped, [0]);

    await t.tap(find.text('Security'));
    await t.pump(const Duration(milliseconds: 50));
    expect(tapped, [0, 3]);
  });

  testWidgets('fits a narrow phone without overflowing', (t) async {
    t.view.physicalSize = const Size(320, 800);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    await t.pumpWidget(_wrap(JourneySpine(journey: _journey(steps: 7))));
    await t.pump(const Duration(milliseconds: 50));

    expect(t.takeException(), isNull);
  });
}
