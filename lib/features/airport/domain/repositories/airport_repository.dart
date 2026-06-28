import 'package:airport_nav/features/airport/domain/entities/airport.dart';

abstract class AirportRepository {
  List<Airport> getAllAirports();
  Airport? getAirportByCode(String iataCode);
  List<Airport> searchAirports(String query);
}
