class Lounge {
  final String id;
  final String airportCode;
  final String terminal;
  final String name;
  final String accessType;
  final String style; // 'luxury', 'fancy', 'casual'
  final int floor;
  final double? price;
  final String currency;
  final List<String> amenities;
  final String entryConditions;
  final String openingHours;
  final double rating;
  final String imageUrl;
  final String location;
  final double? mapX;
  final double? mapY;

  const Lounge({
    required this.id,
    required this.airportCode,
    required this.terminal,
    required this.name,
    required this.accessType,
    required this.style,
    required this.floor,
    this.price,
    required this.currency,
    required this.amenities,
    required this.entryConditions,
    required this.openingHours,
    required this.rating,
    required this.imageUrl,
    required this.location,
    this.mapX,
    this.mapY,
  });

  factory Lounge.fromJson(Map<String, dynamic> json) {
    return Lounge(
      id: json['id'] as String,
      airportCode: json['airportCode'] as String,
      terminal: json['terminal'] as String,
      name: json['name'] as String,
      accessType: json['accessType'] as String,
      style: json['style'] as String? ?? 'fancy',
      floor: json['floor'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble(),
      currency: json['currency'] as String,
      amenities: List<String>.from(json['amenities'] as List),
      entryConditions: json['entryConditions'] as String,
      openingHours: json['openingHours'] as String,
      rating: (json['rating'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
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
      'accessType': accessType,
      'style': style,
      'floor': floor,
      'price': price,
      'currency': currency,
      'amenities': amenities,
      'entryConditions': entryConditions,
      'openingHours': openingHours,
      'rating': rating,
      'imageUrl': imageUrl,
      'location': location,
      'mapX': mapX,
      'mapY': mapY,
    };
  }
}
