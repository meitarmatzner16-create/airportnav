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
