import 'package:flutter/material.dart';

/// Price band: $ (cheap) .. $$$$ (top-end).
enum PriceLevel { one, two, three, four }

extension PriceLevelX on PriceLevel {
  String get symbols => switch (this) {
        PriceLevel.one => r'$',
        PriceLevel.two => r'$$',
        PriceLevel.three => r'$$$',
        PriceLevel.four => r'$$$$',
      };
}

/// A physical facility / dietary fact about a venue - the heart of the
/// "all the airport's physical info in one place" idea.
enum Amenity {
  shower,
  showerPaid,
  napRoom,
  wifi,
  powerOutlets,
  quietZone,
  kidsArea,
  vegan,
  vegetarian,
  halal,
  alcohol,
  buffet,
  barista,
  wheelchair,
  prayerRoom,
  luggageStorage,
}

/// Icon + label for an [Amenity]. Exhaustive switch so a new value forces
/// a decision here.
class AmenityInfo {
  final IconData icon;
  final String label;
  const AmenityInfo(this.icon, this.label);

  static AmenityInfo of(Amenity a) => switch (a) {
        Amenity.shower => const AmenityInfo(Icons.shower_rounded, 'Showers'),
        Amenity.showerPaid =>
          const AmenityInfo(Icons.shower_rounded, 'Showers (\$)'),
        Amenity.napRoom => const AmenityInfo(Icons.bed_rounded, 'Nap rooms'),
        Amenity.wifi => const AmenityInfo(Icons.wifi_rounded, 'Wi-Fi'),
        Amenity.powerOutlets => const AmenityInfo(Icons.power_rounded, 'Power'),
        Amenity.quietZone =>
          const AmenityInfo(Icons.volume_off_rounded, 'Quiet zone'),
        Amenity.kidsArea =>
          const AmenityInfo(Icons.child_care_rounded, 'Kids area'),
        Amenity.vegan => const AmenityInfo(Icons.eco_rounded, 'Vegan'),
        Amenity.vegetarian => const AmenityInfo(Icons.spa_rounded, 'Vegetarian'),
        Amenity.halal => const AmenityInfo(Icons.restaurant_rounded, 'Halal'),
        Amenity.alcohol => const AmenityInfo(Icons.local_bar_rounded, 'Bar'),
        Amenity.buffet =>
          const AmenityInfo(Icons.dinner_dining_rounded, 'Buffet'),
        Amenity.barista => const AmenityInfo(Icons.coffee_rounded, 'Barista'),
        Amenity.wheelchair =>
          const AmenityInfo(Icons.accessible_rounded, 'Step-free'),
        Amenity.prayerRoom =>
          const AmenityInfo(Icons.self_improvement_rounded, 'Prayer room'),
        Amenity.luggageStorage =>
          const AmenityInfo(Icons.luggage_rounded, 'Bag storage'),
      };
}

/// Featured menu item (dining) or product (shop).
class VenueHighlight {
  final String name;
  final String? note; // "Bestseller", "Hot", "Side"
  final String price; // pre-formatted, e.g. "$5.50"
  const VenueHighlight({required this.name, this.price = '', this.note});
}

/// Lounge access rules + entry cost.
class VenueAccess {
  final List<String> rules; // ["Priority Pass", "Business / First"]
  final String? entryCost; // "$59 walk-in"
  const VenueAccess({this.rules = const [], this.entryCost});
}

/// "Best time for you" window.
class BestTimeWindow {
  final String start; // "9:36"
  final String end; // "9:54"
  final String reason; // "Fits before luxury stops - low queue"
  const BestTimeWindow(
      {required this.start, required this.end, required this.reason});
}

/// Short "how to get there" hint.
class DirectionsHint {
  final String text; // "Left at the plaza, follow B gate signs"
  final int minutes; // 6
  const DirectionsHint({required this.text, required this.minutes});
}

/// Drives the in-app styled image tile (+ optional real image override).
class VenuePhotoSpec {
  final String seed; // deterministic layout seed (usually venue id)
  final String? asset; // bundled asset path (future)
  final String? url; // network url (future)
  const VenuePhotoSpec({required this.seed, this.asset, this.url});
}
