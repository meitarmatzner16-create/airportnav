class Shop {
  final String id;
  final String airportCode;
  final String terminal;
  final String name;
  final String category;
  final String style; // 'luxury', 'fancy', 'casual', 'street_vibes', 'fast_food'
  final int floor;
  final String description;
  final String imageUrl;
  final String openingHours;
  final double rating;
  final String location;
  final double? mapX;
  final double? mapY;

  const Shop({
    required this.id,
    required this.airportCode,
    required this.terminal,
    required this.name,
    required this.category,
    required this.style,
    required this.floor,
    required this.description,
    required this.imageUrl,
    required this.openingHours,
    required this.rating,
    required this.location,
    this.mapX,
    this.mapY,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as String,
      airportCode: json['airportCode'] as String,
      terminal: json['terminal'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      style: json['style'] as String? ?? 'casual',
      floor: json['floor'] as int? ?? 1,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      openingHours: json['openingHours'] as String,
      rating: (json['rating'] as num).toDouble(),
      location: json['location'] as String,
      mapX: (json['mapX'] as num?)?.toDouble(),
      mapY: (json['mapY'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'airportCode': airportCode,
      'terminal': terminal,
      'name': name,
      'category': category,
      'style': style,
      'floor': floor,
      'description': description,
      'imageUrl': imageUrl,
      'openingHours': openingHours,
      'rating': rating,
      'location': location,
      'mapX': mapX,
      'mapY': mapY,
    };
  }
}
