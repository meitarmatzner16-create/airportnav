class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final RoutePlan? routePlan;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.routePlan,
  });
}

class RoutePlan {
  final List<RouteStop> stops;
  final int totalMinutes;
  final String summary;

  const RoutePlan({
    required this.stops,
    required this.totalMinutes,
    required this.summary,
  });

  RoutePlan copyWith({
    List<RouteStop>? stops,
    int? totalMinutes,
    String? summary,
  }) {
    return RoutePlan(
      stops: stops ?? this.stops,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      summary: summary ?? this.summary,
    );
  }
}

class RouteStop {
  final String name;
  final String category;
  final String style;
  final int floor;
  final String location;
  final int walkMinutes;
  final int stayMinutes;
  final String? description;
  final List<NavigationStep> directions;

  const RouteStop({
    required this.name,
    required this.category,
    required this.style,
    required this.floor,
    required this.location,
    required this.walkMinutes,
    required this.stayMinutes,
    this.description,
    this.directions = const [],
  });

  RouteStop copyWith({
    String? name,
    String? category,
    String? style,
    int? floor,
    String? location,
    int? walkMinutes,
    int? stayMinutes,
    String? description,
    List<NavigationStep>? directions,
  }) {
    return RouteStop(
      name: name ?? this.name,
      category: category ?? this.category,
      style: style ?? this.style,
      floor: floor ?? this.floor,
      location: location ?? this.location,
      walkMinutes: walkMinutes ?? this.walkMinutes,
      stayMinutes: stayMinutes ?? this.stayMinutes,
      description: description ?? this.description,
      directions: directions ?? this.directions,
    );
  }
}

class NavigationStep {
  final String instruction; // e.g. "Turn left", "Go up to Floor 2"
  final String icon; // e.g. 'turn_left', 'stairs_up', 'elevator_up', 'straight'

  const NavigationStep({
    required this.instruction,
    required this.icon,
  });
}
