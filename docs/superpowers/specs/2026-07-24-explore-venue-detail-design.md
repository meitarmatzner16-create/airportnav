# AirportNav — Explore page + rich Venue detail — Design Spec

- **Date:** 2026-07-24
- **Branch:** `redesign/airportnav-wireframe`
- **Status:** Design approved; pending implementation plan

## 1. Goal & guiding principle

The app's premise: **surface the airport's physical reality digitally.** A traveler
should be able to answer "Does this lounge have showers or nap rooms? Is there vegan
food? What does entry cost? How long to walk there?" — *without* physically walking
over to check.

This spec redesigns the venue browse experience into an **"Explore"** page and adds a
**category-adaptive Venue detail page** built around physical amenities, plus in-app
styled venue imagery.

### In scope
- Restyle the venue browse screen to the "Explore JFK" mockup.
- New **Venue detail** page (adaptive per venue kind).
- Enrich the `Venue` data model with physical facts (amenities, price, access/cost,
  highlights, best-time, walk/gate, directions) + mock data for JFK T4.
- In-app **styled photo tiles** (`VenueImage`).
- Rename the **"Search" nav tab → "Explore"** (route `/venues` → `/explore`).

### Out of scope (explicit)
- The fuller `Home / Explore / Plan / Route / Me` nav overhaul — **deferred**.
  Nav stays `Home / Explore / Assistant (centered) / Flights / Map`.
- Real per-venue photography (a `photoUrl`/`photoAsset` hook is included for later).
- Any backend / live data. All data is mock.
- "Add to plan" is a **stub** (confirmation snackbar) until a Plan feature exists.
- Favorites are **in-memory** (non-persistent) for now.

## 2. Data model

Venues are assembled in `allVenuesProvider` by merging `shopsByAirportProvider` +
`loungesByAirportProvider` into a unified `Venue`. We extend `Venue` with optional,
defaulted fields so existing construction keeps compiling, and enrich specific venues
through a **catalog** (see §6).

### 2.1 New fields on `Venue`
All optional / defaulted:

| field | type | used by |
|---|---|---|
| `walkMinutes` | `int?` | Explore card pill + sort, detail stats |
| `nearestGate` | `String?` | detail stats |
| `avgVisitMinutes` | `int?` | detail stats |
| `reviewCount` | `int?` | detail rating row |
| `priceLevel` | `PriceLevel?` (`$`–`$$$$`) | card + shop detail |
| `isOpenNow` | `bool` (default `true`) | card status + header badge |
| `amenities` | `Set<Amenity>` (default `{}`) | lounge/dining detail |
| `access` | `VenueAccess?` | lounge detail (rules + entry cost) |
| `highlights` | `List<VenueHighlight>` (default `[]`) | dining/shop detail |
| `bestTime` | `BestTimeWindow?` | detail "Best time for you" |
| `directions` | `DirectionsHint?` | detail "How to get there" |
| `photo` | `VenuePhotoSpec?` | `VenueImage` (else derived from category) |

### 2.2 Supporting types (new file `venue_details.dart`)
```dart
enum PriceLevel { one, two, three, four } // renders $, $$, $$$, $$$$

enum Amenity {
  shower, napRoom, wifi, powerOutlets, quietZone, kidsArea,
  vegan, vegetarian, halal, alcohol, buffet, barista,
  wheelchair, prayerRoom, luggageStorage, showerPaid,
}
// AmenityInfo.of(Amenity) -> (IconData icon, String label)

class VenueHighlight { final String name; final String? note; final String price; }
//   note e.g. "Bestseller", "Hot", "Side"

class VenueAccess { final List<String> rules; final String? entryCost; }
//   rules e.g. ["Priority Pass", "Business/First"], entryCost "$59 walk-in"

class BestTimeWindow { final String start; final String end; final String reason; }
//   e.g. 9:36 / 9:54 / "Fits before luxury stops · low queue"

class DirectionsHint { final String text; final int minutes; }
//   text e.g. "Left at the plaza, follow B gate signs"

class VenuePhotoSpec { final String seed; final String? asset; final String? url; }
//   seed drives the deterministic in-app tile; asset/url override with a real image
```

