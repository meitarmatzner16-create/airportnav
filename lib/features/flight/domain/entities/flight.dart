class Flight {
  final String id;
  final String flightNumber;
  final String airline;
  final String airlineLogo;
  final String departureAirport;
  final String departureCity;
  final String arrivalAirport;
  final String arrivalCity;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String status;
  final String? gate;
  final String? terminal;
  final int? delayMinutes;

  const Flight({
    required this.id,
    required this.flightNumber,
    required this.airline,
    required this.airlineLogo,
    required this.departureAirport,
    required this.departureCity,
    required this.arrivalAirport,
    required this.arrivalCity,
    required this.departureTime,
    required this.arrivalTime,
    required this.status,
    this.gate,
    this.terminal,
    this.delayMinutes,
  });

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

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'] as String,
      flightNumber: json['flightNumber'] as String,
      airline: json['airline'] as String,
      airlineLogo: json['airlineLogo'] as String,
      departureAirport: json['departureAirport'] as String,
      departureCity: json['departureCity'] as String,
      arrivalAirport: json['arrivalAirport'] as String,
      arrivalCity: json['arrivalCity'] as String,
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      status: json['status'] as String,
      gate: json['gate'] as String?,
      terminal: json['terminal'] as String?,
      delayMinutes: json['delayMinutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'flightNumber': flightNumber,
      'airline': airline,
      'airlineLogo': airlineLogo,
      'departureAirport': departureAirport,
      'departureCity': departureCity,
      'arrivalAirport': arrivalAirport,
      'arrivalCity': arrivalCity,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'status': status,
      'gate': gate,
      'terminal': terminal,
      'delayMinutes': delayMinutes,
    };
  }
}
