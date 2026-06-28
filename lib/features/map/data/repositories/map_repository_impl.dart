import 'package:airport_nav/features/map/data/datasources/map_mock_datasource.dart';
import 'package:airport_nav/features/map/domain/entities/map_floor.dart';
import 'package:airport_nav/features/map/domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  final MapMockDatasource _datasource;

  MapRepositoryImpl({MapMockDatasource? datasource})
      : _datasource = datasource ?? MapMockDatasource();

  @override
  List<MapFloor> getFloorsByAirport(String airportCode) {
    final code = airportCode.toUpperCase();
    return _datasource
        .getAllFloors()
        .where((floor) => floor.airportCode.toUpperCase() == code)
        .toList();
  }

  @override
  MapFloor? getFloorById(String floorId) {
    try {
      return _datasource
          .getAllFloors()
          .firstWhere((floor) => floor.id == floorId);
    } catch (_) {
      return null;
    }
  }

  @override
  List<NavPath> getNavPathsForFloor(String floorId) {
    final floor = getFloorById(floorId);
    if (floor == null) return [];
    final poiIds = floor.pois.map((p) => p.id).toSet();
    return _datasource.getAllNavPaths().where((path) {
      return poiIds.contains(path.fromPoiId) || poiIds.contains(path.toPoiId);
    }).toList();
  }

  @override
  NavPath? findPath(String fromPoiId, String toPoiId) {
    try {
      return _datasource.getAllNavPaths().firstWhere(
            (path) =>
                (path.fromPoiId == fromPoiId && path.toPoiId == toPoiId) ||
                (path.fromPoiId == toPoiId && path.toPoiId == fromPoiId),
          );
    } catch (_) {
      return null;
    }
  }

  @override
  List<PointOfInterest> searchPois(String airportCode, String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    final floors = getFloorsByAirport(airportCode);
    final results = <PointOfInterest>[];
    for (final floor in floors) {
      results.addAll(floor.pois.where((poi) {
        return poi.name.toLowerCase().contains(lowerQuery) ||
            poi.category.toLowerCase().contains(lowerQuery);
      }));
    }
    return results;
  }
}
