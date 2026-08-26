import 'entities/journey_step.dart';

/// How often the journey ticks. Every value below is expressed in ticks so the
/// whole simulation is a pure function of a counter - which is what makes it
/// reproducible in a test without a real timer.
const kTickInterval = Duration(seconds: 5);

/// Ticks a traveller spends on one step before the journey advances.
/// 8 ticks = 40 seconds, slow enough to read and fast enough to demo.
const kStepDwellTicks = 8;

/// When the scripted gate change fires. 30 seconds in - late enough that the
/// first screen reads as calm, early enough that nobody misses it.
const kDisruptionTick = 6;

/// Queue bands in minutes, keyed by the steps that actually have a queue.
const _bands = <StepKind, (int, int)>{
  StepKind.checkIn: (3, 9),
  StepKind.bagDrop: (2, 7),
  StepKind.security: (8, 18),
  StepKind.passport: (2, 6),
  StepKind.transfer: (4, 11),
};

/// A queue length that moves but never lies: same tick, same answer.
///
/// Uses a Knuth multiplicative hash rather than Random, because Random with a
/// seed still carries state and a pure function of the tick is what lets a
/// test ask for tick 47 and get the same queue length every run.
int driftedQueue(StepKind kind, int baseMinutes, int tick) {
  final band = _bands[kind];
  if (band == null) return baseMinutes;
  final (low, high) = band;
  final hash = (tick * 2654435761 + kind.index * 40503) & 0x7fffffff;
  return low + (hash % (high - low + 1));
}

/// Which step the traveller is on after [tick] ticks.
int indexForTick(int stepCount, int tick, {int startIndex = 0}) {
  final advanced = startIndex + (tick ~/ kStepDwellTicks);
  return advanced >= stepCount ? stepCount - 1 : advanced;
}
