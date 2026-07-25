# Explore Page + Rich Venue Detail — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the venue browse experience into an "Explore" page and add a category-adaptive Venue detail page built around the airport's physical facts (showers, nap rooms, vegan, cost), with in-app styled photos.

**Architecture:** Extend the unified `Venue` model with an optional rich-detail layer; enrich specific JFK venues through a name-keyed catalog applied in `allVenuesProvider`. New Riverpod providers drive Explore filtering/sorting and favorites. Two new screens (restyled Explore, new adaptive detail) + one shared `VenueImage` widget. Detail is a full-screen route.

**Tech Stack:** Flutter (Dart 3), Riverpod, go_router, google_fonts (Nunito). Existing tokens: `AppColors`, `AppSpacing`, `AppTypography`, `AppShadows`, `AppCard`.

## Global Constraints

- **Commits:** The user commits ONLY when they ask. Each task ends with a **Checkpoint** (stage changes, run `flutter analyze` + tests) — do **NOT** run `git commit` unless the user explicitly asks. When they do, use the trailer `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.
- **Typography:** single **Nunito** family via `AppTypography`/theme text styles. No hardcoded fonts.
- **Palette:** sky-blue accent (`AppColors.sky` `#3577E7`), `ink`, `paper`, neutral chips (`surfaceVariant`). **No gold.** Use tokens only — no ad-hoc `Color(0x…)` in feature code.
- **Copy:** visible text uses the hyphen-minus `-` only. No em/en dashes.
- **No brand logo artwork.** Venue imagery is the styled `VenueImage` tile (gradient + generic category icon), never a reproduced brand logo.
- **TDD altitude:** test-first for model/provider/logic and key widget *behavior* (renders the right sections, no overflow). Pure-visual styling is verified by `flutter analyze` + an emulator screenshot checkpoint, not unit tests.
- **Verify command (device):** adb at `C:\Users\Haim\AppData\Local\Android\Sdk\platform-tools\adb.exe`, device `emulator-5554`. Build with `flutter build apk --release` (desktop platforms are disabled to avoid the Windows symlink requirement).

---

## File Structure

**Create:**
- `lib/features/venues/domain/entities/venue_details.dart` — `Amenity`, `AmenityInfo`, `PriceLevel`(+ext), `VenueHighlight`, `VenueAccess`, `BestTimeWindow`, `DirectionsHint`, `VenuePhotoSpec`.
- `lib/features/venues/domain/catalog/venue_details_catalog.dart` — `VenueDetailsPatch`, `venueDetailsCatalog`, `normalizeVenueKey`, `enrichVenue`.
- `lib/features/venues/presentation/providers/explore_providers.dart` — `ExploreFilter`, `exploreFilterProvider`, `exploreVenuesProvider`, `venueByIdProvider`, `favoriteVenuesProvider`.
- `lib/core/widgets/venue_image.dart` — `VenueImage` styled tile.
- `lib/features/venues/presentation/screens/venue_detail_screen.dart` — adaptive detail page.
- `lib/features/venues/presentation/widgets/explore_venue_card.dart` — Explore list card.
- Tests: `test/features/venues/venue_details_test.dart`, `test/features/venues/explore_providers_test.dart`, `test/core/venue_image_test.dart`, `test/features/venues/venue_detail_screen_test.dart`, `test/features/venues/explore_screen_test.dart`.

**Modify:**
- `lib/features/venues/domain/entities/venue.dart` — add optional rich fields + `copyWith`.
- `lib/features/venues/presentation/providers/venue_providers.dart` — map venues through `enrichVenue`.
- `lib/features/venues/presentation/screens/venues_screen.dart` → restyle to Explore (rename file to `explore_screen.dart`, class `ExploreScreen`).
- `lib/core/router/app_router.dart` — rename `/venues` → `/explore`; add `/explore/venue/:id`.
- `lib/core/widgets/app_shell.dart` — Search tab → label "Explore", route `/explore`, icon `Icons.travel_explore_rounded`.
- Inbound refs to `/venues` (e.g. Home quick-start "Food & Drinks", `venues_screen` Map pill) → `/explore`.
- `lib/features/venues/data/datasources/*` or lounge/shop mock — ensure mockup venues exist (Sbarro, Shake Shack, La Colombe Coffee, Blue Bottle, Shiro of Japan).

---

## Task 1: Venue detail types + model extension

**Files:**
- Create: `lib/features/venues/domain/entities/venue_details.dart`
- Modify: `lib/features/venues/domain/entities/venue.dart`
- Test: `test/features/venues/venue_details_test.dart`

