import '../entities/venue.dart';
import '../entities/venue_details.dart';

/// A patch of rich detail applied onto a base [Venue], keyed by normalized name.
class VenueDetailsPatch {
  final int? walkMinutes;
  final String? nearestGate;
  final int? avgVisitMinutes;
  final int? reviewCount;
  final PriceLevel? priceLevel;
  final Set<Amenity>? amenities;
  final VenueAccess? access;
  final List<VenueHighlight>? highlights;
  final BestTimeWindow? bestTime;
  final DirectionsHint? directions;
  const VenueDetailsPatch({
    this.walkMinutes,
    this.nearestGate,
    this.avgVisitMinutes,
    this.reviewCount,
    this.priceLevel,
    this.amenities,
    this.access,
    this.highlights,
    this.bestTime,
    this.directions,
  });
}

String normalizeVenueKey(String name) => name.trim().toLowerCase();

/// Deterministic 2-12 min walk derived from the venue id when none is set.
int _derivedWalk(Venue v) => 2 + (v.id.hashCode.abs() % 11);

/// Applies the catalog patch (if any) + fills sensible defaults so every
/// venue renders. Pure function - unit tested.
Venue enrichVenue(Venue v) {
  final patch = venueDetailsCatalog[normalizeVenueKey(v.name)];
  return v.copyWith(
    photo: VenuePhotoSpec(seed: v.id),
    walkMinutes: v.walkMinutes ?? patch?.walkMinutes ?? _derivedWalk(v),
    nearestGate: patch?.nearestGate,
    avgVisitMinutes: patch?.avgVisitMinutes,
    reviewCount: patch?.reviewCount,
    priceLevel: patch?.priceLevel,
    amenities: patch?.amenities,
    access: patch?.access,
    highlights: patch?.highlights,
    bestTime: patch?.bestTime,
    directions: patch?.directions,
  );
}

