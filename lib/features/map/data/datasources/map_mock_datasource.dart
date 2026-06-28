import 'package:airport_nav/features/map/domain/entities/map_floor.dart';

class MapMockDatasource {
  List<MapFloor> getAllFloors() {
    return const [
      // ==========================================
      // JFK Terminal 1, Floor 1 (Ground / Arrivals)
      // ==========================================
      MapFloor(
        id: 'jfk-t1-f1',
        airportCode: 'JFK',
        terminal: '1',
        floorNumber: 1,
        floorName: 'Ground Floor / Arrivals',
        width: 1000,
        height: 600,
        pois: [
          // Gates along the left side
          PointOfInterest(id: 'jfk-t1-f1-a1', name: 'Gate A1', category: 'gate', x: 50, y: 80),
          PointOfInterest(id: 'jfk-t1-f1-a2', name: 'Gate A2', category: 'gate', x: 50, y: 160),
          PointOfInterest(id: 'jfk-t1-f1-a3', name: 'Gate A3', category: 'gate', x: 50, y: 240),
          PointOfInterest(id: 'jfk-t1-f1-a4', name: 'Gate A4', category: 'gate', x: 50, y: 320),
          PointOfInterest(id: 'jfk-t1-f1-a5', name: 'Gate A5', category: 'gate', x: 50, y: 400),
          // Gates along the right side
          PointOfInterest(id: 'jfk-t1-f1-a6', name: 'Gate A6', category: 'gate', x: 950, y: 80),
          PointOfInterest(id: 'jfk-t1-f1-a7', name: 'Gate A7', category: 'gate', x: 950, y: 160),
          PointOfInterest(id: 'jfk-t1-f1-a8', name: 'Gate A8', category: 'gate', x: 950, y: 240),
          PointOfInterest(id: 'jfk-t1-f1-a9', name: 'Gate A9', category: 'gate', x: 950, y: 320),
          PointOfInterest(id: 'jfk-t1-f1-a10', name: 'Gate A10', category: 'gate', x: 950, y: 400),
          // Shops in center area
          PointOfInterest(id: 'jfk-t1-f1-shop1', name: 'Duty Free Americas', category: 'shop', x: 400, y: 200, linkedId: 'shop-dfa-jfk', icon: 'store'),
          PointOfInterest(id: 'jfk-t1-f1-shop2', name: 'Hudson News', category: 'shop', x: 600, y: 200, icon: 'store'),
          PointOfInterest(id: 'jfk-t1-f1-shop3', name: 'InMotion', category: 'shop', x: 500, y: 280, icon: 'store'),
          // Restaurants
          PointOfInterest(id: 'jfk-t1-f1-rest1', name: 'Shake Shack', category: 'restaurant', x: 400, y: 380, icon: 'restaurant'),
          PointOfInterest(id: 'jfk-t1-f1-rest2', name: 'Starbucks', category: 'restaurant', x: 600, y: 380, icon: 'local_cafe'),
          // Services
          PointOfInterest(id: 'jfk-t1-f1-wc1', name: 'Restroom A', category: 'restroom', x: 250, y: 300, icon: 'wc'),
          PointOfInterest(id: 'jfk-t1-f1-wc2', name: 'Restroom B', category: 'restroom', x: 750, y: 300, icon: 'wc'),
          PointOfInterest(id: 'jfk-t1-f1-info', name: 'Information Desk', category: 'info', x: 500, y: 100, icon: 'info'),
          PointOfInterest(id: 'jfk-t1-f1-sec', name: 'Security Checkpoint', category: 'security', x: 500, y: 500, icon: 'security'),
          PointOfInterest(id: 'jfk-t1-f1-imm', name: 'Immigration', category: 'immigration', x: 500, y: 560, icon: 'badge'),
        ],
      ),

      // ==========================================
      // JFK Terminal 1, Floor 2 (Departures)
      // ==========================================
      MapFloor(
        id: 'jfk-t1-f2',
        airportCode: 'JFK',
        terminal: '1',
        floorNumber: 2,
        floorName: 'Departures',
        width: 1000,
        height: 600,
        pois: [
          // Gates along top
          PointOfInterest(id: 'jfk-t1-f2-b1', name: 'Gate B1', category: 'gate', x: 100, y: 50),
          PointOfInterest(id: 'jfk-t1-f2-b2', name: 'Gate B2', category: 'gate', x: 250, y: 50),
          PointOfInterest(id: 'jfk-t1-f2-b3', name: 'Gate B3', category: 'gate', x: 400, y: 50),
          PointOfInterest(id: 'jfk-t1-f2-b4', name: 'Gate B4', category: 'gate', x: 550, y: 50),
          PointOfInterest(id: 'jfk-t1-f2-b5', name: 'Gate B5', category: 'gate', x: 700, y: 50),
          PointOfInterest(id: 'jfk-t1-f2-b6', name: 'Gate B6', category: 'gate', x: 850, y: 50),
          // Gates along bottom
          PointOfInterest(id: 'jfk-t1-f2-b7', name: 'Gate B7', category: 'gate', x: 100, y: 550),
          PointOfInterest(id: 'jfk-t1-f2-b8', name: 'Gate B8', category: 'gate', x: 300, y: 550),
          PointOfInterest(id: 'jfk-t1-f2-b9', name: 'Gate B9', category: 'gate', x: 500, y: 550),
          PointOfInterest(id: 'jfk-t1-f2-b10', name: 'Gate B10', category: 'gate', x: 700, y: 550),
          // Lounge
          PointOfInterest(id: 'jfk-t1-f2-lounge', name: 'Plaza Premium Lounge', category: 'lounge', x: 850, y: 250, linkedId: 'lounge-plaza-jfk', icon: 'airline_seat_individual_suite'),
          // Shops
          PointOfInterest(id: 'jfk-t1-f2-shop1', name: 'Tiffany & Co.', category: 'shop', x: 300, y: 220, icon: 'store'),
          PointOfInterest(id: 'jfk-t1-f2-shop2', name: 'Michael Kors', category: 'shop', x: 500, y: 220, icon: 'store'),
          PointOfInterest(id: 'jfk-t1-f2-shop3', name: 'MAC Cosmetics', category: 'shop', x: 700, y: 220, icon: 'store'),
          // Restaurants
          PointOfInterest(id: 'jfk-t1-f2-rest1', name: 'Deep Blue Sushi', category: 'restaurant', x: 300, y: 380, icon: 'restaurant'),
          PointOfInterest(id: 'jfk-t1-f2-rest2', name: 'Bobby Van\'s Steakhouse', category: 'restaurant', x: 600, y: 380, icon: 'restaurant'),
          // Services
          PointOfInterest(id: 'jfk-t1-f2-wc1', name: 'Restroom C', category: 'restroom', x: 150, y: 300, icon: 'wc'),
          PointOfInterest(id: 'jfk-t1-f2-wc2', name: 'Restroom D', category: 'restroom', x: 850, y: 400, icon: 'wc'),
          PointOfInterest(id: 'jfk-t1-f2-info', name: 'Information Kiosk', category: 'info', x: 500, y: 300, icon: 'info'),
          PointOfInterest(id: 'jfk-t1-f2-sec', name: 'Security', category: 'security', x: 150, y: 150, icon: 'security'),
        ],
      ),

      // ==========================================
      // LAX Terminal 1, Floor 1 (Ground / Arrivals)
      // ==========================================
      MapFloor(
        id: 'lax-t1-f1',
        airportCode: 'LAX',
        terminal: '1',
        floorNumber: 1,
        floorName: 'Ground Floor / Arrivals',
        width: 1000,
        height: 600,
        pois: [
          // Gates along top
          PointOfInterest(id: 'lax-t1-f1-c1', name: 'Gate C1', category: 'gate', x: 80, y: 50),
          PointOfInterest(id: 'lax-t1-f1-c2', name: 'Gate C2', category: 'gate', x: 200, y: 50),
          PointOfInterest(id: 'lax-t1-f1-c3', name: 'Gate C3', category: 'gate', x: 320, y: 50),
          PointOfInterest(id: 'lax-t1-f1-c4', name: 'Gate C4', category: 'gate', x: 440, y: 50),
          PointOfInterest(id: 'lax-t1-f1-c5', name: 'Gate C5', category: 'gate', x: 560, y: 50),
          PointOfInterest(id: 'lax-t1-f1-c6', name: 'Gate C6', category: 'gate', x: 680, y: 50),
          PointOfInterest(id: 'lax-t1-f1-c7', name: 'Gate C7', category: 'gate', x: 800, y: 50),
          PointOfInterest(id: 'lax-t1-f1-c8', name: 'Gate C8', category: 'gate', x: 920, y: 50),
          // Shops center
          PointOfInterest(id: 'lax-t1-f1-shop1', name: 'Sunglass Hut', category: 'shop', x: 350, y: 200, icon: 'store'),
          PointOfInterest(id: 'lax-t1-f1-shop2', name: 'LA Photo Shop', category: 'shop', x: 550, y: 200, icon: 'store'),
          PointOfInterest(id: 'lax-t1-f1-shop3', name: 'Tech on the Go', category: 'shop', x: 750, y: 200, icon: 'store'),
          // Restaurants
          PointOfInterest(id: 'lax-t1-f1-rest1', name: 'Starbucks', category: 'restaurant', x: 350, y: 350, icon: 'local_cafe'),
          PointOfInterest(id: 'lax-t1-f1-rest2', name: 'Veggie Grill', category: 'restaurant', x: 550, y: 350, icon: 'restaurant'),
          PointOfInterest(id: 'lax-t1-f1-rest3', name: 'McDonald\'s', category: 'restaurant', x: 750, y: 350, icon: 'restaurant'),
          // Services
          PointOfInterest(id: 'lax-t1-f1-wc1', name: 'Restroom E', category: 'restroom', x: 200, y: 280, icon: 'wc'),
          PointOfInterest(id: 'lax-t1-f1-wc2', name: 'Restroom F', category: 'restroom', x: 850, y: 280, icon: 'wc'),
          PointOfInterest(id: 'lax-t1-f1-info', name: 'Information Desk', category: 'info', x: 500, y: 150, icon: 'info'),
          PointOfInterest(id: 'lax-t1-f1-sec', name: 'Security Checkpoint', category: 'security', x: 500, y: 480, icon: 'security'),
          PointOfInterest(id: 'lax-t1-f1-imm', name: 'Customs & Immigration', category: 'immigration', x: 500, y: 550, icon: 'badge'),
          PointOfInterest(id: 'lax-t1-f1-bag', name: 'Baggage Claim', category: 'info', x: 200, y: 520, icon: 'luggage'),
        ],
      ),

      // ==========================================
      // LAX Terminal 1, Floor 2 (Departures)
      // ==========================================
      MapFloor(
        id: 'lax-t1-f2',
        airportCode: 'LAX',
        terminal: '1',
        floorNumber: 2,
        floorName: 'Departures',
        width: 1000,
        height: 600,
        pois: [
          // Gates spread around edges
          PointOfInterest(id: 'lax-t1-f2-d1', name: 'Gate D1', category: 'gate', x: 80, y: 80),
          PointOfInterest(id: 'lax-t1-f2-d2', name: 'Gate D2', category: 'gate', x: 250, y: 80),
          PointOfInterest(id: 'lax-t1-f2-d3', name: 'Gate D3', category: 'gate', x: 420, y: 80),
          PointOfInterest(id: 'lax-t1-f2-d4', name: 'Gate D4', category: 'gate', x: 590, y: 80),
          PointOfInterest(id: 'lax-t1-f2-d5', name: 'Gate D5', category: 'gate', x: 760, y: 80),
          PointOfInterest(id: 'lax-t1-f2-d6', name: 'Gate D6', category: 'gate', x: 920, y: 80),
          PointOfInterest(id: 'lax-t1-f2-d7', name: 'Gate D7', category: 'gate', x: 80, y: 520),
          PointOfInterest(id: 'lax-t1-f2-d8', name: 'Gate D8', category: 'gate', x: 350, y: 520),
          PointOfInterest(id: 'lax-t1-f2-d9', name: 'Gate D9', category: 'gate', x: 650, y: 520),
          PointOfInterest(id: 'lax-t1-f2-d10', name: 'Gate D10', category: 'gate', x: 920, y: 520),
          // Lounge
          PointOfInterest(id: 'lax-t1-f2-lounge', name: 'Star Alliance Lounge', category: 'lounge', x: 850, y: 250, linkedId: 'lounge-star-lax', icon: 'airline_seat_individual_suite'),
          // Shops
          PointOfInterest(id: 'lax-t1-f2-shop1', name: 'Duty Free LAX', category: 'shop', x: 300, y: 230, icon: 'store'),
          PointOfInterest(id: 'lax-t1-f2-shop2', name: 'See\'s Candies', category: 'shop', x: 500, y: 230, icon: 'store'),
          // Restaurants
          PointOfInterest(id: 'lax-t1-f2-rest1', name: 'Real Food Daily', category: 'restaurant', x: 350, y: 380, icon: 'restaurant'),
          PointOfInterest(id: 'lax-t1-f2-rest2', name: 'Dunkin\'', category: 'restaurant', x: 650, y: 380, icon: 'local_cafe'),
          // Services
          PointOfInterest(id: 'lax-t1-f2-wc1', name: 'Restroom G', category: 'restroom', x: 150, y: 300, icon: 'wc'),
          PointOfInterest(id: 'lax-t1-f2-wc2', name: 'Restroom H', category: 'restroom', x: 850, y: 400, icon: 'wc'),
          PointOfInterest(id: 'lax-t1-f2-info', name: 'Info Kiosk', category: 'info', x: 500, y: 300, icon: 'info'),
          PointOfInterest(id: 'lax-t1-f2-sec', name: 'Security', category: 'security', x: 500, y: 460, icon: 'security'),
          PointOfInterest(id: 'lax-t1-f2-charge', name: 'Charging Station', category: 'info', x: 700, y: 300, icon: 'electrical_services'),
        ],
      ),
    ];
  }

