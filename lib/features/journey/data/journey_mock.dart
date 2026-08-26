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
            detail:
                'Moved from ${flight.gate ?? '-'}. Same concourse, 3 min further.',
            newGate: _kMovedGate,
          )
        : null,
  );
}

JourneyStep _connectionStep() => const JourneyStep(
      kind: StepKind.flight,
      title: 'Which flights connect?',
      where: 'Pick the flight you came in on and the one you leave on.',
    );

/// The connecting spine. Same shape as departing, but the first two steps are
/// getting off one aircraft and crossing the airport rather than checking in.
/// Both flights must be chosen before the journey can move off step one.
Journey buildConnectingJourney({
  required DateTime pinnedNow,
  Flight? flight,
  Flight? inbound,
  int tick = 0,
}) {
  if (flight == null || inbound == null) {
    return Journey(
      stage: JourneyStage.connecting,
      flight: flight,
      inboundFlight: inbound,
      steps: [_connectionStep()],
      currentIndex: 0,
      pinnedNow: pinnedNow,
    );
  }

  final term = terminalLabel(flight.terminal);
  final inTerm = terminalLabel(inbound.terminal);
  final disrupted = tick >= kDisruptionTick;
  final gate = disrupted ? _kMovedGate : (flight.gate ?? '-');

  final steps = <JourneyStep>[
    _connectionStep(),
    JourneyStep(
      kind: StepKind.arrive,
      title: 'Get off and follow Transfers',
      where: '$inTerm · arrivals level',
      note: 'Landed on ${inbound.flightNumber} at gate ${inbound.gate ?? '-'}',
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
            detail:
                'Moved from ${flight.gate ?? '-'}. Tight connection - go straight there.',
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
