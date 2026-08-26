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
