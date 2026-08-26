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
