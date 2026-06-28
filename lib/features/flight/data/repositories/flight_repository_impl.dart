import '../../domain/entities/flight.dart';
import '../../domain/repositories/flight_repository.dart';
import '../datasources/flight_mock_datasource.dart';

class FlightRepositoryImpl implements FlightRepository {
  final FlightMockDatasource _datasource;

  FlightRepositoryImpl(this._datasource);

  @override
  List<Flight> getAllFlights() {
    return _datasource.getAllFlights();
  }

  @override
  Flight? getFlightById(String id) {
    final flights = _datasource.getAllFlights();
    try {
      return flights.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Flight> searchFlights(String query) {
    final flights = _datasource.getAllFlights();
    final lowerQuery = query.toLowerCase();
    return flights.where((f) {
      return f.flightNumber.toLowerCase().contains(lowerQuery) ||
          f.airline.toLowerCase().contains(lowerQuery) ||
          f.departureCity.toLowerCase().contains(lowerQuery) ||
          f.arrivalCity.toLowerCase().contains(lowerQuery) ||
          f.departureAirport.toLowerCase().contains(lowerQuery) ||
          f.arrivalAirport.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  List<Flight> getFlightsByAirport(String airportCode) {
    final flights = _datasource.getAllFlights();
    final code = airportCode.toUpperCase();
    return flights.where((f) {
      return f.departureAirport == code || f.arrivalAirport == code;
    }).toList();
  }
}
