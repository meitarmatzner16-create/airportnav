import 'package:airport_nav/features/venues/domain/taxonomy/venue_taxonomy.dart';

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
  });

  List<String> get tagLabels =>
      tags.map(VenueTaxonomy.labelForTag).toList(growable: false);

  String get categoryLabel => VenueTaxonomy.labelForCategory(category);
}

enum VenueType { shop, lounge }
