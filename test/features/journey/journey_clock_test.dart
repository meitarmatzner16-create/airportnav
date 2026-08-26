import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/features/journey/domain/journey_clock.dart';
import 'package:airport_nav/features/journey/domain/entities/journey_step.dart';

void main() {
  group('driftedQueue', () {
    test('is deterministic for the same kind and tick', () {
      final a = driftedQueue(StepKind.security, 12, 7);
      final b = driftedQueue(StepKind.security, 12, 7);
      expect(a, b);
    });

    test('stays inside the band for security across many ticks', () {
      for (var tick = 0; tick < 200; tick++) {
        final q = driftedQueue(StepKind.security, 12, tick);
        expect(q, inInclusiveRange(8, 18));
      }
    });

    test('actually varies across ticks', () {
      final values = <int>{
        for (var tick = 0; tick < 40; tick++)
          driftedQueue(StepKind.security, 12, tick),
      };
      expect(values.length, greaterThan(3));
    });

    test('kinds without a queue return the base unchanged', () {
      expect(driftedQueue(StepKind.gate, 0, 11), 0);
      expect(driftedQueue(StepKind.boarding, 0, 11), 0);
      expect(driftedQueue(StepKind.flight, 0, 11), 0);
    });
  });

  group('indexForTick', () {
    test('starts where it is told', () {
      expect(indexForTick(6, 0, startIndex: 1), 1);
    });

    test('advances one step per dwell', () {
      expect(indexForTick(6, kStepDwellTicks - 1, startIndex: 1), 1);
      expect(indexForTick(6, kStepDwellTicks, startIndex: 1), 2);
      expect(indexForTick(6, kStepDwellTicks * 2, startIndex: 1), 3);
    });

    test('clamps at the last step', () {
      expect(indexForTick(6, kStepDwellTicks * 99, startIndex: 1), 5);
    });
  });
}
