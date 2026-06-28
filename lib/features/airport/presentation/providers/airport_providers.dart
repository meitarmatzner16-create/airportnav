import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/airport/data/repositories/airport_repository_impl.dart';
import 'package:airport_nav/features/airport/domain/entities/airport.dart';
import 'package:airport_nav/features/airport/domain/repositories/airport_repository.dart';

final airportRepositoryProvider = Provider<AirportRepository>((ref) {
  return AirportRepositoryImpl();
});

final allAirportsProvider = Provider<List<Airport>>((ref) {
  final repository = ref.watch(airportRepositoryProvider);
  return repository.getAllAirports();
});

final airportSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredAirportsProvider = Provider<List<Airport>>((ref) {
  final query = ref.watch(airportSearchQueryProvider);
  final repository = ref.watch(airportRepositoryProvider);
  return repository.searchAirports(query);
});

final airportByCodeProvider =
    Provider.family<Airport?, String>((ref, iataCode) {
  final repository = ref.watch(airportRepositoryProvider);
  return repository.getAirportByCode(iataCode);
});
