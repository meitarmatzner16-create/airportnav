import 'package:airport_nav/features/shops/domain/entities/shop.dart';
import 'package:airport_nav/features/lounges/domain/entities/lounge.dart';
import 'package:airport_nav/features/voice_chat/domain/entities/chat_message.dart';

class RoutePlannerService {
  static const _categoryKeywords = {
    'dining': ['food', 'eat', 'hungry', 'burger', 'sushi', 'restaurant', 'coffee', 'cafe', 'lunch', 'dinner', 'breakfast', 'meal', 'snack', 'drink', 'pizza', 'steak'],
    'duty_free': ['duty free', 'duty-free', 'tax free', 'perfume', 'fragrance', 'spirits', 'alcohol', 'wine', 'whisky', 'tobacco'],
    'luxury': ['luxury', 'designer', 'jewelry', 'jewellery', 'diamond', 'gold', 'brand', 'fashion', 'bag', 'bags', 'handbag', 'watch', 'watches'],
    'electronics': ['electronics', 'tech', 'gadget', 'phone', 'headphones', 'charger', 'laptop', 'tablet'],
    'convenience': ['convenience', 'book', 'magazine', 'snacks', 'souvenir', 'gift', 'gifts', 'newspaper'],
    'retail': ['shop', 'shopping', 'store', 'clothes', 'clothing', 'shoes', 'cosmetics', 'beauty'],
  };

  static const _stayEstimates = {
    'dining': 25,
    'duty_free': 15,
    'luxury': 20,
    'electronics': 15,
    'convenience': 10,
    'retail': 15,
    'lounge': 45,
  };

  static const _categoryLabels = {
    'dining': 'eating',
    'duty_free': 'browsing duty-free',
    'luxury': 'shopping luxury',
    'electronics': 'browsing electronics',
    'convenience': 'quick shopping',
    'retail': 'shopping',
    'lounge': 'relaxing in the lounge',
  };

  static const _styleLabels = {
    'luxury': 'Luxury',
    'fancy': 'Fancy',
    'casual': 'Casual',
    'street_vibes': 'Street Vibes',
    'fast_food': 'Fast Food',
  };

  /// Parses user-specified durations from the query.
  Map<String, int> _parseUserTimes(String query) {
    final userTimes = <String, int>{};
    final timePattern = RegExp(
      r'(\d+)\s*(?:min(?:utes?)?|hrs?|hours?)\s+(?:at\s+|for\s+|of\s+)?(\w+)|'
      r'(\w+)\s+(?:for\s+)?(\d+)\s*(?:min(?:utes?)?|hrs?|hours?)',
      caseSensitive: false,
    );

    for (final match in timePattern.allMatches(query)) {
      int? minutes;
      String? keyword;

      if (match.group(1) != null && match.group(2) != null) {
        minutes = int.tryParse(match.group(1)!);
        keyword = match.group(2)!.toLowerCase();
        if (query.contains(RegExp('${match.group(1)}\\s*(?:hrs?|hours?)'))) {
          minutes = (minutes ?? 0) * 60;
        }
      } else if (match.group(3) != null && match.group(4) != null) {
        keyword = match.group(3)!.toLowerCase();
        minutes = int.tryParse(match.group(4)!);
        if (query.contains(RegExp('${match.group(4)}\\s*(?:hrs?|hours?)'))) {
          minutes = (minutes ?? 0) * 60;
        }
      }

      if (minutes != null && keyword != null) {
        for (final entry in _categoryKeywords.entries) {
          if (entry.value.any((kw) => kw.contains(keyword!) || keyword.contains(kw))) {
            userTimes[entry.key] = minutes;
            break;
          }
        }
        if (['lounge', 'relax', 'rest', 'vip', 'chill'].contains(keyword)) {
          userTimes['lounge'] = minutes;
        }
      }
    }

    return userTimes;
  }

