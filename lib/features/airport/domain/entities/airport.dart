class AirportWeather {
  final double tempCelsius;
  final String condition; // sunny, cloudy, rainy, snowy
  final String icon; // emoji or icon name

  const AirportWeather({
    required this.tempCelsius,
    required this.condition,
    required this.icon,
  });

  factory AirportWeather.fromJson(Map<String, dynamic> json) {
    return AirportWeather(
      tempCelsius: (json['tempCelsius'] as num).toDouble(),
      condition: json['condition'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tempCelsius': tempCelsius,
      'condition': condition,
      'icon': icon,
    };
  }
}

class Airport {
  final String iataCode;
  final String name;
  final String city;
  final String country;
  final String imageUrl;
  final List<String> terminals;
  final List<String> facilities;
  final double latitude;
  final double longitude;
  final String timezone;
  final AirportWeather? weather;

  const Airport({
    required this.iataCode,
    required this.name,
    required this.city,
    required this.country,
    required this.imageUrl,
    required this.terminals,
    required this.facilities,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.weather,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    return Airport(
      iataCode: json['iataCode'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      imageUrl: json['imageUrl'] as String,
      terminals: List<String>.from(json['terminals'] as List),
      facilities: List<String>.from(json['facilities'] as List),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String,
      weather: json['weather'] != null
          ? AirportWeather.fromJson(json['weather'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iataCode': iataCode,
      'name': name,
      'city': city,
      'country': country,
      'imageUrl': imageUrl,
      'terminals': terminals,
      'facilities': facilities,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'weather': weather?.toJson(),
    };
  }
}
