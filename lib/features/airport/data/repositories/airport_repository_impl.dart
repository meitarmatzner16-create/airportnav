import 'package:airport_nav/features/airport/data/datasources/airport_mock_datasource.dart';
import 'package:airport_nav/features/airport/domain/entities/airport.dart';
import 'package:airport_nav/features/airport/domain/repositories/airport_repository.dart';

class AirportRepositoryImpl implements AirportRepository {
  final AirportMockDatasource _datasource;

  AirportRepositoryImpl({AirportMockDatasource? datasource})
      : _datasource = datasource ?? AirportMockDatasource();

  @override
  List<Airport> getAllAirports() {
    return _datasource.getAllAirports();
  }

  @override
  Airport? getAirportByCode(String iataCode) {
    final airports = _datasource.getAllAirports();
    try {
      return airports.firstWhere(
        (airport) => airport.iataCode.toUpperCase() == iataCode.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  List<Airport> searchAirports(String query) {
    if (query.isEmpty) return getAllAirports();
    final lowerQuery = query.toLowerCase();
    return _datasource.getAllAirports().where((airport) {
      return airport.iataCode.toLowerCase().contains(lowerQuery) ||
          airport.name.toLowerCase().contains(lowerQuery) ||
          airport.city.toLowerCase().contains(lowerQuery) ||
          airport.country.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