  /// Generates turn-by-turn directions between two stops, accounting for floor changes.
  List<NavigationStep> _generateDirections({
    required int fromFloor,
    required int toFloor,
    required String destinationName,
    required int stopIndex,
  }) {
    final steps = <NavigationStep>[];

    // Floor change
    if (fromFloor != toFloor) {
      final diff = toFloor - fromFloor;
      if (diff > 0) {
        steps.add(NavigationStep(
          instruction: 'Take the escalator up to Floor $toFloor',
          icon: 'escalator_up',
        ));
      } else {
        steps.add(NavigationStep(
          instruction: 'Take the escalator down to Floor $toFloor',
          icon: 'escalator_down',
        ));
      }
    }

    // Simulated turn-by-turn based on stop index for variety
    final directionSets = [
      [
        const NavigationStep(instruction: 'Head straight past the gates', icon: 'straight'),
        const NavigationStep(instruction: 'Turn right at the information board', icon: 'turn_right'),
      ],
      [
        const NavigationStep(instruction: 'Continue straight through the corridor', icon: 'straight'),
        const NavigationStep(instruction: 'Turn left after the restrooms', icon: 'turn_left'),
      ],
      [
        const NavigationStep(instruction: 'Walk past the security checkpoint', icon: 'straight'),
        const NavigationStep(instruction: 'Turn right at the duty-free area', icon: 'turn_right'),
        const NavigationStep(instruction: 'Continue straight for 50m', icon: 'straight'),
      ],
      [
        const NavigationStep(instruction: 'Head left along the main walkway', icon: 'turn_left'),
        const NavigationStep(instruction: 'Turn right at the food court', icon: 'turn_right'),
      ],
      [
        const NavigationStep(instruction: 'Follow signs toward the departures hall', icon: 'straight'),
        const NavigationStep(instruction: 'Turn left past the bookstore', icon: 'turn_left'),
        const NavigationStep(instruction: 'Continue straight to the end', icon: 'straight'),
      ],
    ];

    steps.addAll(directionSets[stopIndex % directionSets.length]);

    steps.add(NavigationStep(
      instruction: '$destinationName will be on your ${stopIndex.isEven ? "right" : "left"}',
      icon: 'destination',
    ));

    return steps;
  }

  RoutePlan? generateRoute({
    required String userQuery,
    required List<Shop> availableShops,
    required List<Lounge> availableLounges,
  }) {
    final query = userQuery.toLowerCase();
    final matchedStops = <RouteStop>[];
    final userTimes = _parseUserTimes(query);
    final usedAssumptions = <String>[];
    // Track floors for navigation directions
    final floors = <int>[];

    // Check for lounge requests
    if (_containsAny(query, ['lounge', 'relax', 'rest', 'vip', 'wait', 'chill'])) {
      if (availableLounges.isNotEmpty) {
        final lounge = _bestLounge(availableLounges);
        final hasUserTime = userTimes.containsKey('lounge');
        final stayMin = hasUserTime ? userTimes['lounge']! : _stayEstimates['lounge']!;
        if (!hasUserTime) {
          usedAssumptions.add('${_categoryLabels['lounge']} for $stayMin min');
        }
        floors.add(lounge.floor);
        matchedStops.add(RouteStop(
          name: lounge.name,
          category: 'lounge',
          style: lounge.style,
          floor: lounge.floor,
          location: '${lounge.terminal} - ${lounge.location}',
          walkMinutes: _estimateWalk(matchedStops.length),
          stayMinutes: stayMin,
          description: lounge.accessType == 'paid'
              ? 'Entry: ${lounge.currency} ${lounge.price?.toStringAsFixed(0) ?? "N/A"}'
              : 'Access: ${lounge.accessType}',
        ));
      }
    }

    // Match shop categories from the query
    for (final entry in _categoryKeywords.entries) {
      if (_containsAny(query, entry.value)) {
        final categoryShops = availableShops
            .where((s) => s.category == entry.key)
            .toList();
        if (categoryShops.isNotEmpty) {
          categoryShops.sort((a, b) => b.rating.compareTo(a.rating));
          final shop = categoryShops.first;
          if (!matchedStops.any((s) => s.name == shop.name)) {
            final hasUserTime = userTimes.containsKey(entry.key);
            final stayMin = hasUserTime ? userTimes[entry.key]! : (_stayEstimates[shop.category] ?? 15);
            if (!hasUserTime) {
              usedAssumptions.add('${_categoryLabels[shop.category] ?? shop.category} for $stayMin min');
            }
            floors.add(shop.floor);
            matchedStops.add(RouteStop(
              name: shop.name,
              category: shop.category,
              style: shop.style,
              floor: shop.floor,
              location: '${shop.terminal} - ${shop.location}',
              walkMinutes: _estimateWalk(matchedStops.length),
              stayMinutes: stayMin,
              description: shop.description.length > 80
                  ? '${shop.description.substring(0, 80)}...'
                  : shop.description,
            ));
          }
        }
      }
    }

    // Check for specific shop/lounge names mentioned
    for (final shop in availableShops) {
      if (query.contains(shop.name.toLowerCase()) &&
          !matchedStops.any((s) => s.name == shop.name)) {
        final hasUserTime = userTimes.containsKey(shop.category);
        final stayMin = hasUserTime ? userTimes[shop.category]! : (_stayEstimates[shop.category] ?? 15);
        if (!hasUserTime) {
          usedAssumptions.add('${_categoryLabels[shop.category] ?? shop.category} for $stayMin min');
        }
        floors.add(shop.floor);
        matchedStops.add(RouteStop(
          name: shop.name,
          category: shop.category,
          style: shop.style,
          floor: shop.floor,
          location: '${shop.terminal} - ${shop.location}',
          walkMinutes: _estimateWalk(matchedStops.length),
          stayMinutes: stayMin,
          description: shop.description.length > 80
              ? '${shop.description.substring(0, 80)}...'
              : shop.description,
        ));
      }
    }

    if (matchedStops.isEmpty) return null;

    // Recalculate walk times and add navigation directions
    final walkAssumptions = <String>[];
    int currentFloor = 1; // Assume user starts at floor 1

    for (var i = 0; i < matchedStops.length; i++) {
      final targetFloor = matchedStops[i].floor;
      // Extra walk time if floor change needed
      final floorDiff = (targetFloor - currentFloor).abs();
      final walk = (i == 0 ? 3 : 3 + (i * 3)) + (floorDiff * 2);

      final directions = _generateDirections(
        fromFloor: currentFloor,
        toFloor: targetFloor,
        destinationName: matchedStops[i].name,
        stopIndex: i,
      );

      walkAssumptions.add('walk $walk min to ${matchedStops[i].name} (Floor $targetFloor)');

      matchedStops[i] = RouteStop(
        name: matchedStops[i].name,
        category: matchedStops[i].category,
        style: matchedStops[i].style,
        floor: matchedStops[i].floor,
        location: matchedStops[i].location,
        walkMinutes: walk,
        stayMinutes: matchedStops[i].stayMinutes,
        description: matchedStops[i].description,
        directions: directions,
      );

      currentFloor = targetFloor;
    }

    final totalMinutes = matchedStops.fold<int>(
      0,
      (sum, stop) => sum + stop.walkMinutes + stop.stayMinutes,
    );

    return RoutePlan(
      stops: matchedStops,
      totalMinutes: totalMinutes,
      summary: _buildSummary(matchedStops, usedAssumptions, walkAssumptions),
    );
  }

