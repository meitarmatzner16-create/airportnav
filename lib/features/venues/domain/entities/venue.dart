import 'package:airport_nav/features/venues/domain/taxonomy/venue_taxonomy.dart';
import 'package:airport_nav/features/venues/domain/entities/venue_details.dart';

/// Unified venue model that wraps both shops and lounges
/// for the Venues search & browse experience.
class Venue {
  final String id;
  final String name;
  final String category; // see VenueTaxonomy.categories
  final String style;
  final List<String> tags; // subcategory keywords from VenueTaxonomy.tags
  final List<String> items; // specific products/dishes the venue sells
  final String airportCode;
  final String terminal;
  final int floor;
  final String location;
  final double rating;
  final String openingHours;
  final String description;
  final VenueType type; // shop or lounge
  final String? logoUrl;

  // ── Rich detail layer (optional; enriched via venue_details_catalog) ──
  final int? walkMinutes;
  final String? nearestGate;
  final int? avgVisitMinutes;
  final int? reviewCount;
  final PriceLevel? priceLevel;
  final bool isOpenNow;
  final Set<Amenity> amenities;
  final VenueAccess? access;
  final List<VenueHighlight> highlights;
  final BestTimeWindow? bestTime;
  final DirectionsHint? directions;
  final VenuePhotoSpec? photo;

  const Venue({
    required this.id,
    required this.name,
    required this.category,
    required this.style,
    required this.airportCode,
    required this.terminal,
    required this.floor,
    required this.location,
    required this.rating,
    required this.openingHours,
    required this.description,
    required this.type,
    this.tags = const [],
    this.items = const [],
    this.logoUrl,
    this.walkMinutes,
    this.nearestGate,
    this.avgVisitMinutes,
    this.reviewCount,
    this.priceLevel,
    this.isOpenNow = true,
    this.amenities = const {},
    this.access,
    this.highlights = const [],
    this.bestTime,
    this.directions,
    this.photo,
  });

  List<String> get tagLabels =>
      tags.map(VenueTaxonomy.labelForTag).toList(growable: false);

  String get categoryLabel => VenueTaxonomy.labelForCategory(category);

  Venue copyWith({
    int? walkMinutes,
    String? nearestGate,
    int? avgVisitMinutes,
    int? reviewCount,
    PriceLevel? priceLevel,
    bool? isOpenNow,
    Set<Amenity>? amenities,
    VenueAccess? access,
    List<VenueHighlight>? highlights,
    BestTimeWindow? bestTime,
    DirectionsHint? directions,
    VenuePhotoSpec? photo,
  }) =>
      Venue(
        id: id,
        name: name,
        category: category,
        style: style,
        airportCode: airportCode,
        terminal: terminal,
        floor: floor,
        location: location,
        rating: rating,
        openingHours: openingHours,
        description: description,
        type: type,
        tags: tags,
        items: items,
        logoUrl: logoUrl,
        walkMinutes: walkMinutes ?? this.walkMinutes,
        nearestGate: nearestGate ?? this.nearestGate,
        avgVisitMinutes: avgVisitMinutes ?? this.avgVisitMinutes,
        reviewCount: reviewCount ?? this.reviewCount,
        priceLevel: priceLevel ?? this.priceLevel,
        isOpenNow: isOpenNow ?? this.isOpenNow,
        amenities: amenities ?? this.amenities,
        access: access ?? this.access,
        highlights: highlights ?? this.highlights,
        bestTime: bestTime ?? this.bestTime,
        directions: directions ?? this.directions,
        photo: photo ?? this.photo,
      );
}

enum VenueType { shop, lounge }