  List<NavPath> getAllNavPaths() {
    return const [
      // JFK Floor 1: Gate A1 to Shake Shack
      NavPath(
        fromPoiId: 'jfk-t1-f1-a1',
        toPoiId: 'jfk-t1-f1-rest1',
        waypoints: [
          MapPoint(50, 80),
          MapPoint(150, 80),
          MapPoint(150, 300),
          MapPoint(400, 300),
          MapPoint(400, 380),
        ],
        distanceMeters: 320,
        estimatedMinutes: 4,
      ),
      // JFK Floor 1: Gate A6 to Information Desk
      NavPath(
        fromPoiId: 'jfk-t1-f1-a6',
        toPoiId: 'jfk-t1-f1-info',
        waypoints: [
          MapPoint(950, 80),
          MapPoint(750, 80),
          MapPoint(750, 100),
          MapPoint(500, 100),
        ],
        distanceMeters: 210,
        estimatedMinutes: 3,
      ),
      // JFK Floor 1: Security to Gate A3
      NavPath(
        fromPoiId: 'jfk-t1-f1-sec',
        toPoiId: 'jfk-t1-f1-a3',
        waypoints: [
          MapPoint(500, 500),
          MapPoint(250, 500),
          MapPoint(250, 240),
          MapPoint(50, 240),
        ],
        distanceMeters: 400,
        estimatedMinutes: 5,
      ),
      // JFK Floor 1: Duty Free Americas to Restroom A
      NavPath(
        fromPoiId: 'jfk-t1-f1-shop1',
        toPoiId: 'jfk-t1-f1-wc1',
        waypoints: [
          MapPoint(400, 200),
          MapPoint(300, 200),
          MapPoint(300, 300),
          MapPoint(250, 300),
        ],
        distanceMeters: 150,
        estimatedMinutes: 2,
      ),
      // JFK Floor 2: Gate B1 to Plaza Premium Lounge
      NavPath(
        fromPoiId: 'jfk-t1-f2-b1',
        toPoiId: 'jfk-t1-f2-lounge',
        waypoints: [
          MapPoint(100, 50),
          MapPoint(100, 150),
          MapPoint(500, 150),
          MapPoint(500, 250),
          MapPoint(850, 250),
        ],
        distanceMeters: 480,
        estimatedMinutes: 6,
      ),
      // JFK Floor 2: Gate B3 to Deep Blue Sushi
      NavPath(
        fromPoiId: 'jfk-t1-f2-b3',
        toPoiId: 'jfk-t1-f2-rest1',
        waypoints: [
          MapPoint(400, 50),
          MapPoint(400, 150),
          MapPoint(300, 150),
          MapPoint(300, 380),
        ],
        distanceMeters: 280,
        estimatedMinutes: 4,
      ),
      // LAX Floor 1: Gate C1 to Starbucks
      NavPath(
        fromPoiId: 'lax-t1-f1-c1',
        toPoiId: 'lax-t1-f1-rest1',
        waypoints: [
          MapPoint(80, 50),
          MapPoint(80, 150),
          MapPoint(350, 150),
          MapPoint(350, 350),
        ],
        distanceMeters: 350,
        estimatedMinutes: 4,
      ),
      // LAX Floor 1: Security to Gate C5
      NavPath(
        fromPoiId: 'lax-t1-f1-sec',
        toPoiId: 'lax-t1-f1-c5',
        waypoints: [
          MapPoint(500, 480),
          MapPoint(500, 300),
          MapPoint(560, 300),
          MapPoint(560, 50),
        ],
        distanceMeters: 300,
        estimatedMinutes: 4,
      ),
      // LAX Floor 2: Gate D1 to Star Alliance Lounge
      NavPath(
        fromPoiId: 'lax-t1-f2-d1',
        toPoiId: 'lax-t1-f2-lounge',
        waypoints: [
          MapPoint(80, 80),
          MapPoint(80, 180),
          MapPoint(500, 180),
          MapPoint(500, 250),
          MapPoint(850, 250),
        ],
        distanceMeters: 520,
        estimatedMinutes: 7,
      ),
      // LAX Floor 2: Gate D4 to Dunkin'
      NavPath(
        fromPoiId: 'lax-t1-f2-d4',
        toPoiId: 'lax-t1-f2-rest2',
        waypoints: [
          MapPoint(590, 80),
          MapPoint(590, 200),
          MapPoint(650, 200),
          MapPoint(650, 380),
        ],
        distanceMeters: 220,
        estimatedMinutes: 3,
      ),
    ];
  }
}