  String _buildSummary(
    List<RouteStop> stops,
    List<String> stayAssumptions,
    List<String> walkAssumptions,
  ) {
    if (stops.isEmpty) return '';

    final buf = StringBuffer();

    for (var i = 0; i < stops.length; i++) {
      final stop = stops[i];
      final styleLabel = _styleLabels[stop.style] ?? stop.style;
      if (i == 0) {
        buf.write('Walk ${stop.walkMinutes} min to ${stop.name} ($styleLabel, Floor ${stop.floor}), ');
      } else {
        buf.write('then walk ${stop.walkMinutes} min to ${stop.name} ($styleLabel, Floor ${stop.floor}), ');
      }
      buf.write('spend ~${stop.stayMinutes} min there');
      if (i < stops.length - 1) buf.write(', ');
    }
    buf.write('.');

    if (stayAssumptions.isNotEmpty || walkAssumptions.isNotEmpty) {
      buf.write('\n\nI assumed you\'ll: ');
      final all = [...walkAssumptions, ...stayAssumptions];
      buf.write(all.join(', '));
      buf.write('. Feel free to tell me your preferred times!');
    }

    return buf.toString();
  }

  int _estimateWalk(int stopIndex) {
    return 3 + (stopIndex * 3);
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  Lounge _bestLounge(List<Lounge> lounges) {
    final sorted = List<Lounge>.from(lounges)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.first;
  }

  String getGreeting(String airportCode) {
    return "Hi! I'm your airport assistant for $airportCode. "
        "Tell me what you'd like to do - eat a burger, visit duty-free, "
        "see luxury bag shops, find a lounge, or anything else. "
        "I'll build your route based on top-rated spots with exact navigation!\n\n"
        "You can specify your timing too: "
        "\"eat burger for 30 min and see bags for 15 min\" - "
        "or I'll give you my best time estimates.";
  }

  String getNoResultsMessage() {
    return "I couldn't find matching places for that request. "
        "Try asking about food, shopping, duty-free, luxury brands, "
        "electronics, or lounges!";
  }

  String getRouteIntro(RoutePlan plan) {
    return "Here's your route (${plan.totalMinutes} min total), "
        "built from the top-rated spots:";
  }
}
