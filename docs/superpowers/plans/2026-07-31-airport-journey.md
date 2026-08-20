# Airport Journey Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn Home into a stage chooser and add a journey page that walks a traveller from choosing their flight through check-in, bag drop, security, gate and boarding - with live queue times, a free-time calculation, and one scripted disruption.

**Architecture:** A pure-Dart `Journey` value object holds an ordered `List<JourneyStep>` plus a `currentIndex` and a `pinnedNow` clock. All progress state is derived from `currentIndex`, never stored twice. A single `.autoDispose` provider owns the only `Timer` in the feature and rebuilds the Journey from a tick count, so every widget test can replace the whole thing with `journeyProvider.overrideWithValue(...)` and never start a timer.

**Tech Stack:** Flutter (Dart 3.11), Riverpod 2.6, go_router 14.8. Existing design tokens: `AppColors`, `AppSpacing`, `AppTypography`, `AppShadows`.

## Global Constraints

- **Visible copy uses hyphen-minus `-` only.** No em dashes, no en dashes. Applies to every user-facing string and every code comment.
- **Do not reproduce airline logo artwork.** Airline identity is the brand-coloured IATA tile via the existing `AirlineTile` widget.
- **Tokens only.** No ad-hoc `Color(0x…)` or raw pixel sizes in feature code. Read from `AppColors` / `AppSpacing` / `AppShadows` / `AppTypography`.
- **Card recipe.** Shadow goes on the OUTER `Container` (`boxShadow: isDark ? null : AppShadows.card`, `border: isDark ? Border.all(color: hairline) : null`), with `Material(color: Colors.transparent, clipBehavior: Clip.antiAlias)` + `InkWell` inside. An `Ink` decoration paints into the parent Material canvas and squares off the corners.
- **Amber is shapes, strokes and dots only.** `AppColors.amber` on paper is ~1.8:1. Any amber that carries text uses `AppColors.amberText`.
- **Compare flights by `flight.id`.** `Flight` has no `==` / `hashCode`.
- **Test imports are absolute:** `package:airport_nav/…`, never relative.
- **No `pumpAndSettle` on any journey screen.** A periodic ticker schedules a frame forever and `pumpAndSettle` times out. Use `await t.pump(const Duration(milliseconds: 200))`.
- **Every widget test that builds a journey screen must override `journeyProvider`.** A test that does not will start a real 5-second timer and fail with "A Timer is still pending even after the widget tree was disposed".
- **Commit message trailer**, on every commit in this plan:
  `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`

## Regression Gate

"All 112 existing tests still pass" is **not** the gate and must not be claimed. These tests are deliberately retired in Task 14 because they import widgets that are being deleted:

| File | Why it goes |
| --- | --- |
| `test/features/home/home_density_test.dart` | imports `quick_start_section.dart` and `upcoming_flight_card.dart` |
| `test/home_sections_test.dart` | imports `upcoming_flight_card.dart` |

`test/home_screen_test.dart` and `test/app_shell_test.dart` are **rewritten**, not deleted. The gate is: those four files handled deliberately, every other existing test green, plus the new tests in this plan.

---

## File Structure

**New feature - `lib/features/journey/`**

| File | Responsibility |
| --- | --- |
| `domain/entities/journey_step.dart` | `StepKind`, `StepStatus`, `JourneyStep` |
| `domain/entities/disruption.dart` | `DisruptionKind`, `Disruption` |
| `domain/entities/journey.dart` | `JourneyStage`, `Journey` + all derived getters |
| `domain/journey_clock.dart` | Deterministic queue drift and step advancement from a tick count |
| `data/journey_mock.dart` | Authored step content per airport; builds a `Journey` from a `Flight` |
| `presentation/providers/journey_providers.dart` | `journeyStageProvider`, `journeyTickProvider`, `journeyProvider`, `acknowledgedDisruptionsProvider` |
| `presentation/widgets/journey_spine.dart` | The always-visible dot spine |
| `presentation/widgets/current_step_card.dart` | "Do this now" hero + the quiet "Then" card |
| `presentation/widgets/free_time_strip.dart` | "You'll have N free minutes" + venue tiles |
| `presentation/widgets/disruption_banner.dart` | Gate change / queue spike takeover |
| `presentation/screens/journey_screen.dart` | Spine + body-per-step |
| `presentation/screens/journey_steps_screen.dart` | Full vertical timeline |

**Modified**

| File | Change |
| --- | --- |
| `lib/features/flight/domain/entities/flight.dart` | add `copyWith` |
| `lib/features/flight/data/datasources/flight_mock_datasource.dart` | add connecting inbound flights (Task 15) |
| `lib/features/home/presentation/home_screen.dart` | rebuilt as the stage chooser |
| `lib/features/home/presentation/widgets/stage_card.dart` | **new** - the three Home cards |
| `lib/core/router/app_router.dart` | `/journey`, `/journey/steps`, `/trip`; `/flights` becomes `builder:` |
| `lib/core/widgets/app_shell.dart` | tab index 3 becomes Trip |

**Deleted** (Task 14)

`home_hero_banner.dart`, `home_search_bar.dart`, `quick_start_section.dart`, `upcoming_flight_card.dart`, `live_departures_section.dart`, and the two test files named in the Regression Gate.

---

## Task 1: Journey domain types

**Files:**
- Create: `lib/features/journey/domain/entities/journey_step.dart`
- Create: `lib/features/journey/domain/entities/disruption.dart`
- Create: `lib/features/journey/domain/entities/journey.dart`
- Test: `test/features/journey/journey_test.dart`

**Interfaces:**
- Consumes: `Flight` from `lib/features/flight/domain/entities/flight.dart`
- Produces: `StepKind`, `StepStatus`, `JourneyStep`, `DisruptionKind`, `Disruption`, `JourneyStage`, `Journey`. Every later task depends on these exact names.

- [ ] **Step 1: Write the failing test**

Create `test/features/journey/journey_test.dart`:

```dart
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/journey/journey_test.dart`
Expected: FAIL - `Target of URI doesn't exist: 'package:airport_nav/features/journey/domain/entities/journey.dart'`

- [ ] **Step 3: Create `journey_step.dart`**

```dart
/// One gate a traveller has to pass. The airport prints this information on a
/// wall; the app's job is to carry it.
enum StepKind {
  flight,
  checkIn,
  bagDrop,
  security,
  passport,
  gate,
  boarding,
  arrive,
  transfer,
}

/// Derived from Journey.currentIndex - never stored on a step.
enum StepStatus { done, current, upcoming }

extension StepKindX on StepKind {
  /// Short label for the spine. Kept tight so six fit across a phone.
  String get short => switch (this) {
        StepKind.flight => 'Flight',
        StepKind.checkIn => 'Check-in',
        StepKind.bagDrop => 'Bags',
        StepKind.security => 'Security',
        StepKind.passport => 'Passport',
        StepKind.gate => 'Gate',
        StepKind.boarding => 'Board',
        StepKind.arrive => 'Arrive',
        StepKind.transfer => 'Transfer',
      };
}

class JourneyStep {
  final StepKind kind;
  final String title;
  final String where;
  final String? note;
  final DateTime? deadline;
  final int queueMinutes;
  final int walkMinutes;
  final DateTime? completedAt;

  const JourneyStep({
    required this.kind,
    required this.title,
    required this.where,
    this.note,
    this.deadline,
    this.queueMinutes = 0,
    this.walkMinutes = 0,
    this.completedAt,
  });

  /// What this step costs the traveller in minutes.
  int get totalMinutes => queueMinutes + walkMinutes;

  JourneyStep copyWith({
    int? queueMinutes,
    int? walkMinutes,
    String? where,
    DateTime? completedAt,
  }) =>
      JourneyStep(
        kind: kind,
        title: title,
        where: where ?? this.where,
        note: note,
        deadline: deadline,
        queueMinutes: queueMinutes ?? this.queueMinutes,
        walkMinutes: walkMinutes ?? this.walkMinutes,
        completedAt: completedAt ?? this.completedAt,
      );
}
```

- [ ] **Step 4: Create `disruption.dart`**

```dart
import 'journey_step.dart';

enum DisruptionKind { gateChange, queueSpike, boardingEarly, laneClosed }

/// A change the airport would announce over a speaker you may not hear.
///
/// [affectedStep] is what lets the UI collapse an acknowledged banner and keep
/// it collapsed until that step is done. Acknowledgement itself is provider
/// state, not a field here - this object stays immutable and comparable.
class Disruption {
  final DisruptionKind kind;
  final StepKind affectedStep;
  final String headline;
  final String detail;

  /// Set only when [kind] is [DisruptionKind.gateChange].
  final String? newGate;

  const Disruption({
    required this.kind,
    required this.affectedStep,
    required this.headline,
    required this.detail,
    this.newGate,
  });
}
```

- [ ] **Step 5: Create `journey.dart`**

