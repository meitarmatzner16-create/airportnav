import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/journey/domain/entities/disruption.dart';
import 'package:airport_nav/features/journey/domain/entities/journey_step.dart';
import 'package:airport_nav/features/journey/presentation/providers/journey_providers.dart';
import 'package:airport_nav/features/journey/presentation/widgets/disruption_banner.dart';

const _gateChange = Disruption(
  kind: DisruptionKind.gateChange,
  affectedStep: StepKind.gate,
  headline: 'Gate changed to B14',
  detail: 'Moved from C18. Same concourse, 3 min further.',
  newGate: 'B14',
);

Widget _wrap(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(theme: AppTheme.light, home: Scaffold(body: child)),
    );

void main() {
  testWidgets('shows headline and detail when unacknowledged', (t) async {
    await t.pumpWidget(_wrap(const DisruptionBanner(disruption: _gateChange)));
    await t.pump(const Duration(milliseconds: 50));

    expect(find.text('Gate changed to B14'), findsOneWidget);
    expect(find.textContaining('Same concourse'), findsOneWidget);
  });

  testWidgets('tapping collapses it to the headline only', (t) async {
    await t.pumpWidget(_wrap(const DisruptionBanner(disruption: _gateChange)));
    await t.pump(const Duration(milliseconds: 50));

    await t.tap(find.text('Gate changed to B14'));
    await t.pump(const Duration(milliseconds: 200));

    expect(find.text('Gate changed to B14'), findsOneWidget);
    expect(find.textContaining('Same concourse'), findsNothing);
  });

  testWidgets('stays collapsed when the step is already acknowledged', (t) async {
    await t.pumpWidget(_wrap(
      const DisruptionBanner(disruption: _gateChange),
      overrides: [
        acknowledgedDisruptionsProvider
            .overrideWith((ref) => <StepKind>{StepKind.gate}),
      ],
    ));
    await t.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Same concourse'), findsNothing);
  });
}