### 2.3 Amenity → icon/label map
`shower`→shower, `napRoom`→"Nap room"/bed icon, `wifi`→"Wi-Fi", `powerOutlets`→"Power",
`quietZone`→"Quiet zone", `kidsArea`→"Kids area", `vegan`→"Vegan", `vegetarian`→"Veg",
`halal`→"Halal", `alcohol`→"Bar", `buffet`→"Buffet", `barista`→"Barista",
`wheelchair`→"Step-free", `prayerRoom`→"Prayer room", `luggageStorage`→"Bag storage",
`showerPaid`→"Shower ($)". (Icons from Material rounded set.)

## 3. Explore page (`/explore`, renamed from Venues)

- **Header:** `Explore JFK` (display title) + subtitle `{openCount} venues open ·
  Terminal {t} · Concourse {c}`. Root tab → **no back arrow**; a location/terminal
  chip sits top-right (replaces today's "Map" pill, still routes to `/map`).
- **Search field:** existing behavior + a mic affordance (mic is decorative/opens
  the Assistant for now; wired to voice later).
- **Filter chips** (horizontal scroll, single-select, "All" default):
  `All · Food · Coffee · Lounge · Shop · Duty-Free`
  → maps to: all / `dining` / tag `coffee` / `lounge` / (`retail`+`luxury`+
  `electronics`+`convenience`) / `duty_free`.
- **Result bar:** `{n} results · sorted by walk time` (default sort = `walkMinutes`
  ascending; venues without walk data sort last).
- **Venue card** (`_ExploreVenueCard`, replaces list tile in browse mode):
  `VenueImage` tile (56–64 px, rounded) · name · `{categoryLabel} · {location}`
  (the existing `location` field holds the concourse-ish string, e.g. "Concourse B",
  "Food Court · B Gates") · ★rating · `~{walk}m` · `Open`/`Closed` (colored) —
  with a **walk-time pill**
  (🚶 `{walk}m`, top-right) and a **route icon button** (routes to `/map`).
  Whole card taps through to the detail route.
- Search results reuse the same card. The existing smart-search ("you might like",
  intent banner) is preserved.

## 4. Venue detail page (`/explore/venue/:id`, top-level, no bottom nav)

Full-screen (like `/boarding-pass`). Venue resolved by `id` from `allVenuesProvider`.
`ListView` body + **sticky footer**.

- **App bar:** back + favorite (★, in-memory toggle via a `favoriteVenuesProvider`).
- **Image header:** `VenueImage` (full-width, ~200 px, rounded bottom).
- **Title block:** name · `{concourse}` · `Open now`/`Closed` badge · `★{rating} ·
  {reviewCount} reviews`.
- **3-stat row:** Walk (`{walkMinutes}m`) · Avg visit (`{avgVisitMinutes}m`) ·
  Nearest gate (`{nearestGate}`). Missing values render "—".
- **About:** `description`.
- **Best time for you** card: `{start} – {end}` + `{reason}` (only if `bestTime`).
- **Adaptive section** (the signature part):
  - **Lounge** (`type == lounge`): **"What's inside"** — an amenity grid from
    `amenities` (icon + label, ✓), then an **Access & cost** block from `access`
    (rules chips + `entryCost`). *Directly answers "showers? nap rooms? vegan?
    what's the cost?"*
  - **Dining** (`category == dining`): **Highlights** — `highlights` menu rows
    (name · note · price) + **dietary chips** derived from amenities
    (Vegan/Veg/Halal). "Full menu" link is decorative for now.
  - **Shop** (else): **Featured** — `highlights` as products/brands + `priceLevel`.
- **How to get there:** a simple two-node route line (origin → venue) + `directions`
  text and `{minutes} min` (only if `directions`).
- **Sticky footer:** `Directions` (outline → `/map`) + `Add to plan` (filled sky →
  snackbar "Added to your plan").

Sparse venues (no catalog entry) still render: stats show "—", adaptive section shows
a small "More info coming soon" note; header/title/about/photo always work.

## 5. Photos — `VenueImage` widget (`core/widgets/venue_image.dart`)

- API: `VenueImage({required Venue venue, double? height, double? size,
  BorderRadius? radius})`.
- If `venue.photo?.asset`/`url` present → render that image (with graceful fallback).
- Else render a **deterministic styled tile**: a category-tinted two-tone gradient +
  a large translucent category icon + a subtle motif (offset circles/dots) seeded by
  a hash of `venue.id`/`photo.seed`. On-brand (sky/ink + per-category accent).
- Same venue always yields the same tile (stable across rebuilds; no `Random()` at
  build — seed drives a deterministic layout).

## 6. Mock data enrichment (`venue_details_catalog.dart`)

A `Map<String, VenueDetailsPatch>` keyed by venue id (fallback: normalized name),
applied inside `allVenuesProvider` after Shop/Lounge → Venue mapping.
`VenueDetailsPatch` carries the same optional fields as §2.1 (walk/gate/avgVisit/
reviewCount/priceLevel/amenities/access/highlights/bestTime/directions/photo) and is
merged onto the base `Venue`. Missing keys → derived defaults (`walkMinutes` from
floor + id hash in a 2–12 min range, `isOpenNow` from `openingHours`, `photo` from
category, empty amenities/highlights).

**Must-enrich set (JFK Terminal 4):**
- **All JFK lounges** (from `lounge_mock_datasource`): full `amenities`
  (shower/napRoom/wifi/buffet/alcohol/etc.), `access` (rules + entryCost),
  `bestTime`, `walkMinutes`, `nearestGate`, `avgVisitMinutes`, `reviewCount`.
- **Mockup dining/coffee venues** — ensure these exist and are enriched:
  `Sbarro` (Food Court · B Gates), `Shake Shack` (Concourse B), `La Colombe Coffee`,
  `Blue Bottle`, `Shiro of Japan`. Add to the JFK shop/dining mock set if absent.
- A few shops (e.g. `Duty Free Americas`, `Hudson News`, `InMotion`) for variety.

Concourse label for JFK T4 is static `"Concourse B"` for the demo (single-terminal
context); the field is on the model so it can vary later.

## 7. Nav rename

- `app_shell.dart`: Search tab → label `Explore`, icon `Icons.travel_explore_rounded`
  (or keep `search`), route `/explore`.
- `app_router.dart`: rename shell route `/venues` → `/explore`; add top-level route
  `/explore/venue/:id` → `VenueDetailScreen`.
- Update inbound references (e.g. Home "Food & Drinks" quick-start, any `/venues`
  pushes) to `/explore`.

## 8. Build phases (each independently verifiable)

1. **Model + types** — `venue_details.dart`, extend `Venue`, amenity/icon map.
2. **Catalog + providers** — `venue_details_catalog.dart`; enrich in `allVenuesProvider`;
   add `venueByIdProvider` (id → Venue for the detail route), `favoriteVenuesProvider`,
   `exploreFilterProvider`, and sorted/filtered list providers.
3. **`VenueImage`** styled tiles.
4. **Explore page** restyle (header, chips, sort, `_ExploreVenueCard`, tap-through).
5. **Venue detail** screen (adaptive) + router wiring + card tap.
6. **Nav rename** Search → Explore.
7. **Verify** — analyze, tests, emulator screenshots.

## 9. Testing / verification

- **Widget/unit tests:**
  - `Amenity`/`PriceLevel` render mapping is total (no missing cases).
  - Explore filter maps each chip to the right venues; sort is by walk time asc.
  - Detail page renders a **lounge** (amenity grid + access/cost visible) and a
    **dining** venue (menu highlights) without overflow.
  - `VenueImage` is deterministic for a given venue (same seed → same layout).
- `flutter analyze` clean (no new warnings).
- **Emulator screenshots:** Explore page; a lounge detail (showing shower/nap/vegan/
  cost); a dining detail (menu). Confirm Nunito + sky palette carry through.

## 10. Assumptions

- Single-terminal (JFK T4 / Concourse B) context for the demo.
- Mic, "Full menu", Directions, and Add-to-plan are lightweight stubs/routes for now.
- Favorites and filter selection are in-memory (reset on app restart).