```dart
import '../../../flight/domain/entities/flight.dart';
import 'disruption.dart';
import 'journey_step.dart';

enum JourneyStage { departing, connecting }

/// Boarding and gate-close are derived here and nowhere else. Three different
/// offsets used to exist across the app; this is the single source.
const kBoardingLead = Duration(minutes: 30);
const kGateCloseLead = Duration(minutes: 15);

/// An ordered walk through the airport, pinned to one moment in time.
///
/// [pinnedNow] is frozen when the journey is created and never re-read from the
/// system clock. The mock flight datasource rebuilds every departure relative
/// to DateTime.now() on every call, so a journey that re-read the repository
/// would have a departure time that never got any closer.
class Journey {
  final JourneyStage stage;
  final Flight? flight;
  final Flight? inboundFlight;
  final List<JourneyStep> steps;
  final int currentIndex;
  final DateTime pinnedNow;
  final Disruption? disruption;

  const Journey({
    required this.stage,
    required this.steps,
    required this.currentIndex,
    required this.pinnedNow,
    this.flight,
    this.inboundFlight,
    this.disruption,
  });

  StepStatus statusOf(int i) {
    if (i < currentIndex) return StepStatus.done;
    if (i == currentIndex) return StepStatus.current;
    return StepStatus.upcoming;
  }

  JourneyStep get currentStep => steps[currentIndex];

  JourneyStep? get nextStep =>
      currentIndex + 1 < steps.length ? steps[currentIndex + 1] : null;

  bool get awaitingFlight => currentStep.kind == StepKind.flight;

  bool get isAtGate => currentStep.kind == StepKind.boarding;

  DateTime? get boardingTime =>
      flight == null ? null : flight!.departureTime.subtract(kBoardingLead);

  DateTime? get gateClosesAt =>
      flight == null ? null : flight!.departureTime.subtract(kGateCloseLead);

  /// Minutes still to be spent queueing and walking, from the current step on.
  Duration get remainingProcessTime => Duration(
        minutes: steps
            .skip(currentIndex)
            .fold<int>(0, (sum, s) => sum + s.totalMinutes),
      );

  DateTime get projectedGateArrival => pinnedNow.add(remainingProcessTime);

  /// The number no sign in the building can give you. Negative means behind.
  Duration? get freeTime => boardingTime == null
      ? null
      : boardingTime!.difference(projectedGateArrival);

  /// Honours a gate-change disruption so the banner and the cards never
  /// disagree about which gate you are walking to.
  String get effectiveGate =>
      disruption?.newGate ?? flight?.gate ?? '-';

  Journey copyWith({
    JourneyStage? stage,
    Flight? flight,
    Flight? inboundFlight,
    List<JourneyStep>? steps,
    int? currentIndex,
    DateTime? pinnedNow,
    Disruption? disruption,
    bool clearFlight = false,
    bool clearDisruption = false,
  }) =>
      Journey(
        stage: stage ?? this.stage,
        flight: clearFlight ? null : (flight ?? this.flight),
        inboundFlight: inboundFlight ?? this.inboundFlight,
        steps: steps ?? this.steps,
        currentIndex: currentIndex ?? this.currentIndex,
        pinnedNow: pinnedNow ?? this.pinnedNow,
        disruption:
            clearDisruption ? null : (disruption ?? this.disruption),
      );
}
```

- [ ] **Step 6: Run the test to verify it passes**

Run: `flutter test test/features/journey/journey_test.dart`
Expected: PASS - 8 tests

- [ ] **Step 7: Commit**

```bash
git add lib/features/journey/domain test/features/journey/journey_test.dart
git commit -m "feat(journey): domain model for the airport journey

Journey holds an ordered list of steps plus a currentIndex and a pinned
clock. Status is derived from currentIndex rather than stored on each step,
so the two can never disagree. Boarding and gate-close offsets live here and
nowhere else - three different derivations existed across the app before.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 2: Flight.copyWith

**Files:**
- Modify: `lib/features/flight/domain/entities/flight.dart`
- Test: `test/features/journey/flight_copy_test.dart`

**Interfaces:**
- Produces: `Flight.copyWith({String? gate, String? status, int? delayMinutes})`. Task 5 needs it to apply a gate change without mutating the mock repository.

- [ ] **Step 1: Write the failing test**

Create `test/features/journey/flight_copy_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/features/flight/domain/entities/flight.dart';

