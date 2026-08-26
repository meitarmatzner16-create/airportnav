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
  String get effectiveGate => disruption?.newGate ?? flight?.gate ?? '-';

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
        disruption: clearDisruption ? null : (disruption ?? this.disruption),
      );
}
