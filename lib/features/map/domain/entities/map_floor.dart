class MapFloor {
  final String id;
  final String airportCode;
  final String terminal;
  final int floorNumber;
  final String floorName;
  final double width;
  final double height;
  final List<PointOfInterest> pois;

  const MapFloor({
    required this.id,
    required this.airportCode,
    required this.terminal,
    required this.floorNumber,
    required this.floorName,
    required this.width,
    required this.height,
    required this.pois,
  });
}

class PointOfInterest {
  final String id;
  final String name;
  final String category;
  final double x;
  final double y;
  final String? linkedId;
  final String? icon;

  const PointOfInterest({
    required this.id,
    required this.name,
    required this.category,
    required this.x,
    required this.y,
    this.linkedId,
    this.icon,
  });
}

class NavPath {
  final String fromPoiId;
  final String toPoiId;
  final List<MapPoint> waypoints;
  final double distanceMeters;
  final int estimatedMinutes;

  const NavPath({
    required this.fromPoiId,
    required this.toPoiId,
    required this.waypoints,
    required this.distanceMeters,
    required this.estimatedMinutes,
  });
}

class MapPoint {
  final double x;
  final double y;
  const MapPoint(this.x, this.y);
}
