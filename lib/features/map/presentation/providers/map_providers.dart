import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/map/data/repositories/map_repository_impl.dart';
import 'package:airport_nav/features/map/domain/entities/map_floor.dart';
import 'package:airport_nav/features/map/domain/repositories/map_repository.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepositoryImpl();
});

final selectedMapAirportProvider = StateProvider<String>((ref) => 'JFK');

final airportFloorsProvider = Provider<List<MapFloor>>((ref) {
  final airportCode = ref.watch(selectedMapAirportProvider);
  final repository = ref.watch(mapRepositoryProvider);
  return repository.getFloorsByAirport(airportCode);
});

final selectedFloorIndexProvider = StateProvider<int>((ref) => 0);

final selectedFloorProvider = Provider<MapFloor?>((ref) {
  final floors = ref.watch(airportFloorsProvider);
  final index = ref.watch(selectedFloorIndexProvider);
  if (floors.isEmpty || index >= floors.length) return null;
  return floors[index];
});

final floorPoisProvider = Provider<List<PointOfInterest>>((ref) {
  final floor = ref.watch(selectedFloorProvider);
  return floor?.pois ?? [];
});

final selectedPoiProvider = StateProvider<PointOfInterest?>((ref) => null);

final navigationFromPoiProvider = StateProvider<PointOfInterest?>((ref) => null);
final navigationToPoiProvider = StateProvider<PointOfInterest?>((ref) => null);

final activeNavPathProvider = Provider<NavPath?>((ref) {
  final from = ref.watch(navigationFromPoiProvider);
  final to = ref.watch(navigationToPoiProvider);
  if (from == null || to == null) return null;
  final repository = ref.watch(mapRepositoryProvider);
  return repository.findPath(from.id, to.id);
});

final mapSearchQueryProvider = StateProvider<String>((ref) => '');

final mapSearchResultsProvider = Provider<List<PointOfInterest>>((ref) {
  final query = ref.watch(mapSearchQueryProvider);
  final airportCode = ref.watch(selectedMapAirportProvider);
  final repository = ref.watch(mapRepositoryProvider);
  return repository.searchPois(airportCode, query);
});