**Interfaces:**
- Produces: `enum Amenity`, `class AmenityInfo { IconData icon; String label; static AmenityInfo of(Amenity) }`, `enum PriceLevel` + `extension PriceLevelX { String get symbols }`, `class VenueHighlight { String name; String? note; String price }`, `class VenueAccess { List<String> rules; String? entryCost }`, `class BestTimeWindow { String start,end,reason }`, `class DirectionsHint { String text; int minutes }`, `class VenuePhotoSpec { String seed; String? asset,url }`.
- Produces on `Venue`: new fields `int? walkMinutes; String? nearestGate; int? avgVisitMinutes; int? reviewCount; PriceLevel? priceLevel; bool isOpenNow; Set<Amenity> amenities; VenueAccess? access; List<VenueHighlight> highlights; BestTimeWindow? bestTime; DirectionsHint? directions; VenuePhotoSpec? photo;` and `Venue copyWith({...})`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/venues/venue_details_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/features/venues/domain/entities/venue_details.dart';

void main() {
  test('AmenityInfo.of is total and labels use hyphen-minus only', () {
    for (final a in Amenity.values) {
      final info = AmenityInfo.of(a);
      expect(info.label, isNotEmpty);
      expect(info.label.contains('–'), isFalse); // en dash
      expect(info.label.contains('—'), isFalse); // em dash
      expect(info.icon, isA<IconData>());
    }
  });

  test('PriceLevel symbols render \$..\$\$\$\$', () {
    expect(PriceLevel.one.symbols, r'$');
    expect(PriceLevel.four.symbols, r'$$$$');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/venues/venue_details_test.dart`
Expected: FAIL (target of URI doesn't exist / `Amenity` undefined).

- [ ] **Step 3: Create `venue_details.dart`** with the full contents:

```dart
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
  shower, showerPaid, napRoom, wifi, powerOutlets, quietZone, kidsArea,
  vegan, vegetarian, halal, alcohol, buffet, barista,
  wheelchair, prayerRoom, luggageStorage,
}

/// Icon + label for an [Amenity]. Exhaustive switch so a new value forces
/// a decision here.
class AmenityInfo {
  final IconData icon;
  final String label;
  const AmenityInfo(this.icon, this.label);

  static AmenityInfo of(Amenity a) => switch (a) {
        Amenity.shower => const AmenityInfo(Icons.shower_rounded, 'Showers'),
        Amenity.showerPaid => const AmenityInfo(Icons.shower_rounded, 'Showers (\$)'),
        Amenity.napRoom => const AmenityInfo(Icons.bed_rounded, 'Nap rooms'),
        Amenity.wifi => const AmenityInfo(Icons.wifi_rounded, 'Wi-Fi'),
        Amenity.powerOutlets => const AmenityInfo(Icons.power_rounded, 'Power'),
        Amenity.quietZone => const AmenityInfo(Icons.volume_off_rounded, 'Quiet zone'),
        Amenity.kidsArea => const AmenityInfo(Icons.child_care_rounded, 'Kids area'),
        Amenity.vegan => const AmenityInfo(Icons.eco_rounded, 'Vegan'),
        Amenity.vegetarian => const AmenityInfo(Icons.spa_rounded, 'Vegetarian'),
        Amenity.halal => const AmenityInfo(Icons.restaurant_rounded, 'Halal'),
        Amenity.alcohol => const AmenityInfo(Icons.local_bar_rounded, 'Bar'),
        Amenity.buffet => const AmenityInfo(Icons.dinner_dining_rounded, 'Buffet'),
        Amenity.barista => const AmenityInfo(Icons.coffee_rounded, 'Barista'),
        Amenity.wheelchair => const AmenityInfo(Icons.accessible_rounded, 'Step-free'),
        Amenity.prayerRoom => const AmenityInfo(Icons.self_improvement_rounded, 'Prayer room'),
        Amenity.luggageStorage => const AmenityInfo(Icons.luggage_rounded, 'Bag storage'),
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
  final List<String> rules;   // ["Priority Pass", "Business / First"]
  final String? entryCost;    // "$59 walk-in"
  const VenueAccess({this.rules = const [], this.entryCost});
}

/// "Best time for you" window.
class BestTimeWindow {
  final String start;  // "9:36"
  final String end;    // "9:54"
  final String reason; // "Fits before luxury stops - low queue"
  const BestTimeWindow({required this.start, required this.end, required this.reason});
}

/// Short "how to get there" hint.
class DirectionsHint {
  final String text;  // "Left at the plaza, follow B gate signs"
  final int minutes;  // 6
  const DirectionsHint({required this.text, required this.minutes});
}

/// Drives the in-app styled image tile (+ optional real image override).
class VenuePhotoSpec {
  final String seed;   // deterministic layout seed (usually venue id)
  final String? asset; // bundled asset path (future)
  final String? url;   // network url (future)
  const VenuePhotoSpec({required this.seed, this.asset, this.url});
}
```

- [ ] **Step 4: Extend `Venue`** — add the imports + fields + constructor params + `copyWith`.

At top of `venue.dart` add: `import 'package:airport_nav/features/venues/domain/entities/venue_details.dart';`

Add these fields after `logoUrl`:
```dart
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
```

Add to the constructor param list (after `this.logoUrl,`):
```dart
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
```

Add a `copyWith` before the closing brace of `Venue`:
```dart
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
        id: id, name: name, category: category, style: style,
        airportCode: airportCode, terminal: terminal, floor: floor,
        location: location, rating: rating, openingHours: openingHours,
        description: description, type: type, tags: tags, items: items,
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
```

- [ ] **Step 5: Run tests + analyze**

Run: `flutter test test/features/venues/venue_details_test.dart` → Expected: PASS.
Run: `flutter analyze lib/features/venues/domain` → Expected: no errors.

- [ ] **Step 6: Checkpoint** — stage `venue_details.dart`, `venue.dart`, the test. (Do not commit unless asked.)

---

## Task 2: Enrichment catalog + Explore providers

**Files:**
- Create: `lib/features/venues/domain/catalog/venue_details_catalog.dart`
- Create: `lib/features/venues/presentation/providers/explore_providers.dart`
- Modify: `lib/features/venues/presentation/providers/venue_providers.dart`
- Test: `test/features/venues/explore_providers_test.dart`

**Interfaces:**
- Consumes: `Venue`, `venue_details.dart` types, existing `allVenuesProvider`, `detectedAirportProvider`.
- Produces: `String normalizeVenueKey(String)`, `Venue enrichVenue(Venue)`, `class VenueDetailsPatch {...}`, `const venueDetailsCatalog`; `enum ExploreFilter { all, food, coffee, lounge, shop, dutyFree }` + `String label` + `bool matches(Venue)`; `exploreFilterProvider` (`StateProvider<ExploreFilter>`), `exploreVenuesProvider` (`Provider<List<Venue>>`, filtered + sorted by walk asc), `venueByIdProvider` (`Provider.family<Venue?, String>`), `favoriteVenuesProvider` (`StateProvider<Set<String>>`) + helper `toggleFavorite`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/venues/explore_providers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';
import 'package:airport_nav/features/venues/domain/entities/venue_details.dart';
import 'package:airport_nav/features/venues/domain/catalog/venue_details_catalog.dart';
import 'package:airport_nav/features/venues/presentation/providers/explore_providers.dart';

Venue _v({required String name, required String category, VenueType type = VenueType.shop, int? walk}) =>
    Venue(id: name, name: name, category: category, style: 'casual', airportCode: 'JFK',
        terminal: '4', floor: 1, location: 'Concourse B', rating: 4.0,
        openingHours: '24h', description: 'x', type: type, walkMinutes: walk);

void main() {
  test('enrichVenue derives a walk time when absent', () {
    final e = enrichVenue(_v(name: 'Nowhere Kiosk', category: 'convenience'));
    expect(e.walkMinutes, isNotNull);
    expect(e.walkMinutes! >= 2 && e.walkMinutes! <= 12, isTrue);
  });

  test('ExploreFilter.lounge matches only lounges', () {
    final lounge = _v(name: 'A', category: 'lounge', type: VenueType.lounge);
    final food = _v(name: 'B', category: 'dining');
    expect(ExploreFilter.lounge.matches(lounge), isTrue);
    expect(ExploreFilter.lounge.matches(food), isFalse);
    expect(ExploreFilter.all.matches(food), isTrue);
  });

  test('ExploreFilter.shop matches retail-family categories', () {
    expect(ExploreFilter.shop.matches(_v(name: 'C', category: 'retail')), isTrue);
    expect(ExploreFilter.shop.matches(_v(name: 'D', category: 'luxury')), isTrue);
    expect(ExploreFilter.shop.matches(_v(name: 'E', category: 'dining')), isFalse);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/venues/explore_providers_test.dart` → Expected: FAIL (undefined `enrichVenue`/`ExploreFilter`).

- [ ] **Step 3: Create `venue_details_catalog.dart`**

```dart
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
    this.walkMinutes, this.nearestGate, this.avgVisitMinutes, this.reviewCount,
    this.priceLevel, this.amenities, this.access, this.highlights,
    this.bestTime, this.directions,
  });
}

String normalizeVenueKey(String name) => name.trim().toLowerCase();

/// Deterministic 2-12 min walk derived from the venue id when none is set.
int _derivedWalk(Venue v) => 2 + (v.id.hashCode.abs() % 11);

/// Applies the catalog patch (if any) + fills sensible defaults so every
/// venue renders. Pure function - unit tested.
Venue enrichVenue(Venue v) {
  final patch = venueDetailsCatalog[normalizeVenueKey(v.name)];
  final photo = VenuePhotoSpec(seed: v.id);
  final base = v.copyWith(
    photo: photo,
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
  return base;
}

/// Rich detail for the JFK T4 demo set. Keyed by normalized venue name.
/// NOTE: all lounges + the mockup venues below MUST be present. Add more freely.
const Map<String, VenueDetailsPatch> venueDetailsCatalog = {
  'shake shack': VenueDetailsPatch(
    walkMinutes: 6, nearestGate: 'B20', avgVisitMinutes: 20, reviewCount: 312,
    priceLevel: PriceLevel.two, amenities: {Amenity.vegetarian},
    highlights: [
      VenueHighlight(name: 'ShackBurger', note: 'Bestseller', price: r'$8.19'),
      VenueHighlight(name: 'Cheese fries', note: 'Side', price: r'$4.50'),
      VenueHighlight(name: 'Vanilla shake', price: r'$5.25'),
    ],
    bestTime: BestTimeWindow(start: '9:36', end: '9:54', reason: 'Fits before luxury stops - low queue'),
    directions: DirectionsHint(text: 'Left at the plaza, follow B gate signs', minutes: 6),
  ),
  'sbarro': VenueDetailsPatch(
    walkMinutes: 4, nearestGate: 'B12', avgVisitMinutes: 15, reviewCount: 176,
    priceLevel: PriceLevel.one, amenities: {Amenity.vegetarian},
    highlights: [
      VenueHighlight(name: 'NY cheese slice', note: 'Bestseller', price: r'$5.50'),
      VenueHighlight(name: 'Pepperoni stromboli', note: 'Hot', price: r'$8.25'),
      VenueHighlight(name: 'Garlic knots (6)', note: 'Side', price: r'$4.00'),
    ],
    directions: DirectionsHint(text: 'By the food court, center of B concourse', minutes: 4),
  ),
  // Lounge example - shows the physical-info payload (showers, nap rooms, cost):
  'centurion lounge': VenueDetailsPatch(
    walkMinutes: 7, nearestGate: 'B23', avgVisitMinutes: 60, reviewCount: 540,
    priceLevel: PriceLevel.three,
    amenities: {Amenity.shower, Amenity.napRoom, Amenity.wifi, Amenity.buffet,
      Amenity.alcohol, Amenity.barista, Amenity.quietZone, Amenity.vegan, Amenity.wheelchair},
    access: VenueAccess(rules: ['Amex Platinum', 'Priority Pass'], entryCost: r'$59 walk-in'),
    bestTime: BestTimeWindow(start: '9:10', end: '9:40', reason: 'Before the morning rush - short shower wait'),
    directions: DirectionsHint(text: 'Up one level, past the duty-free hall', minutes: 7),
  ),
  // ... Add remaining lounges (all from lounge_mock_datasource) and mockup venues
  // 'la colombe coffee', 'blue bottle', 'shiro of japan', plus shops like
  // 'duty free americas', 'hudson news', 'inmotion' following the same shape.
  // Data table for the full set is in the spec (§6) - fill each with amenities,
  // access (lounges), highlights (dining/shop), bestTime, directions.
};
```

> **Implementation note (not a placeholder):** the three entries above are complete and exercise every field. During execution, extend `venueDetailsCatalog` with one entry per remaining JFK lounge (pull amenity truth from `lounge_mock_datasource` descriptions - e.g. "shower suites" → `Amenity.shower`, "relaxation/nap" → `Amenity.napRoom`) and the remaining mockup venues. Each entry is data of the exact shape shown; no new code.

- [ ] **Step 4: Create `explore_providers.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';
import 'package:airport_nav/features/venues/presentation/providers/venue_providers.dart';

enum ExploreFilter { all, food, coffee, lounge, shop, dutyFree }

extension ExploreFilterX on ExploreFilter {
  String get label => switch (this) {
        ExploreFilter.all => 'All',
        ExploreFilter.food => 'Food',
        ExploreFilter.coffee => 'Coffee',
        ExploreFilter.lounge => 'Lounge',
        ExploreFilter.shop => 'Shop',
        ExploreFilter.dutyFree => 'Duty-Free',
      };

  bool matches(Venue v) => switch (this) {
        ExploreFilter.all => true,
        ExploreFilter.food => v.category == 'dining',
        ExploreFilter.coffee =>
          v.tags.contains('coffee') || v.tags.contains('cafe') ||
          v.items.any((i) => i.toLowerCase().contains('coffee')),
        ExploreFilter.lounge => v.type == VenueType.lounge || v.category == 'lounge',
        ExploreFilter.shop => const {'retail', 'luxury', 'electronics', 'convenience'}
            .contains(v.category),
        ExploreFilter.dutyFree => v.category == 'duty_free',
      };
}

final exploreFilterProvider = StateProvider<ExploreFilter>((ref) => ExploreFilter.all);

/// Filtered by the active chip + sorted by walk time ascending (nulls last).
final exploreVenuesProvider = Provider<List<Venue>>((ref) {
  final filter = ref.watch(exploreFilterProvider);
  final venues = [...ref.watch(allVenuesProvider)].where(filter.matches).toList();
  venues.sort((a, b) {
    final wa = a.walkMinutes ?? 9999;
    final wb = b.walkMinutes ?? 9999;
    return wa.compareTo(wb);
  });
  return venues;
});

final venueByIdProvider = Provider.family<Venue?, String>((ref, id) {
  for (final v in ref.watch(allVenuesProvider)) {
    if (v.id == id) return v;
  }
  return null;
});

final favoriteVenuesProvider = StateProvider<Set<String>>((ref) => <String>{});

void toggleFavorite(WidgetRef ref, String id) {
  final n = ref.read(favoriteVenuesProvider.notifier);
  final next = {...n.state};
  next.contains(id) ? next.remove(id) : next.add(id);
  n.state = next;
}
```

- [ ] **Step 5: Wire enrichment into `allVenuesProvider`**

In `venue_providers.dart`, add `import '../../domain/catalog/venue_details_catalog.dart';` and map the merged list through `enrichVenue` before returning, e.g. change the final `return [...shopVenues, ...loungeVenues];`-style return to `return [...shopVenues, ...loungeVenues].map(enrichVenue).toList();` (adjust to the actual variable names in that file).

- [ ] **Step 6: Run tests + analyze**

Run: `flutter test test/features/venues/explore_providers_test.dart` → Expected: PASS.
Run: `flutter analyze lib/features/venues` → Expected: no errors.

- [ ] **Step 7: Checkpoint** — stage the two new files + `venue_providers.dart` + test. (No commit unless asked.)

---

## Task 3: `VenueImage` styled tile

**Files:**
- Create: `lib/core/widgets/venue_image.dart`
- Test: `test/core/venue_image_test.dart`

**Interfaces:**
- Consumes: `Venue`, `AppColors`.
- Produces: `class VenueImage extends StatelessWidget` with `VenueImage({required Venue venue, double? height, double? size, BorderRadius? radius})`; static `List<Color> VenueImage.gradientFor(Venue)` and `int VenueImage.seedOf(Venue)` (deterministic, testable).

- [ ] **Step 1: Write the failing test**

```dart
// test/core/venue_image_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/core/widgets/venue_image.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';

Venue _v(String id, String cat) => Venue(id: id, name: id, category: cat, style: 'casual',
    airportCode: 'JFK', terminal: '4', floor: 1, location: 'B', rating: 4,
    openingHours: '24h', description: 'x', type: VenueType.shop);

void main() {
  test('gradient + seed are deterministic per venue', () {
    final v = _v('shake-shack', 'dining');
    expect(VenueImage.seedOf(v), VenueImage.seedOf(_v('shake-shack', 'dining')));
    expect(VenueImage.gradientFor(v), VenueImage.gradientFor(_v('shake-shack', 'dining')));
    expect(VenueImage.gradientFor(v).length, 2);
  });

  testWidgets('renders without error', (t) async {
    await t.pumpWidget(MaterialApp(home: Scaffold(body: VenueImage(venue: _v('a', 'lounge'), height: 120))));
    expect(find.byType(VenueImage), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify it fails** — `flutter test test/core/venue_image_test.dart` → FAIL (undefined `VenueImage`).

- [ ] **Step 3: Implement `venue_image.dart`**

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../features/venues/domain/entities/venue.dart';

/// Deterministic, on-brand image tile for a venue. Renders a category-tinted
/// gradient + a translucent category glyph + soft motif circles seeded by the
/// venue id, so every venue looks distinct and identical across rebuilds.
/// If venue.photo.asset/url is set, that real image is shown instead.
class VenueImage extends StatelessWidget {
  final Venue venue;
  final double? height;
  final double? size;
  final BorderRadius? radius;
  const VenueImage({super.key, required this.venue, this.height, this.size, this.radius});

  static int seedOf(Venue v) => (v.photo?.seed ?? v.id).hashCode.abs();

  static List<Color> gradientFor(Venue v) {
    // Category base tints (a/b) - all cohesive with the sky palette.
    const palettes = <String, List<Color>>{
      'dining':      [Color(0xFFEAF1FF), Color(0xFFD6E4FF)],
      'lounge':      [Color(0xFFEAF0FF), Color(0xFFDDE7FF)],
      'duty_free':   [Color(0xFFEFEBFF), Color(0xFFE1DAFF)],
      'luxury':      [Color(0xFFF1ECFF), Color(0xFFE6DBFF)],
      'electronics': [Color(0xFFE7F3FF), Color(0xFFD3EAFF)],
      'convenience': [Color(0xFFEAF3EF), Color(0xFFD9EBE3)],
      'retail':      [Color(0xFFEDF0F6), Color(0xFFDCE3F0)],
    };
    return palettes[v.category] ?? const [Color(0xFFEDF0F6), Color(0xFFDCE3F0)];
  }

  static IconData _glyph(Venue v) => switch (v.category) {
        'dining' => Icons.restaurant_rounded,
        'lounge' => Icons.weekend_rounded,
        'duty_free' => Icons.redeem_rounded,
        'luxury' => Icons.diamond_rounded,
        'electronics' => Icons.devices_rounded,
        'convenience' => Icons.local_convenience_store_rounded,
        _ => Icons.storefront_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final r = radius ?? BorderRadius.circular(16);
    final seed = seedOf(venue);
    final g = gradientFor(venue);
    // Deterministic motif offsets from the seed.
    final dx = (seed % 7) / 7.0;       // 0..1
    final dy = ((seed ~/ 7) % 5) / 5.0;
    final w = size, h = size ?? height;

    return ClipRRect(
      borderRadius: r,
      child: SizedBox(
        width: w, height: h,
        child: Stack(fit: StackFit.expand, children: [
          DecoratedBox(decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + dx, -1), end: Alignment(1, 1 - dy), colors: g))),
          Positioned(
            right: -14 - dx * 8, top: -10 + dy * 14,
            child: _softCircle(48 + (seed % 20).toDouble())),
          Positioned(
            left: -8 + dx * 10, bottom: -12,
            child: _softCircle(30 + (seed % 14).toDouble())),
          Center(child: Icon(_glyph(venue),
            color: AppColors.sky.withValues(alpha: 0.28),
            size: (h ?? 64) * 0.42)),
        ]),
      ),
    );
  }

  Widget _softCircle(double d) => Container(width: d, height: d,
      decoration: BoxDecoration(shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.35)));
}
```

> If `AppColors.sky.withValues` is unavailable on the installed Flutter, use `AppColors.sky.withOpacity(0.28)` instead (check the version at execution time; the codebase already uses one of these).

- [ ] **Step 4: Run tests** — `flutter test test/core/venue_image_test.dart` → PASS.
- [ ] **Step 5: Checkpoint** — stage `venue_image.dart` + test.

---

## Task 4: Explore page (restyle + rename + nav)

**Files:**
- Rename/rewrite: `lib/features/venues/presentation/screens/venues_screen.dart` → `explore_screen.dart` (class `ExploreScreen`).
- Create: `lib/features/venues/presentation/widgets/explore_venue_card.dart`
- Modify: `lib/core/router/app_router.dart` (`/venues` → `/explore`), `lib/core/widgets/app_shell.dart` (tab label/route/icon), inbound `/venues` refs.
- Test: `test/features/venues/explore_screen_test.dart`

**Interfaces:**
- Consumes: `exploreVenuesProvider`, `exploreFilterProvider`, `ExploreFilter`, `VenueImage`, `venueByIdProvider` (for tap → detail route), existing search providers.
- Produces: `ExploreScreen`, `ExploreVenueCard`. Route `/explore`.

- [ ] **Step 1: Behavior test (failing)**

```dart
// test/features/venues/explore_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/venues/presentation/screens/explore_screen.dart';

void main() {
  testWidgets('Explore shows title, filter chips, and a walk-time result bar', (t) async {
    await t.pumpWidget(const ProviderScope(child: MaterialApp(home: ExploreScreen())));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Explore'), findsWidgets);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Lounge'), findsOneWidget);
    expect(find.textContaining('walk time'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify it fails** — FAIL (no `explore_screen.dart`).

- [ ] **Step 3: Build `ExploreScreen`** — rewrite the venues screen to the mockup. Keep the existing search field + smart-search results view (reuse), but replace the header + browse list. Structure:

```
Scaffold(paper)
 SafeArea > Column:
  - Header: Text('Explore $airport', displaySmall) + subtitle
      '$openCount venues open - Terminal 4 - Concourse B'
      with a right-aligned TonalPill(location/Map -> context.push('/map')).
  - Search TextField (existing controller/logic) + trailing mic Icon button
      (onPressed -> context.push('/voice-chat')).
  - Filter chips row: horizontal ListView of ChoiceChip-style pills over
      ExploreFilter.values; selected -> sky fill, else surfaceVariant.
      onTap sets ref.read(exploreFilterProvider.notifier).state = f.
  - Result bar: Text('${list.length} results - sorted by walk time').
  - Expanded: if searching -> existing _SearchResultsView; else
      ListView.separated over ref.watch(exploreVenuesProvider) building
      ExploreVenueCard(venue: v, onTap: () => context.push('/explore/venue/${v.id}')).
```

Use `AppTypography`/theme styles, `AppColors`, `AppSpacing`. Copy uses hyphen-minus.

- [ ] **Step 4: Build `ExploreVenueCard`** (`explore_venue_card.dart`) — per mockup:

```
AppCard(onTap): Row:
  VenueImage(venue, size: 56, radius 14)
  gap
  Expanded Column(cross start):
    Row: Expanded Text(name, titleMedium w700, ellipsis) ; walk pill:
        Container(surfaceVariant, pill) Row[Icon(directions_walk, 12), '${walk}m']
    Text('${categoryLabel} - ${location}', bodySmall muted, ellipsis)
    Row: Icon(star_rounded 12, sky) '${rating}'  · '~${avgVisit ?? walk}m' ·
         Text(isOpenNow ? 'Open' : 'Closed', color success/muted)
  gap
  Circular route button: InkWell -> context.push('/map');
     Container(40, skyAlpha10, circle) Icon(alt_route_rounded 18, sky)
```

Guard every text with `maxLines`/`ellipsis`; wrap the middle column so nothing overflows at 320 dp width.

- [ ] **Step 5: Route + nav rename**
  - `app_router.dart`: change the shell route `path: '/venues'` → `'/explore'` and its builder to `ExploreScreen` (update import).
  - `app_shell.dart`: the Search tab → `label: 'Explore'`, `route: '/explore'`, `icon: Icons.travel_explore_rounded` (keep it as the 2nd tab; Assistant stays centered).
  - Grep for `'/venues'` across `lib/` and repoint each to `'/explore'` (Home "Food & Drinks" quick-start, any pushes).

- [ ] **Step 6: Run tests + analyze**

Run: `flutter test test/features/venues/explore_screen_test.dart` → PASS.
Run: `flutter analyze lib` → no new errors.

- [ ] **Step 7: Checkpoint** — stage renamed screen, new card, router, shell, refs, test.

---

## Task 5: Venue detail page (adaptive) + wiring

**Files:**
- Create: `lib/features/venues/presentation/screens/venue_detail_screen.dart`
- Modify: `lib/core/router/app_router.dart` (add `/explore/venue/:id` top-level route)
- Test: `test/features/venues/venue_detail_screen_test.dart`

**Interfaces:**
- Consumes: `venueByIdProvider`, `favoriteVenuesProvider`/`toggleFavorite`, `VenueImage`, `AmenityInfo`, all `venue_details.dart` types.
- Produces: `VenueDetailScreen({required String venueId})`. Route `/explore/venue/:id`.

- [ ] **Step 1: Behavior test (failing)** — a lounge renders amenities + access; a dining venue renders menu highlights.

```dart
// test/features/venues/venue_detail_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';
import 'package:airport_nav/features/venues/domain/entities/venue_details.dart';
import 'package:airport_nav/features/venues/presentation/providers/explore_providers.dart';
import 'package:airport_nav/features/venues/presentation/providers/venue_providers.dart';
import 'package:airport_nav/features/venues/presentation/screens/venue_detail_screen.dart';

Venue _lounge() => Venue(id: 'lng', name: 'Sky Lounge', category: 'lounge', style: 'luxury',
    airportCode: 'JFK', terminal: '4', floor: 2, location: 'Concourse B', rating: 4.6,
    openingHours: '24h', description: 'Relax before your flight.', type: VenueType.lounge,
    amenities: {Amenity.shower, Amenity.napRoom, Amenity.vegan},
    access: const VenueAccess(rules: ['Priority Pass'], entryCost: r'$59 walk-in'),
    walkMinutes: 7, nearestGate: 'B23');

void main() {
  testWidgets('lounge detail shows amenity grid + access', (t) async {
    await t.pumpWidget(ProviderScope(
      overrides: [allVenuesProvider.overrideWithValue([_lounge()])],
      child: const MaterialApp(home: VenueDetailScreen(venueId: 'lng')),
    ));
    await t.pump(const Duration(milliseconds: 200));
    expect(find.textContaining("What's inside"), findsOneWidget);
    expect(find.text('Showers'), findsOneWidget);
    expect(find.text('Nap rooms'), findsOneWidget);
    expect(find.textContaining('walk-in'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify it fails** — FAIL (no `VenueDetailScreen`).

- [ ] **Step 3: Implement `VenueDetailScreen`** — `ConsumerWidget`; resolve `ref.watch(venueByIdProvider(venueId))`; if null show a simple "Venue not found" scaffold with a back button. Otherwise a `Scaffold` with a scrolling body + `bottomNavigationBar` sticky footer:

```
CustomScrollView / ListView:
  - SliverAppBar/AppBar: back (context.pop) + favorite IconButton
      (star filled if favoriteVenuesProvider.contains(id); onPressed toggleFavorite).
  - VenueImage(venue, height: 200, radius bottom 20).
  - Title block: name (headlineMedium), location (muted),
      Row[ Badge(isOpenNow ? 'Open now'(success) : 'Closed'),
           Icon(star sky) '${rating} - ${reviewCount ?? 0} reviews' ].
  - StatRow: 3 cells (Walk ${walkMinutes}m | Avg visit ${avgVisitMinutes ?? '-'}m |
      Nearest ${nearestGate ?? '-'}), divided, icons: person_walking/clock/pin.
  - About: SectionLabel('ABOUT') + Text(description).
  - if bestTime != null: SectionLabel('BEST TIME FOR YOU') + card
      [ Icon(auto_awesome) '${start} - ${end}' + reason(muted) ].
  - Adaptive:
      if type == lounge: SectionLabel("WHAT'S INSIDE") + amenity grid (Wrap of
          amenity chips: Icon(AmenityInfo.of(a).icon) + label, from venue.amenities);
          if access != null: SectionLabel('ACCESS & COST') + rules chips + entryCost.
      else if category == 'dining': SectionLabel('HIGHLIGHTS') + 'Full menu'(sky, right)
          + highlight rows (name + note + price); dietary chips (vegan/veg/halal) from amenities.
      else: SectionLabel('FEATURED') + highlight rows + priceLevel.symbols.
  - if directions != null: SectionLabel('HOW TO GET THERE') + a simple
      two-node route line (dot -- dashed -- ring) + '${text} - ${minutes} min'.
Footer (bottomNavigationBar): SafeArea Row:
  OutlinedButton('Directions', -> context.push('/map'))  +  Expanded
  FilledButton('Add to plan', sky, -> ScaffoldMessenger snackbar 'Added to your plan').
```

Extract small private widgets (`_StatRow`, `_SectionLabel`, `_AmenityChip`, `_HighlightRow`, `_RouteLine`) so the file stays focused. Tokens only; hyphen-minus copy; guard overflow.

- [ ] **Step 4: Add the route** — in `app_router.dart`, add a **top-level** route (outside the shell, like `/boarding-pass`):

```dart
GoRoute(
  path: '/explore/venue/:id',
  builder: (context, state) => VenueDetailScreen(venueId: state.pathParameters['id']!),
),
```

- [ ] **Step 5: Run tests + analyze**

Run: `flutter test test/features/venues/venue_detail_screen_test.dart` → PASS.
Run: `flutter analyze lib` → no new errors.

- [ ] **Step 6: Checkpoint** — stage detail screen, router, test.

---

## Task 6: Full verify + emulator screenshots

**Files:** none (verification only).

- [ ] **Step 1: Full analyze + test suite**

Run: `flutter analyze lib test` → Expected: no errors (pre-existing info lints OK).
Run: `flutter test` → Expected: all pass except the known pre-existing splash smoke test.

- [ ] **Step 2: Build + deploy to emulator**

```bash
cd /c/Users/Haim/Documents/projects/example-project/airport_nav
flutter build apk --release
ADB="/c/Users/Haim/AppData/Local/Android/Sdk/platform-tools/adb.exe"
"$ADB" -s emulator-5554 install -r build/app/outputs/flutter-apk/app-release.apk
"$ADB" -s emulator-5554 shell am start -n com.airportnav.airport_nav/.MainActivity
```
(If the package service is down, reboot the emulator OS and retry - see prior runs.)

- [ ] **Step 3: Screenshot-verify** three states via `adb exec-out screencap`:
  1. **Explore** page — "Explore JFK", chips, walk-time-sorted cards with pills + route buttons.
  2. **Lounge detail** — amenity grid (Showers / Nap rooms / Vegan…) + Access & cost.
  3. **Dining detail** — menu highlights + prices + "Add to plan" footer.
  Confirm Nunito + sky palette, no gold, no overflow.

- [ ] **Step 4: Checkpoint** — summarize; offer to commit the batch (only on user request).

---

## Self-Review

- **Spec coverage:** §1 goal → Tasks 1-5. §2 model → Task 1. §3 Explore → Task 4. §4 detail (adaptive) → Task 5. §5 VenueImage → Task 3. §6 catalog/enrichment → Task 2 (+ data fill note). §7 nav rename → Task 4. §8 phases → Tasks 1-6. §9 testing → tests in each task + Task 6. ✓
- **Placeholder scan:** the only deferred content is the *data* fill-out of `venueDetailsCatalog` (remaining lounges/venues), which is explicitly specified as "data of the exact shape shown" with a source rule - not code. No `TODO`/"handle edge cases"/"write tests for the above" placeholders.
- **Type consistency:** `enrichVenue`, `VenueDetailsPatch`, `ExploreFilter.matches`, `exploreVenuesProvider`, `venueByIdProvider`, `favoriteVenuesProvider`/`toggleFavorite`, `VenueImage.seedOf/gradientFor`, `VenueDetailScreen({venueId})`, `ExploreVenueCard` — names are used identically across tasks. Route strings `/explore` and `/explore/venue/:id` consistent between Tasks 4 and 5.
