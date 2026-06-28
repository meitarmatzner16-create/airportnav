import '../entities/flight.dart';

abstract class FlightRepository {
  List<Flight> getAllFlights();
  Flight? getFlightById(String id);
  List<Flight> searchFlights(String query);
  List<Flight> getFlightsByAirport(String airportCode);
}
