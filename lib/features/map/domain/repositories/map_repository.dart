import 'package:airport_nav/features/map/domain/entities/map_floor.dart';

abstract class MapRepository {
  List<MapFloor> getFloorsByAirport(String airportCode);
  MapFloor? getFloorById(String floorId);
  List<NavPath> getNavPathsForFloor(String floorId);
  NavPath? findPath(String fromPoiId, String toPoiId);
  List<PointOfInterest> searchPois(String airportCode, String query);
}