void main() {
  test('copyWith replaces the gate and leaves everything else alone', () {
    final f = Flight(
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

    final moved = f.copyWith(gate: 'B14');

    expect(moved.gate, 'B14');
    expect(moved.id, 'fl-003');
    expect(moved.flightNumber, 'AA 2468');
    expect(moved.terminal, '4');
    expect(moved.departureTime, f.departureTime);
    expect(f.gate, 'C18', reason: 'original must be untouched');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/journey/flight_copy_test.dart`
Expected: FAIL - `The method 'copyWith' isn't defined for the type 'Flight'`

- [ ] **Step 3: Add `copyWith` to `Flight`**

Insert immediately after the `Flight` constructor in `lib/features/flight/domain/entities/flight.dart`:

```dart
  /// A gate change has to be applied somewhere. The mock repository rebuilds
  /// its list on every call, so the journey holds a modified copy instead.
  Flight copyWith({
    String? gate,
    String? terminal,
    String? status,
    int? delayMinutes,
  }) =>
      Flight(
        id: id,
        flightNumber: flightNumber,
        airline: airline,
        airlineLogo: airlineLogo,
        departureAirport: departureAirport,
        departureCity: departureCity,
        arrivalAirport: arrivalAirport,
        arrivalCity: arrivalCity,
        departureTime: departureTime,
        arrivalTime: arrivalTime,
        status: status ?? this.status,
        gate: gate ?? this.gate,
        terminal: terminal ?? this.terminal,
        delayMinutes: delayMinutes ?? this.delayMinutes,
      );
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/journey/flight_copy_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/flight/domain/entities/flight.dart test/features/journey/flight_copy_test.dart
git commit -m "feat(flight): add copyWith

A gate-change disruption has to change a gate somewhere. The mock repository
rebuilds its whole list on every call, so there is nothing to mutate - the
journey carries a modified copy instead.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 3: Deterministic clock

**Files:**
- Create: `lib/features/journey/domain/journey_clock.dart`
- Test: `test/features/journey/journey_clock_test.dart`

**Interfaces:**
- Consumes: `StepKind` from Task 1
- Produces: `kTickInterval`, `kStepDwellTicks`, `kDisruptionTick`, `driftedQueue(StepKind, int baseMinutes, int tick)`, `indexForTick(int stepCount, int tick, {int startIndex})`

- [ ] **Step 1: Write the failing test**

Create `test/features/journey/journey_clock_test.dart`:

```dart
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/journey/journey_clock_test.dart`
Expected: FAIL - `Target of URI doesn't exist: '.../journey_clock.dart'`

- [ ] **Step 3: Create `journey_clock.dart`**

```dart
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
/// seed still carries state and the workflow scripts that generate this data
/// cannot call DateTime.now() or Math.random().
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
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/journey/journey_clock_test.dart`
Expected: PASS - 7 tests

- [ ] **Step 5: Commit**

```bash
git add lib/features/journey/domain/journey_clock.dart test/features/journey/journey_clock_test.dart
git commit -m "feat(journey): deterministic queue drift and step advance

The whole simulation is a pure function of a tick counter, so a test can ask
for tick 47 and get the same queue length every run. No Random, no clock
reads, no timer - those all live in the provider layer.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 4: Departing journey mock

**Files:**
- Create: `lib/features/journey/data/journey_mock.dart`
- Test: `test/features/journey/journey_mock_test.dart`

**Interfaces:**
- Consumes: `Journey`, `JourneyStep`, `StepKind`, `JourneyStage`, `Flight`, `driftedQueue`, `indexForTick`
- Produces: `buildDepartingJourney({required DateTime pinnedNow, Flight? flight, int tick = 0})`, `terminalLabel(String? terminal)`

- [ ] **Step 1: Write the failing test**

Create `test/features/journey/journey_mock_test.dart`:

```dart
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/journey/journey_mock_test.dart`
Expected: FAIL - `Target of URI doesn't exist: '.../journey_mock.dart'`

- [ ] **Step 3: Create `journey_mock.dart`**

```dart
import '../../flight/domain/entities/flight.dart';
import '../domain/entities/disruption.dart';
import '../domain/entities/journey.dart';
import '../domain/entities/journey_step.dart';
import '../domain/journey_clock.dart';

/// The mock flight data mixes bare numbers ('4') with written names
/// ('Tom Bradley International'). Never build a label as 'T$terminal' - that
/// produces "TTom Bradley International", a bug already shipped elsewhere.
String terminalLabel(String? terminal) {
  if (terminal == null || terminal.isEmpty) return 'Terminal';
  final bare = int.tryParse(terminal.trim());
  return bare == null ? terminal : 'Terminal $terminal';
}

/// Gate the scripted disruption moves the traveller to.
const _kMovedGate = 'B14';

JourneyStep _flightStep() => const JourneyStep(
      kind: StepKind.flight,
      title: 'Which flight are you on?',
      where: 'Pick it once and the whole journey builds around it.',
    );

/// Builds the departing spine. Everything is authored - queue bands, desk
/// zones, lane names - because no airport publishes this and the app is a
/// prototype. [tick] drives queue drift, step advance and the disruption.
Journey buildDepartingJourney({
  required DateTime pinnedNow,
  Flight? flight,
  int tick = 0,
}) {
  if (flight == null) {
    return Journey(
      stage: JourneyStage.departing,
      steps: [_flightStep()],
      currentIndex: 0,
      pinnedNow: pinnedNow,
    );
  }

  final term = terminalLabel(flight.terminal);
  final disrupted = tick >= kDisruptionTick;
  final gate = disrupted ? _kMovedGate : (flight.gate ?? '-');

  final steps = <JourneyStep>[
    _flightStep(),
    JourneyStep(
      kind: StepKind.checkIn,
      title: 'Check in',
      where: '$term · Zone 3, desks 301-318',
      note: '${flight.airline} counters',
      deadline: flight.departureTime.subtract(const Duration(minutes: 60)),
      queueMinutes: driftedQueue(StepKind.checkIn, 6, tick),
      walkMinutes: 3,
    ),
    JourneyStep(
      kind: StepKind.bagDrop,
      title: 'Drop your bag',
      where: '$term · same zone, desks 314-318',
      note: 'Closes 60 min before departure',
      deadline: flight.departureTime.subtract(const Duration(minutes: 60)),
      queueMinutes: driftedQueue(StepKind.bagDrop, 4, tick),
      walkMinutes: 1,
    ),
    JourneyStep(
      kind: StepKind.security,
      title: 'Head to Security',
      where: '$term · Main checkpoint · Lane B',
      note: 'Fast Track open - your ticket qualifies',
      deadline: flight.departureTime.subtract(const Duration(minutes: 45)),
      queueMinutes: driftedQueue(StepKind.security, 12, tick),
      walkMinutes: 4,
    ),
    JourneyStep(
      kind: StepKind.gate,
      title: 'Gate $gate',
      where: '$term · Concourse ${gate.isEmpty ? '-' : gate[0]}',
      note: 'Walk time from the security exit',
      deadline: flight.departureTime.subtract(kBoardingLead),
      walkMinutes: _walkToGate(gate),
    ),
    JourneyStep(
      kind: StepKind.boarding,
      title: 'Boarding',
      where: 'Gate $gate · Group 4',
      note: 'Gate closes 15 min before departure',
      deadline: flight.departureTime.subtract(kGateCloseLead),
    ),
  ];

  return Journey(
    stage: JourneyStage.departing,
    flight: flight,
    steps: steps,
    // Step one is answered the moment a flight exists, so progress starts at 1.
    currentIndex: indexForTick(steps.length, tick, startIndex: 1),
    pinnedNow: pinnedNow,
    disruption: disrupted
        ? Disruption(
            kind: DisruptionKind.gateChange,
            affectedStep: StepKind.gate,
            headline: 'Gate changed to $_kMovedGate',
            detail: 'Moved from ${flight.gate ?? '-'}. Same concourse, 3 min further.',
            newGate: _kMovedGate,
          )
        : null,
  );
}

/// Rough gate-to-walk estimate. Near concourses are closer than far ones.
int _walkToGate(String gate) {
  if (gate.isEmpty) return 10;
  return switch (gate[0].toUpperCase()) {
    'A' => 8,
    'B' => 10,
    'C' => 12,
    'D' => 14,
    _ => 12,
  };
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/journey/journey_mock_test.dart`
Expected: PASS - 8 tests

- [ ] **Step 5: Commit**

```bash
git add lib/features/journey/data test/features/journey/journey_mock_test.dart
git commit -m "feat(journey): authored departing spine with drifting queues

Six steps from choosing a flight to boarding, with the zone, lane and desk
numbers an airport only ever prints on a wall. A scripted gate change fires
at tick 6 and moves the gate everywhere at once via effectiveGate.

terminalLabel exists because the mock data mixes bare numbers with written
names, and the naive 'T\$terminal' pattern yields 'TTom Bradley International'.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 5: Journey providers

**Files:**
- Create: `lib/features/journey/presentation/providers/journey_providers.dart`
- Test: `test/features/journey/journey_providers_test.dart`

**Interfaces:**
- Consumes: `buildDepartingJourney`, `kTickInterval`, `selectedFlightProvider` (a `StateProvider<Flight?>` in `lib/features/flight/presentation/providers/flight_providers.dart`)
- Produces: `journeyStageProvider` (`StateProvider<JourneyStage?>`), `journeyTickProvider` (`AutoDisposeProvider<int>` fed by a `StateProvider<int>` `journeyTickValueProvider`), `journeyProvider` (`Provider<Journey?>`), `acknowledgedDisruptionsProvider` (`StateProvider<Set<StepKind>>`)

**Critical:** `journeyProvider` must be a plain `Provider<Journey?>`. `overrideWithValue` does not compile on `StateProvider` or `StreamProvider`, and it is the only override form used anywhere in this suite.

- [ ] **Step 1: Write the failing test**

Create `test/features/journey/journey_providers_test.dart`:

```dart
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/journey/journey_providers_test.dart`
Expected: FAIL - `Target of URI doesn't exist: '.../journey_providers.dart'`

- [ ] **Step 3: Create `journey_providers.dart`**

```dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../flight/presentation/providers/flight_providers.dart';
import '../../data/journey_mock.dart';
import '../../domain/entities/journey.dart';
import '../../domain/entities/journey_step.dart';
import '../../domain/journey_clock.dart';

/// Which stage the traveller told us they are in. Null means Home has not been
/// answered yet - the app deliberately cannot infer this from a flight.
final journeyStageProvider = StateProvider<JourneyStage?>((ref) => null);

/// The raw tick counter. Kept separate from the timer so tests can set it.
final journeyTickValueProvider = StateProvider<int>((ref) => 0);

/// The only Timer in this feature.
///
/// It lives in an autoDispose provider body with ref.onDispose, never in a
/// widget's initState. The splash screen broke this suite exactly once by
/// leaking a timer, and its header comment still documents the fix.
///
/// Nothing at app scope watches this. test/widget_test.dart pumps a const
/// ProviderScope that cannot take overrides, and it survives only because the
/// app starts at /splash and never builds a journey screen.
final journeyTickerProvider = AutoDisposeProvider<void>((ref) {
  final timer = Timer.periodic(kTickInterval, (_) {
    ref.read(journeyTickValueProvider.notifier).update((t) => t + 1);
  });
  ref.onDispose(timer.cancel);
});

/// The moment the journey was pinned to.
///
/// FlightMockDatasource rebuilds every departureTime relative to DateTime.now()
/// on every single call, so a journey that re-read the repository would have a
/// departure that never got closer. This is read once, when the stage is first
/// chosen, and never again.
final journeyEpochProvider = Provider<DateTime>((ref) => DateTime.now());

/// A plain Provider so widget tests can call overrideWithValue on it.
/// StateProvider and StreamProvider do not support that form.
final journeyProvider = Provider<Journey?>((ref) {
  final stage = ref.watch(journeyStageProvider);
  if (stage == null) return null;

  final tick = ref.watch(journeyTickValueProvider);
  final flight = ref.watch(selectedFlightProvider);
  final pinnedNow = ref.watch(journeyEpochProvider);

  return switch (stage) {
    JourneyStage.departing =>
      buildDepartingJourney(pinnedNow: pinnedNow, flight: flight, tick: tick),
    // Connecting arrives in Task 15.
    JourneyStage.connecting =>
      buildDepartingJourney(pinnedNow: pinnedNow, flight: flight, tick: tick),
  };
});

/// Disruptions the traveller has acknowledged, keyed by the step they affect.
/// Acknowledgement lives here rather than on the immutable Disruption so it
/// survives rebuilds and clears when the affected step completes.
final acknowledgedDisruptionsProvider =
    StateProvider<Set<StepKind>>((ref) => <StepKind>{});
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/journey/journey_providers_test.dart`
Expected: PASS - 5 tests

- [ ] **Step 5: Commit**

```bash
git add lib/features/journey/presentation/providers test/features/journey/journey_providers_test.dart
git commit -m "feat(journey): providers, with the only timer in the feature

journeyProvider is a plain Provider so overrideWithValue compiles - the only
override form this suite uses. The timer lives in an autoDispose body with
ref.onDispose, never in initState, and nothing at app scope watches it.

The epoch is pinned once: the mock datasource rebuilds every departure time
relative to DateTime.now() on every call, so re-reading it per tick would
give a departure that never gets closer.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 6: JourneySpine widget

**Files:**
- Create: `lib/features/journey/presentation/widgets/journey_spine.dart`
- Test: `test/features/journey/journey_spine_test.dart`

**Interfaces:**
- Consumes: `Journey`, `StepStatus`, `StepKindX.short`
- Produces: `JourneySpine({required Journey journey, VoidCallback? onTap})`

Renders `journey.steps.length` dots - never a hard-coded six, because departing (6), connecting (6) and an international spine with passport (7) all coexist.

- [ ] **Step 1: Write the failing test**

Create `test/features/journey/journey_spine_test.dart`:

```dart
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

    expect(find.text('Passport'), findsNothing);
    expect(find.text('Security'), findsOneWidget);
    expect(t.takeException(), isNull);
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/journey/journey_spine_test.dart`
Expected: FAIL - `Target of URI doesn't exist: '.../journey_spine.dart'`

- [ ] **Step 3: Create `journey_spine.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/journey.dart';
import '../../domain/entities/journey_step.dart';

/// Where you are in the airport, at a glance.
///
/// Amber marks the path already walked - the brand's wayfinding accent, used
/// as a shape only. Sky marks where you are now. Renders one dot per step,
/// so a spine with passport control is simply longer.
class JourneySpine extends StatelessWidget {
  final Journey journey;
  final VoidCallback? onTap;

  const JourneySpine({super.key, required this.journey, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final track = isDark ? AppColors.dHairline : AppColors.hairlineCool;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final sky = isDark ? AppColors.dSky : AppColors.sky;

    return Semantics(
      label: 'Step ${journey.currentIndex + 1} of ${journey.steps.length}',
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < journey.steps.length; i++)
                Expanded(
                  child: _SpineStep(
                    label: journey.steps[i].kind.short,
                    status: journey.statusOf(i),
                    isLast: i == journey.steps.length - 1,
                    track: track,
                    muted: muted,
                    sky: sky,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpineStep extends StatelessWidget {
  final String label;
  final StepStatus status;
  final bool isLast;
  final Color track;
  final Color muted;
  final Color sky;

  const _SpineStep({
    required this.label,
    required this.status,
    required this.isLast,
    required this.track,
    required this.muted,
    required this.sky,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrent = status == StepStatus.current;
    final isDone = status == StepStatus.done;
    final dotSize = isCurrent ? 13.0 : 11.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 16,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Connector, drawn behind the dot and only to the right.
              if (!isLast)
                Positioned(
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      const Spacer(),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isDone ? AppColors.amber : track,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppColors.amber
                      : isCurrent
                          ? sky
                          : track,
                  border: isCurrent
                      ? Border.all(color: sky.withValues(alpha: 0.25), width: 3)
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isCurrent ? sky : muted,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/journey/journey_spine_test.dart`
Expected: PASS - 3 tests

- [ ] **Step 5: Commit**

```bash
git add lib/features/journey/presentation/widgets/journey_spine.dart test/features/journey/journey_spine_test.dart
git commit -m "feat(journey): the progress spine

One dot per step, so departing, connecting and an international spine with
passport control all render correctly. Amber marks the path already walked -
shape only, never text, since amber on paper is 1.8:1.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 7: Journey body cards

**Files:**
- Create: `lib/features/journey/presentation/widgets/current_step_card.dart`
- Create: `lib/features/journey/presentation/widgets/free_time_strip.dart`
- Test: `test/features/journey/journey_cards_test.dart`

**Interfaces:**
- Consumes: `Journey`, `JourneyStep`, `Venue` (`lib/features/venues/domain/entities/venue.dart`, which carries `walkMinutes` as an `int` and `avgVisitMinutes` as an `int?`)
- Produces: `CurrentStepCard({required Journey journey})`, `ThenCard({required JourneyStep step, required String gate})`, `FreeTimeStrip({required Duration? freeTime, required List<Venue> venues})`, `int venueCostMinutes(Venue)`, `int defaultDwellFor(String category)`

**Free-time arithmetic.** Only 10 venues carry authored walk times; the rest get a hash-derived 2-12 minutes, and `avgVisitMinutes` is null for every venue outside that catalog. Cost is therefore `2 * walkMinutes + (avgVisitMinutes ?? defaultDwellFor(category))` - the return leg counts, and a null dwell falls back to a per-category default rather than silently becoming walk-only.

- [ ] **Step 1: Write the failing test**

Create `test/features/journey/journey_cards_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/flight/domain/entities/flight.dart';
import 'package:airport_nav/features/journey/domain/entities/journey.dart';
import 'package:airport_nav/features/journey/domain/entities/journey_step.dart';
import 'package:airport_nav/features/journey/presentation/widgets/current_step_card.dart';
import 'package:airport_nav/features/journey/presentation/widgets/free_time_strip.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

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

Journey _journey() => Journey(
      stage: JourneyStage.departing,
      flight: _flight(),
      currentIndex: 1,
      pinnedNow: DateTime(2026, 7, 31, 10, 3),
      steps: [
        const JourneyStep(kind: StepKind.flight, title: 'Flight', where: 'x'),
        JourneyStep(
          kind: StepKind.security,
          title: 'Head to Security',
          where: 'Terminal 4 · Main checkpoint · Lane B',
          note: 'Fast Track open - your ticket qualifies',
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
      ],
    );

Venue _venue({
  required String id,
  required String name,
  required int walk,
  int? visit,
  String category = 'dining',
}) =>
    Venue(
      id: id,
      name: name,
      category: category,
      style: 'casual',
      airportCode: 'JFK',
      terminal: '4',
      floor: 1,
      location: 'Concourse C',
      rating: 4.4,
      openingHours: '24h',
      description: 'x',
      type: VenueType.shop,
      walkMinutes: walk,
      avgVisitMinutes: visit,
    );

void main() {
  group('CurrentStepCard', () {
    testWidgets('shows where, the note and the three stats', (t) async {
      await t.pumpWidget(_wrap(CurrentStepCard(journey: _journey())));
      await t.pump(const Duration(milliseconds: 50));

      expect(find.text('Head to Security'), findsOneWidget);
      expect(find.text('Terminal 4 · Main checkpoint · Lane B'), findsOneWidget);
      expect(find.textContaining('Fast Track'), findsOneWidget);
      expect(find.text('12 min'), findsOneWidget);
      expect(find.text('4 min'), findsOneWidget);
      expect(find.text('Queue'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('omits the queue stat when there is no queue', (t) async {
      final j = _journey().copyWith(steps: [
        const JourneyStep(kind: StepKind.flight, title: 'Flight', where: 'x'),
        const JourneyStep(
          kind: StepKind.gate,
          title: 'Gate C18',
          where: 'Concourse C',
          walkMinutes: 12,
        ),
      ]);
      await t.pumpWidget(_wrap(CurrentStepCard(journey: j)));
      await t.pump(const Duration(milliseconds: 50));

      expect(find.text('Queue'), findsNothing);
      expect(find.text('Walk'), findsOneWidget);
    });
  });

  group('venueCostMinutes', () {
    test('counts the walk both ways plus the visit', () {
      expect(venueCostMinutes(_venue(id: 'a', name: 'A', walk: 4, visit: 20)), 28);
    });

    test('falls back to a category dwell when the visit is unknown', () {
      final v = _venue(id: 'b', name: 'B', walk: 3, category: 'lounge');
      expect(v.avgVisitMinutes, isNull);
      expect(venueCostMinutes(v), 6 + defaultDwellFor('lounge'));
    });

    test('every category has a dwell above zero', () {
      for (final c in ['dining', 'lounge', 'shopping', 'services', 'unknown']) {
        expect(defaultDwellFor(c), greaterThan(0));
      }
    });
  });

  group('FreeTimeStrip', () {
    testWidgets('shows only venues that fit the free time', (t) async {
      await t.pumpWidget(_wrap(FreeTimeStrip(
        freeTime: const Duration(minutes: 25),
        venues: [
          _venue(id: 'near', name: 'Blue Bottle', walk: 2, visit: 10),
          _venue(id: 'far', name: 'Far Lounge', walk: 30, visit: 60),
        ],
      )));
      await t.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('25'), findsWidgets);
      expect(find.text('Blue Bottle'), findsOneWidget);
      expect(find.text('Far Lounge'), findsNothing);
    });

    testWidgets('turns urgent when free time is negative', (t) async {
      await t.pumpWidget(_wrap(FreeTimeStrip(
        freeTime: const Duration(minutes: -6),
        venues: [_venue(id: 'near', name: 'Blue Bottle', walk: 2, visit: 10)],
      )));
      await t.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('behind'), findsOneWidget);
      expect(find.text('Blue Bottle'), findsNothing);
    });

    testWidgets('renders nothing when free time is unknown', (t) async {
      await t.pumpWidget(_wrap(const FreeTimeStrip(freeTime: null, venues: [])));
      await t.pump(const Duration(milliseconds: 50));

      expect(find.byType(SizedBox), findsWidgets);
      expect(t.takeException(), isNull);
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/journey/journey_cards_test.dart`
Expected: FAIL - `Target of URI doesn't exist: '.../current_step_card.dart'`

- [ ] **Step 3: Create `current_step_card.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/journey.dart';
import '../../domain/entities/journey_step.dart';

/// "Do this now" - the one thing the traveller should act on.
class CurrentStepCard extends StatelessWidget {
  final Journey journey;

  const CurrentStepCard({super.key, required this.journey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final step = journey.currentStep;
    final sky = isDark ? AppColors.dSky : AppColors.sky;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final clock = DateFormat('H:mm');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.dSurface : AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: sky, width: 2),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step ${journey.currentIndex + 1} of ${journey.steps.length} · do this now',
              style: theme.textTheme.labelSmall?.copyWith(
                color: sky,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              step.title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: textColor, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              step.where,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: textColor, fontWeight: FontWeight.w600),
            ),
            if (step.note != null) ...[
              const SizedBox(height: 2),
              Text(step.note!,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            ],
            const SizedBox(height: AppSpacing.smMd),
            Divider(
              height: 1,
              color: isDark ? AppColors.dHairline : AppColors.hairline,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                // Skipped rather than shown as zero when there is no queue.
                if (step.queueMinutes > 0)
                  _Stat(
                    label: 'Queue',
                    value: '${step.queueMinutes} min',
                    emphasise: step.queueMinutes >= 15,
                  ),
                if (step.walkMinutes > 0)
                  _Stat(label: 'Walk', value: '${step.walkMinutes} min'),
                if (step.deadline != null)
                  _Stat(
                    label: 'Be there by',
                    value: clock.format(step.deadline!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasise;

  const _Stat({
    required this.label,
    required this.value,
    this.emphasise = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: muted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: AppTypography.mono(
              fontSize: 15,
              weight: FontWeight.w700,
              color: emphasise ? AppColors.statusDelayed : textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// The step after the current one, kept deliberately quiet.
class ThenCard extends StatelessWidget {
  final JourneyStep step;
  final String gate;

  const ThenCard({super.key, required this.step, required this.gate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.dSurface : AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: isDark
            ? Border.all(color: AppColors.dHairline, width: 1)
            : Border.all(color: AppColors.hairline, width: 1),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.smMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THEN',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: muted, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    step.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: textColor, fontWeight: FontWeight.w700),
                  ),
                ),
                if (step.walkMinutes > 0)
                  Text(
                    '${step.walkMinutes} min walk',
                    style: AppTypography.mono(fontSize: 12, color: muted),
                  ),
              ],
            ),
            if (step.note != null) ...[
              const SizedBox(height: 2),
              Text(step.where,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Create `free_time_strip.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../venues/domain/entities/venue.dart';

/// How long a traveller typically spends somewhere, when the catalog does not
/// say. Only 10 venues carry an authored avgVisitMinutes; without a fallback
/// the fit calculation silently collapses to walk time alone.
int defaultDwellFor(String category) => switch (category.toLowerCase()) {
      'lounge' => 40,
      'dining' => 25,
      'cafe' => 15,
      'shopping' => 12,
      'services' => 10,
      _ => 15,
    };

/// Walk there, spend time, walk back. The return leg is the part people forget.
int venueCostMinutes(Venue v) =>
    (v.walkMinutes * 2) + (v.avgVisitMinutes ?? defaultDwellFor(v.category));

/// "You'll have 25 free minutes" - and only the places that actually fit.
class FreeTimeStrip extends StatelessWidget {
  final Duration? freeTime;
  final List<Venue> venues;
  final void Function(Venue)? onTap;

  const FreeTimeStrip({
    super.key,
    required this.freeTime,
    required this.venues,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final free = freeTime;
    if (free == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;

    if (free.isNegative) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.statusDelayedAlpha15,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.statusDelayed, width: 1),
        ),
        padding: const EdgeInsets.all(AppSpacing.smMd),
        child: Row(
          children: [
            const Icon(Icons.running_with_errors_rounded,
                size: 18, color: AppColors.statusDelayed),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                "You're ${free.inMinutes.abs()} min behind - skip the stop and go straight through.",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.statusDelayed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final fits = venues.where((v) => venueCostMinutes(v) <= free.inMinutes).toList()
      ..sort((a, b) => a.walkMinutes.compareTo(b.walkMinutes));
    if (fits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "You'll have ${free.inMinutes} free minutes",
          style: theme.textTheme.labelSmall?.copyWith(
            color: muted,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            for (var i = 0; i < fits.length && i < 3; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(child: _VenueTile(venue: fits[i], onTap: onTap)),
            ],
          ],
        ),
      ],
    );
  }
}

class _VenueTile extends StatelessWidget {
  final Venue venue;
  final void Function(Venue)? onTap;

  const _VenueTile({required this.venue, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.dSurface : AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.dHairline : AppColors.hairline,
          width: 1,
        ),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap == null ? null : () => onTap!(venue),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: AppSpacing.smMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${venue.walkMinutes} min',
                  style: AppTypography.mono(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/features/journey/journey_cards_test.dart`
Expected: PASS - 8 tests

- [ ] **Step 6: Commit**

```bash
git add lib/features/journey/presentation/widgets test/features/journey/journey_cards_test.dart
git commit -m "feat(journey): current step, then, and free-time cards

The free-time fit counts the walk both ways plus a dwell, with a per-category
default when avgVisitMinutes is null - which it is for every venue outside
the ten-entry JFK catalog. Without that fallback the filter silently becomes
walk-only. Negative free time flips the strip to a warning instead of
recommending a coffee the traveller does not have time for.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 8: Disruption banner

**Files:**
- Create: `lib/features/journey/presentation/widgets/disruption_banner.dart`
- Test: `test/features/journey/disruption_banner_test.dart`

**Interfaces:**
- Consumes: `Disruption`, `DisruptionKind`, `StepKind`, `acknowledgedDisruptionsProvider`
- Produces: `DisruptionBanner({required Disruption disruption})` - a `ConsumerWidget`

- [ ] **Step 1: Write the failing test**

Create `test/features/journey/disruption_banner_test.dart`:

```dart
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

Widget _wrap(Widget child, {List<Override> overrides = const []}) => ProviderScope(
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/journey/disruption_banner_test.dart`
Expected: FAIL - `Target of URI doesn't exist: '.../disruption_banner.dart'`

- [ ] **Step 3: Create `disruption_banner.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/disruption.dart';
import '../providers/journey_providers.dart';

/// The announcement you may not have heard, delivered where you are.
///
/// Tapping acknowledges rather than dismisses: the banner collapses to a
/// single line and stays until the affected step is done. A gate change must
/// not be able to leave the screen because somebody tapped once.
class DisruptionBanner extends ConsumerWidget {
  final Disruption disruption;

  const DisruptionBanner({super.key, required this.disruption});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final acknowledged =
        ref.watch(acknowledgedDisruptionsProvider).contains(disruption.affectedStep);

    final isUrgent = disruption.kind == DisruptionKind.gateChange ||
        disruption.kind == DisruptionKind.boardingEarly;
    final fill = isUrgent ? AppColors.statusDelayedAlpha15 : AppColors.amberAlpha15;
    final line = isUrgent ? AppColors.statusDelayed : AppColors.amber;
    final ink = isUrgent ? AppColors.statusDelayed : AppColors.amberText;

    return Semantics(
      liveRegion: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => ref
              .read(acknowledgedDisruptionsProvider.notifier)
              .update((s) => {...s, disruption.affectedStep}),
          child: Container(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: line, width: 1),
            ),
            padding: const EdgeInsets.all(AppSpacing.smMd),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_iconFor(disruption.kind), size: 18, color: line),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disruption.headline,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!acknowledged) ...[
                        const SizedBox(height: 2),
                        Text(
                          disruption.detail,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: ink, height: 1.35),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(DisruptionKind kind) => switch (kind) {
        DisruptionKind.gateChange => Icons.swap_horiz_rounded,
        DisruptionKind.queueSpike => Icons.trending_up_rounded,
        DisruptionKind.boardingEarly => Icons.schedule_rounded,
        DisruptionKind.laneClosed => Icons.block_rounded,
      };
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/journey/disruption_banner_test.dart`
Expected: PASS - 3 tests

- [ ] **Step 5: Commit**

```bash
git add lib/features/journey/presentation/widgets/disruption_banner.dart test/features/journey/disruption_banner_test.dart
git commit -m "feat(journey): disruption banner with acknowledgement

Acknowledgement lives in provider state keyed by affected step, not on the
immutable Disruption, so it survives rebuilds and clears when that step
completes. Tapping collapses to one line rather than dismissing - a gate
change should not be able to leave the screen because of one tap.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 9: Journey screen

**Files:**
- Create: `lib/features/journey/presentation/screens/journey_screen.dart`
- Test: `test/features/journey/journey_screen_test.dart`

**Interfaces:**
- Consumes: everything from Tasks 1-8, plus `upcomingFlightsProvider`, `selectedFlightProvider`, `detectedAirportProvider`, `allVenuesProvider`, `AirlineTile`, `StatusBadge`
- Produces: `JourneyScreen()` - `const` constructor required, because every shell child is built as `const NoTransitionPage(child: X())`

Body switches on `journey.awaitingFlight`: the flight list at step one, the step cards afterwards.

- [ ] **Step 1: Write the failing test**

Create `test/features/journey/journey_screen_test.dart`:

```dart
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

Widget _app(Journey? journey, {List<Override> extra = const []}) => ProviderScope(
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

  testWidgets('after a flight it shows the current step and the next one', (t) async {
    t.view.physicalSize = const Size(375, 1400);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);

    await t.pumpWidget(_app(_running()));
    await t.pump(const Duration(milliseconds: 200));

    expect(find.text('Head to Security'), findsOneWidget);
    expect(find.text('THEN'), findsOneWidget);
    expect(find.text('Gate C18'), findsWidgets);
    expect(find.text('AA 2468'), findsWidgets);
    expect(t.takeException(), isNull);
  });

  testWidgets('with no journey it invites you to pick a stage', (t) async {
    await t.pumpWidget(_app(null));
    await t.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('What are you doing'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/journey/journey_screen_test.dart`
Expected: FAIL - `Target of URI doesn't exist: '.../journey_screen.dart'`

- [ ] **Step 3: Create `journey_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/airline_tile.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../flight/domain/entities/flight.dart';
import '../../../flight/presentation/providers/flight_providers.dart';
import '../../../venues/presentation/providers/venue_providers.dart';
import '../../domain/entities/journey.dart';
import '../providers/journey_providers.dart';
import '../widgets/current_step_card.dart';
import '../widgets/disruption_banner.dart';
import '../widgets/free_time_strip.dart';
import '../widgets/journey_spine.dart';

const _gutter = AppSpacing.gutter;

/// One page for the whole journey. The spine is constant; the body is whatever
/// the current step needs - a flight list at step one, step cards after that.
class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final journey = ref.watch(journeyProvider);

    // Keeps the ticker alive for exactly as long as this screen is mounted.
    ref.watch(journeyTickerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
        child: journey == null
            ? _NoStage(onPick: () => context.go('/home'))
            : ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: AppSpacing.smMd),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, 0),
                    child: _Header(journey: journey),
                  ),
                  const SizedBox(height: AppSpacing.smMd),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _gutter),
                    child: JourneySpine(
                      journey: journey,
                      onTap: () => context.push('/journey/steps'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (journey.awaitingFlight)
                    _FlightPicker(journey: journey)
                  else
                    _StepBody(journey: journey),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Journey journey;
  const _Header({required this.journey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final flight = journey.flight;
    final clock = DateFormat('H:mm');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.go('/home'),
                child: Text(
                  '‹ Home',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDark ? AppColors.dSky : AppColors.sky,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                flight == null
                    ? 'Departing'
                    : '${flight.flightNumber} · ${flight.arrivalCity}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 2),
              Text(
                flight == null
                    ? 'Choose your flight to begin'
                    : '${flight.departureAirport} · departs ${clock.format(flight.departureTime)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
        ),
        if (flight != null) ...[
          const SizedBox(width: AppSpacing.sm),
          StatusBadge(status: flight.status, delayMinutes: flight.delayMinutes),
        ],
      ],
    );
  }
}

/// Step one. The board is the body of the page, not a separate destination.
class _FlightPicker extends ConsumerWidget {
  final Journey journey;
  const _FlightPicker({required this.journey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final flights = ref.watch(upcomingFlightsProvider);
    final step = journey.currentStep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step 1 of ${journey.steps.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.dSky : AppColors.sky,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  )),
              const SizedBox(height: 5),
              Text(step.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(step.where,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (flights.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _gutter),
            child: const EmptyState(
              icon: Icons.flight_takeoff_rounded,
              title: 'No upcoming flights',
              message: 'Nothing departing in the next few hours.',
            ),
          )
        else
          for (final f in flights)
            Padding(
              padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, AppSpacing.sm),
              child: _FlightRow(
                flight: f,
                onTap: () =>
                    ref.read(selectedFlightProvider.notifier).state = f,
              ),
            ),
      ],
    );
  }
}

class _FlightRow extends StatelessWidget {
  final Flight flight;
  final VoidCallback onTap;

  const _FlightRow({required this.flight, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final clock = DateFormat('H:mm');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.dSurface : AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.dHairline : AppColors.hairline,
          width: 1,
        ),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.smMd),
            child: Row(
              children: [
                AirlineTile(flightNumber: flight.flightNumber, size: 34),
                const SizedBox(width: AppSpacing.smMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${flight.arrivalCity} (${flight.arrivalAirport})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(flight.flightNumber,
                          style: AppTypography.mono(fontSize: 11, color: muted)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      clock.format(flight.departureTime),
                      style: AppTypography.mono(
                        fontSize: 14,
                        weight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text('Gate ${flight.gate ?? '-'}',
                        style: theme.textTheme.labelSmall?.copyWith(color: muted)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepBody extends ConsumerWidget {
  final Journey journey;
  const _StepBody({required this.journey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venues = ref.watch(allVenuesProvider);
    final next = journey.nextStep;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (journey.disruption != null) ...[
            DisruptionBanner(disruption: journey.disruption!),
            const SizedBox(height: AppSpacing.smMd),
          ],
          CurrentStepCard(journey: journey),
          if (next != null) ...[
            const SizedBox(height: AppSpacing.smMd),
            ThenCard(step: next, gate: journey.effectiveGate),
          ],
          const SizedBox(height: AppSpacing.lg),
          FreeTimeStrip(
            freeTime: journey.freeTime,
            venues: venues,
            onTap: (v) => context.push('/explore/venue/${v.id}'),
          ),
        ],
      ),
    );
  }
}

class _NoStage extends StatelessWidget {
  final VoidCallback onPick;
  const _NoStage({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(_gutter),
        child: EmptyState(
          icon: Icons.explore_outlined,
          title: 'No journey yet',
          message: 'What are you doing today? Pick departing, connecting or arrived on Home.',
          action: PrimaryButton(label: 'Go to Home', onPressed: onPick),
        ),
      ),
    );
  }
}
```

Note: `_NoStage` uses `PrimaryButton` from `core/widgets/app_buttons.dart`; add that import.

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/journey/journey_screen_test.dart`
Expected: PASS - 3 tests

- [ ] **Step 5: Commit**

```bash
git add lib/features/journey/presentation/screens/journey_screen.dart test/features/journey/journey_screen_test.dart
git commit -m "feat(journey): the journey page

Spine on top, body per step. Choosing a flight is step one, so the app never
renders an 'I need a flight first' empty state - the board simply is what the
first step looks like.

The ticker is watched here rather than at app scope, so it starts when the
screen mounts and is cancelled when it leaves.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 10: All-steps timeline

**Files:**
- Create: `lib/features/journey/presentation/screens/journey_steps_screen.dart`
- Test: `test/features/journey/journey_steps_screen_test.dart`

**Interfaces:**
- Consumes: `journeyProvider`, `Journey`, `StepStatus`
- Produces: `JourneyStepsScreen()` with a `const` constructor

- [ ] **Step 1: Write the failing test**

Create `test/features/journey/journey_steps_screen_test.dart`:

```dart
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/journey/journey_steps_screen_test.dart`
Expected: FAIL - `Target of URI doesn't exist`

- [ ] **Step 3: Create `journey_steps_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/journey.dart';
import '../../domain/entities/journey_step.dart';
import '../providers/journey_providers.dart';

const _gutter = AppSpacing.gutter;

/// The whole journey, top to bottom. For the traveller who wants the full
/// picture rather than only the next move.
class JourneyStepsScreen extends ConsumerWidget {
  const JourneyStepsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final journey = ref.watch(journeyProvider);
    final muted = isDark ? AppColors.dMuted : AppColors.muted;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Your journey', style: theme.textTheme.titleMedium),
      ),
      body: journey == null
          ? Center(
              child: Text('No journey yet',
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, AppSpacing.xxl),
              children: [
                for (var i = 0; i < journey.steps.length; i++)
                  _TimelineRow(
                    step: journey.steps[i],
                    status: journey.statusOf(i),
                    isLast: i == journey.steps.length - 1,
                  ),
              ],
            ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final JourneyStep step;
  final StepStatus status;
  final bool isLast;

  const _TimelineRow({
    required this.step,
    required this.status,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final sky = isDark ? AppColors.dSky : AppColors.sky;
    final track = isDark ? AppColors.dHairline : AppColors.hairlineCool;
    final isDone = status == StepStatus.done;
    final isCurrent = status == StepStatus.current;
    final clock = DateFormat('H:mm');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 16,
            child: Column(
              children: [
                const SizedBox(height: 5),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? AppColors.amber
                        : isCurrent
                            ? sky
                            : track,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: isDone ? AppColors.amber : track,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.smMd),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          step.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDone ? muted : textColor,
                            fontWeight:
                                isDone ? FontWeight.w600 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: sky,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            'NOW',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (step.deadline != null)
                        Text(
                          clock.format(step.deadline!),
                          style: AppTypography.mono(fontSize: 11, color: muted),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.where,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                  if (step.totalMinutes > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (step.queueMinutes > 0) '${step.queueMinutes} min queue',
                        if (step.walkMinutes > 0) '${step.walkMinutes} min walk',
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/features/journey/journey_steps_screen_test.dart`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add lib/features/journey/presentation/screens/journey_steps_screen.dart test/features/journey/journey_steps_screen_test.dart
git commit -m "feat(journey): full timeline screen

Every step with its location, deadline, queue and walk. Reached from the
spine, for when the next move is not enough and you want the whole picture.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 11: Home becomes the stage chooser

**Files:**
- Create: `lib/features/home/presentation/widgets/stage_card.dart`
- Modify: `lib/features/home/presentation/home_screen.dart` (full rewrite of `build`)
- Test: `test/home_screen_test.dart` (rewrite)

**Interfaces:**
- Consumes: `journeyStageProvider`, `journeyProvider`, `JourneyStage`, `detectedAirportProvider`, `HomeHeader`
- Produces: `StageCard({required JourneyStage? stage, required IconData icon, required String title, required String description, Journey? liveJourney, required VoidCallback onTap})`

The airport picker stays in `HomeHeader` untouched - it is the app's only writer of `detectedAirportProvider`, which `upcomingFlightsProvider`, `allVenuesProvider`, `filteredOffersProvider`, `ExploreScreen` and the flights board all read.

- [ ] **Step 1: Write the failing test**

Replace `test/home_screen_test.dart` entirely:

```dart
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
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/home_screen_test.dart`
Expected: FAIL - `Expected: exactly one matching candidate / Actual: _TextFinder:<zero widgets>` on "What are you doing today"

- [ ] **Step 3: Create `stage_card.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../journey/domain/entities/journey.dart';

/// One of the three ways into the airport.
///
/// Before it is chosen it describes a choice. Once it is the active stage it
/// carries live status instead, so the second launch tells the traveller
/// something rather than asking the same question again.
class StageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color tint;
  final Journey? liveJourney;
  final VoidCallback onTap;

  const StageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.tint,
    required this.onTap,
    this.liveJourney,
  });

  bool get _isActive => liveJourney != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sky = isDark ? AppColors.dSky : AppColors.sky;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.dSurface : AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: _isActive
            ? Border.all(color: sky, width: 2)
            : Border.all(color: hairline, width: 1),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: tint,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(icon, size: 20, color: textColor),
                    ),
                    const SizedBox(width: AppSpacing.smMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (_isActive) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: sky,
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusFull),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style:
                                        theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isActive
                                ? 'Next: ${liveJourney!.currentStep.title}'
                                    '${liveJourney!.currentStep.queueMinutes > 0 ? ' · ${liveJourney!.currentStep.queueMinutes} min queue' : ''}'
                                : description,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: muted, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(Icons.chevron_right_rounded, size: 20, color: muted),
                  ],
                ),
                if (_isActive) ...[
                  const SizedBox(height: AppSpacing.smMd),
                  Divider(height: 1, color: hairline),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _MiniStat(
                        label: 'Step',
                        value:
                            '${liveJourney!.currentIndex + 1} of ${liveJourney!.steps.length}',
                      ),
                      _MiniStat(label: 'Gate', value: liveJourney!.effectiveGate),
                      if (liveJourney!.boardingTime != null)
                        _MiniStat(
                          label: 'Boards',
                          value:
                              '${liveJourney!.boardingTime!.hour.toString().padLeft(2, '0')}:${liveJourney!.boardingTime!.minute.toString().padLeft(2, '0')}',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 1),
          Text(value,
              style: AppTypography.mono(
                  fontSize: 14, weight: FontWeight.w700, color: textColor)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Rewrite `home_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../features/flight/presentation/providers/flight_providers.dart';
import '../../../features/journey/domain/entities/journey.dart';
import '../../../features/journey/presentation/providers/journey_providers.dart';
import 'widgets/home_header.dart';
import 'widgets/stage_card.dart';

const _gutter = AppSpacing.gutter;
const _sectionGap = AppSpacing.sectionGap;

/// Home asks the one question the app cannot answer for itself: are you
/// departing, connecting or arriving? Knowing the flight does not settle it -
/// the same boarding pass belongs to someone about to check in and to someone
/// who just landed with 90 minutes to make the connection.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _airports = ['JFK', 'LAX', 'LHR', 'CDG', 'DXB', 'SIN', 'NRT', 'SFO'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final detectedAirport = ref.watch(detectedAirportProvider);
    final journey = ref.watch(journeyProvider);
    final muted = isDark ? AppColors.dMuted : AppColors.muted;

    void start(JourneyStage stage) {
      ref.read(journeyStageProvider.notifier).state = stage;
      context.push('/journey');
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: AppSpacing.smMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: HomeHeader(
                airport: detectedAirport,
                airports: _airports,
                onAirportChanged: (v) =>
                    ref.read(detectedAirportProvider.notifier).state = v,
                onNotifications: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                        const SnackBar(content: Text("You're all caught up.")));
                },
                onProfile: () => context.go('/more'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hey there', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 3),
                  Text(
                    "Let's get you where you need to go.\nWhat are you doing today?",
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: muted, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: StageCard(
                icon: Icons.flight_takeoff_rounded,
                title: 'Departing',
                description: "I'm at the airport and heading to my gate.",
                tint: isDark ? AppColors.skyAlpha15 : AppColors.skyTint,
                liveJourney:
                    journey?.stage == JourneyStage.departing ? journey : null,
                onTap: () => start(JourneyStage.departing),
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: StageCard(
                icon: Icons.swap_horiz_rounded,
                title: 'Connecting',
                description: 'I have a connection to another flight.',
                tint: isDark ? AppColors.amberAlpha15 : AppColors.amberTint,
                liveJourney:
                    journey?.stage == JourneyStage.connecting ? journey : null,
                onTap: () => start(JourneyStage.connecting),
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: StageCard(
                icon: Icons.flight_land_rounded,
                title: 'Arrived',
                description: "I've landed and want services or transport.",
                tint: AppColors.successAlpha15,
                onTap: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(const SnackBar(
                        content: Text('Arrived is coming next.')));
                },
              ),
            ),
            const SizedBox(height: _sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: _PopularRow(onExplore: () => context.go('/explore')),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _PopularRow extends StatelessWidget {
  final VoidCallback onExplore;
  const _PopularRow({required this.onExplore});

  static const _items = <(IconData, String)>[
    (Icons.restaurant_rounded, 'Food'),
    (Icons.weekend_rounded, 'Lounges'),
    (Icons.shower_rounded, 'Showers'),
    (Icons.shopping_bag_outlined, 'Shops'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Popular right now',
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: textColor, fontWeight: FontWeight.w700)),
            const Spacer(),
            InkWell(
              onTap: onExplore,
              child: Text('View all',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDark ? AppColors.dSky : AppColors.sky,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.smMd),
        Row(
          children: [
            for (var i = 0; i < _items.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dSurface : AppColors.card,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: hairline, width: 1),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onExplore,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.smMd),
                        child: Column(
                          children: [
                            Icon(_items[i].$1, size: 20, color: textColor),
                            const SizedBox(height: 6),
                            Text(_items[i].$2,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/home_screen_test.dart`
Expected: PASS - 3 tests

- [ ] **Step 6: Commit**

```bash
git add lib/features/home/presentation test/home_screen_test.dart
git commit -m "feat(home): Home becomes the stage chooser

Departing, connecting and arriving are genuinely different journeys and no
amount of flight data tells the app which one you are on - the same boarding
pass belongs to someone about to check in and to someone who just landed with
90 minutes to make a connection. That is the question Home now asks.

The chosen stage stops being a door: it carries step, gate and boarding time,
so the second launch reports rather than asks. The airport picker stays in the
header - it is the app's only writer of detectedAirportProvider.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 12: Routing and the Trip tab

**Files:**
- Modify: `lib/core/router/app_router.dart`
- Modify: `lib/core/widgets/app_shell.dart:34-39`
- Test: `test/app_shell_test.dart` (rewrite lines 22 and 39)

**Interfaces:**
- Consumes: `JourneyScreen`, `JourneyStepsScreen`, `journeyProvider`
- Produces: routes `/journey`, `/journey/steps`; tab index 3 becomes Trip

**Constraints:**
- `_tabs` must stay at exactly 5 entries with the hero at index 2. A sixth entry un-centres the Assistant disc and shrinks every tab from 1/5 to 1/6 of a 360px phone, truncating the `maxLines: 1` labels.
- `/flights` moves out of the tab bar. Convert it from `pageBuilder: NoTransitionPage` to `builder:` or a push shows with no animation and reads as a rendering bug.
- `AppShell._currentIndex` returns -1 for any location not in `_tabs`, which renders the bar with no active tab. `/journey` must therefore be the Trip tab's route.

- [ ] **Step 1: Write the failing test**

Rewrite `test/app_shell_test.dart` lines 22 and 39 so the route list and labels read:

```dart
    for (final route in ['/home', '/explore', '/voice-chat', '/journey', '/map']) {
```

```dart
    for (final label in ['Home', 'Explore', 'Assistant', 'Trip', 'Map']) {
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/app_shell_test.dart`
Expected: FAIL - the shell still declares `/flights` and the label `Flights`

- [ ] **Step 3: Swap the tab in `app_shell.dart`**

Replace the fourth `_NavItem` (currently `/flights`, `Icons.flight_outlined`, label `'Flights'`) with:

```dart
    _NavItem(
      // Trip: return me to my journey, wherever I am in it.
      route: '/journey',
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore_rounded,
      label: 'Trip',
    ),
```

Leave the list at five entries and the hero at index 2.

- [ ] **Step 4: Register the routes in `app_router.dart`**

Add these imports:

```dart
import '../../features/journey/presentation/screens/journey_screen.dart';
import '../../features/journey/presentation/screens/journey_steps_screen.dart';
```

Change the existing `/flights` route inside the `ShellRoute` from `pageBuilder` to `builder` so a push animates:

```dart
          // Reached from the journey's first step, not from the tab bar.
          GoRoute(
            path: '/flights',
            builder: (context, state) => const FlightsBoardScreen(),
          ),
```

Add the journey routes as siblings inside the same `ShellRoute`:

```dart
          GoRoute(
            path: '/journey',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: JourneyScreen(),
            ),
            routes: [
              GoRoute(
                path: 'steps',
                builder: (context, state) => const JourneyStepsScreen(),
              ),
            ],
          ),
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `flutter test test/app_shell_test.dart test/features/journey/`
Expected: PASS

- [ ] **Step 6: Commit**

```bash
git add lib/core/router/app_router.dart lib/core/widgets/app_shell.dart test/app_shell_test.dart
git commit -m "feat(nav): Trip replaces Flights in the tab bar

The Trip tab has one job: take me back to my journey. The flights board is
still there - it is what the journey's first step looks like - but it is no
longer a destination you visit before the app can help you.

The bar stays at five entries with the hero at index 2. A sixth would
un-centre the Assistant disc and truncate every label on a 360px phone.
/flights moves from NoTransitionPage to builder so a push animates.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 13: Retire what Home no longer uses

**Files:**
- Delete: `lib/features/home/presentation/widgets/home_hero_banner.dart`
- Delete: `lib/features/home/presentation/widgets/home_search_bar.dart`
- Delete: `lib/features/home/presentation/widgets/quick_start_section.dart`
- Delete: `lib/features/home/presentation/widgets/upcoming_flight_card.dart`
- Delete: `lib/features/home/presentation/widgets/live_departures_section.dart`
- Delete: `test/features/home/home_density_test.dart`
- Delete: `test/home_sections_test.dart`
- Modify: `lib/features/flight/presentation/providers/flight_providers.dart`

**Why these tests go rather than being fixed:** they import the deleted widget files directly, so they fail to compile rather than fail an assertion. `home_density_test.dart` imports both `quick_start_section.dart` and `upcoming_flight_card.dart`; `home_sections_test.dart` imports `upcoming_flight_card.dart`. Their subject matter no longer exists.

- [ ] **Step 1: Confirm nothing else imports them**

Run:

```bash
grep -rn "home_hero_banner\|home_search_bar\|quick_start_section\|upcoming_flight_card\|live_departures_section" lib/ test/
```

Expected: only the files listed above. If anything else appears, retarget it before deleting.

- [ ] **Step 2: Delete the widgets and their tests**

```bash
git rm lib/features/home/presentation/widgets/home_hero_banner.dart \
       lib/features/home/presentation/widgets/home_search_bar.dart \
       lib/features/home/presentation/widgets/quick_start_section.dart \
       lib/features/home/presentation/widgets/upcoming_flight_card.dart \
       lib/features/home/presentation/widgets/live_departures_section.dart \
       test/features/home/home_density_test.dart \
       test/home_sections_test.dart
```

- [ ] **Step 3: Remove the dead boarding-time providers**

`timeUntilBoardingProvider` and `availableTimeMinutesProvider` in `flight_providers.dart` have zero call sites and use a -30 / -15 minute offset that now duplicates `kBoardingLead` and `kGateCloseLead` in `journey.dart`. Delete both provider declarations.

Verify first:

```bash
grep -rn "timeUntilBoardingProvider\|availableTimeMinutesProvider" lib/ test/
```

Expected: only their declarations in `flight_providers.dart`.

- [ ] **Step 4: Run analyze and the full suite**

Run: `flutter analyze`
Expected: `No issues found!`

Run: `flutter test`
Expected: PASS - all remaining tests green

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "refactor(home): retire the widgets Home no longer uses

Home is the stage chooser now. The hero banner was a promise rather than
information, Quick Start duplicated three tab-bar destinations, flight search
became step one of the journey, and the departures board went with it.

home_density_test and home_sections_test are deleted rather than repaired:
they import the deleted widget files directly, so they fail to compile, and
their subject matter no longer exists.

Also removes timeUntilBoardingProvider and availableTimeMinutesProvider,
which had no call sites and carried a third and fourth derivation of the
boarding offset now owned by journey.dart.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 14: Connecting flights

**Files:**
- Modify: `lib/features/flight/data/datasources/flight_mock_datasource.dart`
- Modify: `lib/features/journey/data/journey_mock.dart`
- Modify: `lib/features/journey/presentation/providers/journey_providers.dart`
- Test: `test/features/journey/connecting_test.dart`

**Interfaces:**
- Produces: `buildConnectingJourney({required DateTime pinnedNow, Flight? flight, Flight? inbound, int tick = 0})`, `connectingInboundProvider`

**The data problem this fixes.** Of 15 mock flights only 3 arrive at JFK, landing at now+9h45m, now+16h and now+19h30m - later than every JFK departure, whose latest is now+3h05m. No pair of existing flights can form a connection.

- [ ] **Step 1: Write the failing test**

Create `test/features/journey/connecting_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:airport_nav/features/flight/data/datasources/flight_mock_datasource.dart';
import 'package:airport_nav/features/journey/data/journey_mock.dart';
import 'package:airport_nav/features/journey/domain/entities/journey.dart';
import 'package:airport_nav/features/journey/domain/entities/journey_step.dart';

void main() {
  test('at least one inbound lands before a JFK departure leaves', () {
    final all = FlightMockDatasource().getAllFlights();
    final arrivals = all.where((f) => f.arrivalAirport == 'JFK').toList();
    final departures = all.where((f) => f.departureAirport == 'JFK').toList();

    expect(arrivals, isNotEmpty);
    expect(departures, isNotEmpty);

    final connectable = arrivals.any((a) => departures.any((d) =>
        d.departureTime.isAfter(a.arrivalTime.add(const Duration(minutes: 45)))));
    expect(connectable, isTrue,
        reason: 'a connection needs an inbound that lands before an outbound leaves');
  });

  test('the connecting spine reuses the shape but swaps the first steps', () {
    final all = FlightMockDatasource().getAllFlights();
    final inbound = all.firstWhere((f) => f.arrivalAirport == 'JFK');
    final outbound = all.firstWhere((f) => f.departureAirport == 'JFK');

    final j = buildConnectingJourney(
      pinnedNow: DateTime(2026, 7, 31, 10, 3),
      flight: outbound,
      inbound: inbound,
    );

    expect(j.stage, JourneyStage.connecting);
    expect(j.inboundFlight, isNotNull);
    expect(
      j.steps.map((s) => s.kind).toList(),
      [
        StepKind.flight,
        StepKind.arrive,
        StepKind.transfer,
        StepKind.security,
        StepKind.gate,
        StepKind.boarding,
      ],
    );
  });

  test('connecting waits on step one without an outbound', () {
    final j = buildConnectingJourney(pinnedNow: DateTime(2026, 7, 31, 10, 3));
    expect(j.awaitingFlight, isTrue);
    expect(j.stage, JourneyStage.connecting);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/features/journey/connecting_test.dart`
Expected: FAIL - `connectable` is false, and `buildConnectingJourney` is undefined

- [ ] **Step 3: Add connecting inbound flights**

In `flight_mock_datasource.dart`, append three inbound flights to the returned list. They land 75, 95 and 130 minutes from `now`, comfortably before the JFK departures at now+1h45m and later:

```dart
      // ── Inbound flights that can actually connect ──────────────────
      // Every pre-existing JFK arrival lands hours after the last JFK
      // departure has gone, so no connection could be formed. These three
      // land inside the departure window on purpose.
      Flight(
        id: 'fl-016',
        flightNumber: 'AA 106',
        airline: 'American Airlines',
        airlineLogo: 'assets/airlines/aa.png',
        departureAirport: 'LHR',
        departureCity: 'London',
        arrivalAirport: 'JFK',
        arrivalCity: 'New York',
        departureTime: now.subtract(const Duration(hours: 6)),
        arrivalTime: now.add(const Duration(minutes: 15)),
        status: 'landed',
        gate: 'A5',
        terminal: '8',
      ),
      Flight(
        id: 'fl-017',
        flightNumber: 'BA 117',
        airline: 'British Airways',
        airlineLogo: 'assets/airlines/ba.png',
        departureAirport: 'LHR',
        departureCity: 'London',
        arrivalAirport: 'JFK',
        arrivalCity: 'New York',
        departureTime: now.subtract(const Duration(hours: 7)),
        arrivalTime: now.add(const Duration(minutes: 35)),
        status: 'on_time',
        gate: 'A7',
        terminal: '7',
      ),
      Flight(
        id: 'fl-018',
        flightNumber: 'IB 6251',
        airline: 'Iberia',
        airlineLogo: 'assets/airlines/ib.png',
        departureAirport: 'MAD',
        departureCity: 'Madrid',
        arrivalAirport: 'JFK',
        arrivalCity: 'New York',
        departureTime: now.subtract(const Duration(hours: 8)),
        arrivalTime: now.add(const Duration(minutes: 50)),
        status: 'delayed',
        gate: 'A3',
        terminal: '4',
        delayMinutes: 20,
      ),
```

- [ ] **Step 4: Add `buildConnectingJourney` to `journey_mock.dart`**

```dart
/// The connecting spine. Same shape as departing, but the first two steps are
/// getting off one aircraft and crossing the airport rather than checking in.
Journey buildConnectingJourney({
  required DateTime pinnedNow,
  Flight? flight,
  Flight? inbound,
  int tick = 0,
}) {
  if (flight == null) {
    return Journey(
      stage: JourneyStage.connecting,
      inboundFlight: inbound,
      steps: [_flightStep()],
      currentIndex: 0,
      pinnedNow: pinnedNow,
    );
  }

  final term = terminalLabel(flight.terminal);
  final inTerm = terminalLabel(inbound?.terminal);
  final disrupted = tick >= kDisruptionTick;
  final gate = disrupted ? _kMovedGate : (flight.gate ?? '-');

  final steps = <JourneyStep>[
    _flightStep(),
    JourneyStep(
      kind: StepKind.arrive,
      title: 'Get off and follow Transfers',
      where: '$inTerm · arrivals level',
      note: inbound == null
          ? 'Follow the purple Flight Connections signs'
          : 'Landed on ${inbound.flightNumber} at gate ${inbound.gate ?? '-'}',
      walkMinutes: 5,
    ),
    JourneyStep(
      kind: StepKind.transfer,
      title: 'Cross to $term',
      where: 'AirTrain · 2 stops',
      note: 'Runs every 4 minutes',
      queueMinutes: driftedQueue(StepKind.transfer, 7, tick),
      walkMinutes: 6,
    ),
    JourneyStep(
      kind: StepKind.security,
      title: 'Transfer security',
      where: '$term · Connections checkpoint',
      note: 'Shorter than the main hall - connecting passengers only',
      deadline: flight.departureTime.subtract(const Duration(minutes: 45)),
      queueMinutes: driftedQueue(StepKind.security, 10, tick),
      walkMinutes: 3,
    ),
    JourneyStep(
      kind: StepKind.gate,
      title: 'Gate $gate',
      where: '$term · Concourse ${gate.isEmpty ? '-' : gate[0]}',
      deadline: flight.departureTime.subtract(kBoardingLead),
      walkMinutes: _walkToGate(gate),
    ),
    JourneyStep(
      kind: StepKind.boarding,
      title: 'Boarding',
      where: 'Gate $gate · Group 4',
      note: 'Gate closes 15 min before departure',
      deadline: flight.departureTime.subtract(kGateCloseLead),
    ),
  ];

  return Journey(
    stage: JourneyStage.connecting,
    flight: flight,
    inboundFlight: inbound,
    steps: steps,
    currentIndex: indexForTick(steps.length, tick, startIndex: 1),
    pinnedNow: pinnedNow,
    disruption: disrupted
        ? Disruption(
            kind: DisruptionKind.gateChange,
            affectedStep: StepKind.gate,
            headline: 'Gate changed to $_kMovedGate',
            detail: 'Moved from ${flight.gate ?? '-'}. Tight connection - go straight there.',
            newGate: _kMovedGate,
          )
        : null,
  );
}
```

- [ ] **Step 5: Wire the connecting branch in `journey_providers.dart`**

Add the inbound provider and replace the placeholder branch:

```dart
/// The most recent JFK arrival that can still make a departure. Authored data:
/// no naturally-occurring pair existed in the mock set.
final connectingInboundProvider = Provider<Flight?>((ref) {
  final all = ref.watch(allFlightsProvider);
  final airport = ref.watch(detectedAirportProvider);
  final arrivals = all
      .where((f) => f.arrivalAirport == airport && f.status != 'cancelled')
      .toList()
    ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
  return arrivals.isEmpty ? null : arrivals.first;
});
```

Then in `journeyProvider`:

```dart
    JourneyStage.connecting => buildConnectingJourney(
        pinnedNow: pinnedNow,
        flight: flight,
        inbound: ref.watch(connectingInboundProvider),
        tick: tick,
      ),
```

Add `import '../../data/journey_mock.dart';` if not already present, and import `Flight`.

- [ ] **Step 6: Run the tests to verify they pass**

Run: `flutter test test/features/journey/`
Expected: PASS - all journey tests including the three new connecting ones

- [ ] **Step 7: Commit**

```bash
git add lib/features/flight/data/datasources/flight_mock_datasource.dart \
        lib/features/journey/data/journey_mock.dart \
        lib/features/journey/presentation/providers/journey_providers.dart \
        test/features/journey/connecting_test.dart
git commit -m "feat(journey): connecting flights

Connecting is where an airport fails people worst, and it could not be built
at all: of 15 mock flights only 3 arrived at JFK, landing 6 to 16 hours after
the last departure had gone. No pair could form a connection. Three inbound
flights now land inside the departure window.

The connecting spine reuses the departing shape and swaps the first two steps
- get off and follow transfers, then cross terminals - so one set of widgets
renders both journeys.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 15: Full verification

**Files:** none created; this task proves the whole thing works.

- [ ] **Step 1: Analyze**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 2: Full suite**

Run: `flutter test`
Expected: PASS. Confirm against the Regression Gate: `home_density_test.dart` and `home_sections_test.dart` are gone, `home_screen_test.dart` and `app_shell_test.dart` are rewritten, and the new journey tests are green.

- [ ] **Step 3: Check for leaked timers explicitly**

Run: `flutter test test/features/journey/ test/home_screen_test.dart --reporter expanded`
Expected: no output containing "A Timer is still pending". If it appears, a test is building a journey screen without `journeyProvider.overrideWithValue(...)`.

- [ ] **Step 4: Build the web bundle**

Run: `flutter build web --release --base-href /airportnav/`
Expected: `√ Built build\web`

- [ ] **Step 5: Walk the flow on a device or emulator**

Run: `flutter run`

Confirm by hand:
1. Home asks "What are you doing today?" and shows three stage cards
2. Tapping Departing opens the journey with the spine and the flight list
3. Picking a flight advances the spine and shows "Do this now"
4. Waiting ~30 seconds fires the gate change; the banner, the Then card and the stage card on Home all show the new gate
5. Tapping the banner collapses it to one line and it stays collapsed
6. Tapping the spine opens the full timeline
7. Going back Home shows Departing marked ACTIVE with live status
8. The Trip tab returns to the journey from anywhere
9. The airport picker still changes airports and Explore follows

- [ ] **Step 6: Commit and push**

```bash
git add -A
git commit -m "chore(journey): verify the full journey flow

analyze clean, suite green, web bundle builds, and the flow walked by hand
from the stage chooser through a gate change to boarding.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
git push
```

The push triggers the Pages workflow, so the live demo updates itself.

---

## Self-Review

**Spec coverage.** Every section of the spec maps to a task: §2 spine → Tasks 1, 4, 14; §2 free time → Tasks 1, 7; §3 decisions → Tasks 11, 12; §4 domain → Tasks 1, 2; §5 simulation → Tasks 3, 5; §6 Home → Task 11; §6 journey page → Task 9; §6 all-steps → Task 10; §6 Trip tab → Task 12; §6 free-time arithmetic → Task 7; §6 edge states → Tasks 7, 9; §7 testing → every task plus Task 15.

**Deliberately deferred, and named in the spec's §8:** the Arrived stage (Home shows a snackbar), and `mapAnchorId` step-to-map deep links.

**Type consistency check.** `Journey`, `JourneyStep`, `StepKind`, `StepStatus`, `JourneyStage`, `Disruption`, `DisruptionKind` are declared once in Task 1 and used with those exact names everywhere after. `journeyProvider`, `journeyStageProvider`, `journeyTickValueProvider`, `journeyTickerProvider`, `journeyEpochProvider`, `acknowledgedDisruptionsProvider` and `connectingInboundProvider` are declared in Task 5 (except the last, added in Task 14) and referenced consistently. `buildDepartingJourney` and `buildConnectingJourney` share the same named-parameter shape.

**Known risk carried forward.** `_walkToGate` in `journey_mock.dart` duplicates the logic of `estimatedWalkMinutes`, which is deleted with `upcoming_flight_card.dart` in Task 13. The journey copy is the surviving one; nothing else references the old function after that task.