/// Rich detail for the JFK demo set. Keyed by normalized venue name.
/// Lounges carry the physical-info payload (showers, nap rooms, cost); dining
/// carries menu highlights; shops carry featured products.
const Map<String, VenueDetailsPatch> venueDetailsCatalog = {
  // ─────────────────────────── Lounges ───────────────────────────
  'admirals club': VenueDetailsPatch(
    walkMinutes: 5,
    nearestGate: 'B20',
    avgVisitMinutes: 55,
    reviewCount: 284,
    priceLevel: PriceLevel.three,
    amenities: {
      Amenity.wifi,
      Amenity.powerOutlets,
      Amenity.buffet,
      Amenity.alcohol,
      Amenity.barista,
      Amenity.quietZone,
      Amenity.wheelchair,
    },
    access: VenueAccess(
      rules: ['AA First / Business', 'Admirals Club members', 'One World Sapphire'],
      entryCost: r'$79 day pass',
    ),
    bestTime: BestTimeWindow(
        start: '8:40', end: '9:20', reason: 'Calm before the mid-morning bank - easy seating'),
    directions: DirectionsHint(text: 'Level 3, above the B20 gate cluster', minutes: 5),
  ),
  'centurion lounge': VenueDetailsPatch(
    walkMinutes: 7,
    nearestGate: 'B28',
    avgVisitMinutes: 65,
    reviewCount: 540,
    priceLevel: PriceLevel.four,
    amenities: {
      Amenity.shower,
      Amenity.napRoom,
      Amenity.wifi,
      Amenity.powerOutlets,
      Amenity.buffet,
      Amenity.alcohol,
      Amenity.barista,
      Amenity.quietZone,
      Amenity.vegan,
      Amenity.wheelchair,
    },
    access: VenueAccess(
      rules: ['Amex Platinum / Centurion', 'Priority Pass select'],
      entryCost: r'$59 walk-in',
    ),
    bestTime: BestTimeWindow(
        start: '9:10', end: '9:40', reason: 'Before the rush - shortest shower-suite wait'),
    directions:
        DirectionsHint(text: 'Up to Level 3, past the duty-free hall toward B28', minutes: 7),
  ),

  // ────────────────────────── Dining / coffee ─────────────────────────
  'shake shack': VenueDetailsPatch(
    walkMinutes: 6,
    nearestGate: 'B20',
    avgVisitMinutes: 20,
    reviewCount: 312,
    priceLevel: PriceLevel.two,
    amenities: {Amenity.vegetarian},
    highlights: [
      VenueHighlight(name: 'ShackBurger', note: 'Bestseller', price: r'$8.19'),
      VenueHighlight(name: 'Cheese fries', note: 'Side', price: r'$4.50'),
      VenueHighlight(name: 'Vanilla shake', price: r'$5.25'),
    ],
    bestTime: BestTimeWindow(
        start: '9:36', end: '9:54', reason: 'Fits before luxury stops - low queue'),
    directions: DirectionsHint(text: 'Left at the plaza, follow B gate signs', minutes: 6),
  ),
  'sbarro': VenueDetailsPatch(
    walkMinutes: 4,
    nearestGate: 'B12',
    avgVisitMinutes: 15,
    reviewCount: 176,
    priceLevel: PriceLevel.one,
    amenities: {Amenity.vegetarian},
    highlights: [
      VenueHighlight(name: 'NY cheese slice', note: 'Bestseller', price: r'$5.50'),
      VenueHighlight(name: 'Pepperoni stromboli', note: 'Hot', price: r'$8.25'),
      VenueHighlight(name: 'Garlic knots (6)', note: 'Side', price: r'$4.00'),
    ],
    bestTime: BestTimeWindow(
        start: '11:30', end: '11:50', reason: 'Just before the lunch surge'),
    directions: DirectionsHint(text: 'Center of the B food court', minutes: 4),
  ),
  'la colombe coffee': VenueDetailsPatch(
    walkMinutes: 3,
    nearestGate: 'B24',
    avgVisitMinutes: 8,
    reviewCount: 142,
    priceLevel: PriceLevel.two,
    amenities: {Amenity.barista, Amenity.vegan, Amenity.vegetarian},
    highlights: [
      VenueHighlight(name: 'Draft latte', note: 'Bestseller', price: r'$5.75'),
      VenueHighlight(name: 'Oat cortado', price: r'$4.95'),
      VenueHighlight(name: 'Almond croissant', note: 'Bakery', price: r'$4.25'),
    ],
    bestTime: BestTimeWindow(start: '9:05', end: '9:20', reason: 'Fresh pull, no line'),
    directions: DirectionsHint(text: 'Right of the B concourse atrium', minutes: 3),
  ),
  'blue bottle coffee': VenueDetailsPatch(
    walkMinutes: 2,
    nearestGate: 'B22',
    avgVisitMinutes: 7,
    reviewCount: 198,
    priceLevel: PriceLevel.two,
    amenities: {Amenity.barista, Amenity.vegan, Amenity.vegetarian},
    highlights: [
      VenueHighlight(name: 'New Orleans iced', note: 'Bestseller', price: r'$5.50'),
      VenueHighlight(name: 'Gibraltar', price: r'$4.75'),
      VenueHighlight(name: 'Liege waffle', note: 'Sweet', price: r'$5.00'),
    ],
    bestTime: BestTimeWindow(
        start: '8:50', end: '9:10', reason: 'Central Plaza - quick in and out'),
    directions: DirectionsHint(text: 'Central Plaza, opposite the flight boards', minutes: 2),
  ),
  'shiro of japan': VenueDetailsPatch(
    walkMinutes: 5,
    nearestGate: 'B26',
    avgVisitMinutes: 35,
    reviewCount: 221,
    priceLevel: PriceLevel.three,
    amenities: {Amenity.alcohol, Amenity.vegetarian},
    highlights: [
      VenueHighlight(name: 'Salmon avocado roll', note: 'Bestseller', price: r'$12.00'),
      VenueHighlight(name: 'Chicken teriyaki', note: 'Hot', price: r'$16.50'),
      VenueHighlight(name: 'Edamame', note: 'Side', price: r'$6.00'),
    ],
    bestTime: BestTimeWindow(
        start: '12:10', end: '12:35', reason: 'Sit-down - beat the lunch wait'),
    directions: DirectionsHint(text: 'Concourse B, near the B26 rotunda', minutes: 5),
  ),

  // ───────────────────────────── Shops ─────────────────────────────
  'duty free americas': VenueDetailsPatch(
    walkMinutes: 4,
    nearestGate: 'B18',
    avgVisitMinutes: 18,
    reviewCount: 402,
    priceLevel: PriceLevel.three,
    highlights: [
      VenueHighlight(name: 'Fragrance & beauty', note: 'Tax-free'),
      VenueHighlight(name: 'Spirits & wine'),
      VenueHighlight(name: 'Sunglasses'),
    ],
    directions: DirectionsHint(text: 'Main duty-free hall, Level 2', minutes: 4),
  ),
  'hudson news': VenueDetailsPatch(
    walkMinutes: 2,
    nearestGate: 'B14',
    avgVisitMinutes: 6,
    reviewCount: 88,
    priceLevel: PriceLevel.one,
    highlights: [
      VenueHighlight(name: 'Travel essentials'),
      VenueHighlight(name: 'Snacks & drinks'),
      VenueHighlight(name: 'Magazines'),
    ],
    directions: DirectionsHint(text: 'By the B14 walkway', minutes: 2),
  ),
  'inmotion entertainment': VenueDetailsPatch(
    walkMinutes: 3,
    nearestGate: 'B16',
    avgVisitMinutes: 10,
    reviewCount: 63,
    priceLevel: PriceLevel.three,
    highlights: [
      VenueHighlight(name: 'Headphones', note: 'Popular'),
      VenueHighlight(name: 'Chargers & cables'),
      VenueHighlight(name: 'Travel adapters'),
    ],
    directions: DirectionsHint(text: 'Level 1, near the B16 escalators', minutes: 3),
  ),
};
