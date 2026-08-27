import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../flight/domain/entities/flight.dart';
import '../../../flight/presentation/providers/flight_providers.dart';
import '../../data/journey_mock.dart';
import '../../domain/entities/journey.dart';
import '../../domain/entities/journey_step.dart';
import '../../domain/journey_clock.dart';

/// Which stage the traveller told us they are in. Null means Home has not been
/// answered yet - the app deliberately cannot infer this from a flight.
final journeyStageProvider = StateProvider<JourneyStage?>((ref) => null);

/// The flight the traveller arrived on. Connecting only - the "I arrived on"
/// column of the connection picker writes it.
final selectedInboundFlightProvider = StateProvider<Flight?>((ref) => null);

/// True while the traveller is revisiting step one mid-journey to swap a
/// flight. The journey keeps running underneath - nothing is cleared, so
/// backing out with Done costs nothing.
final flightEditingProvider = StateProvider<bool>((ref) => false);

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
    JourneyStage.connecting => buildConnectingJourney(
        pinnedNow: pinnedNow,
        flight: flight,
        inbound: ref.watch(selectedInboundFlightProvider),
        tick: tick,
      ),
  };
});

/// Disruptions the traveller has acknowledged, keyed by the step they affect.
/// Acknowledgement lives here rather than on the immutable Disruption so it
/// survives rebuilds and clears when the affected step completes.
final acknowledgedDisruptionsProvider =
    StateProvider<Set<StepKind>>((ref) => <StepKind>{});
