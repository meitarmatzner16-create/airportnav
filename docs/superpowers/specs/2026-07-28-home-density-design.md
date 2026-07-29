# AirportNav - Home Density - Design Spec

- **Date:** 2026-07-28
- **Branch:** `redesign/airportnav-wireframe`
- **Status:** Design approved; pending implementation plan
- **Workstream:** B of 4 (A Brand done -> **B Home density** -> C+D Trip ingestion / connections / lounge)

## 1. Goal

The home screen carries too much text at too small a size. Three surfaces are
crowded and all three get the same treatment: **fewer words, bigger type, more air.**

| Surface | Problem today | After |
|---|---|---|
| Quick Start | 3 lines per card (icon + title + subtitle), 10.5px title, 9px subtitle | Icon + **one word**, no subtitle |
| Live Departures | 5-column table, 9.5-11px type, column header row | Two-line rows, 16px headline, no header row |
| Your Upcoming Flight | 4 stats crammed across one row | 2x2 stat grid, larger values |

## 2. Custom icon set

Stock Material icons are generic. The Quick Start actions get a small **drawn**
icon set, built the same way as the logo (Flutter vector paths on a 24-unit grid,
scaled by `size / 24`), so they scale and theme cleanly.

| Icon | Composition | Meaning |
|---|---|---|
| `flights` | Magnifying glass with a **plane inside it** | Find my flight |
| `navigate` | Amber dotted route rising to a solid heading arrow, origin dot | Get to my gate |
| `food` | Fork + knife pair | Food and drinks |
| `shops` | Shopping bag with handle | Shops |

**Colour rule:** the primary stroke is `ink`, the secondary detail is `sky`.
**Amber appears in `navigate` only** - amber is reserved for wayfinding, and using
it on Food or Shops purely for visual balance would dilute that meaning.

API (`lib/core/branding/app_icons.dart`):
```dart
enum AppIconKind { flights, navigate, food, shops }

class AppIcon extends StatelessWidget {
  const AppIcon(this.kind, {super.key, this.size = 26, this.color});
  final AppIconKind kind;
  final double size;
  /// Overrides the primary (ink) stroke only; the sky detail and the amber
  /// route keep their brand colours so the set stays recognisable.
  final Color? color;
}
```

## 3. Quick Start

- `QuickStartItem` **drops `subtitle`** and its `icon` becomes an `AppIconKind`.
- Labels: **Flights · Navigate · Food · Shops** (one word each).
- Card: icon `26px`, gap `12`, label `13px / w700`, vertical padding `16`.
- The four cards stay a single row of equal-width cards, still wrapped in
  `IntrinsicHeight` (this is what stops the infinite-height crash that produced a
  blank home in release builds - do not remove it).

Routes are unchanged: Flights -> `/flights`, Navigate -> `/map`, Food -> `/explore`,
Shops -> `/explore`.

## 4. Live Departures

Replace the table with two-line rows. **The column header row is deleted** - the
grid is what forced every cell to be tiny.

```
[ DL ]   DL 1234                    4:59 AM
  38px   Atlanta (ATL)      A12   ( On time )
```

| Element | Style |
|---|---|
| Airline tile | 38px, rounded 12 (was 22px circle) |
| Flight number | 16px, w800 |
| Time | 16px, w800, right-aligned, tabular figures |
| Destination | 13px, `muted` |
| Gate | 12px, w700, `ink` |
| Status | existing `StatusBadge`, right-aligned |
| Row padding | `13` vertical, `12` horizontal |

Selected row keeps the current treatment (sky tint fill + `sky` 1.5px border,
inset with a margin) so the selection remains obvious.

Overflow: flight number, destination and time are all `maxLines: 1` +
`TextOverflow.ellipsis`; destination is the flexible cell that gives way first.

## 5. Your Upcoming Flight

Header row (airline tile, destination, flight number, boards-in, chevron) keeps its
structure but the four stats move from one cramped row to a **2x2 grid**:

```
Gate            Departs
A12             4:59 AM

Est. walk       Terminal
8 min           T4
```

| Element | Style |
|---|---|
| Stat label | 11px, `muted` |
| Stat value | 18px, w700, `ink` (was ~14px) |
| Cell spacing | 14 vertical between rows, 12 horizontal between columns |

Icons stay on each stat but move inline beside the label rather than above it, so
the value gets the visual weight.

## 6. Out of scope

- Hero banner, search bar and the header (already done in Workstream A)
- The Assistant entry card
- Any Workstream C/D work (trip ingestion, connections, lounge)
- Dark-mode-specific tuning beyond the existing `isDark` branches

## 7. Verification

**Tests**
- `AppIcon` renders every `AppIconKind` at 16 / 26 / 44px with no exception
- Quick Start renders exactly the four one-word labels and **no** subtitle text
- Live Departures renders flight number, destination, time, gate and status, and
  does **not** render the old `FLIGHT` / `DESTINATION` column headers
- `UpcomingFlightCard` renders all four stat labels and values
- Home lays out at 320dp width with no overflow exception
- `flutter analyze lib test` clean; full suite stays at 0 failures

**Visual (emulator)**
- Quick Start shows four custom icons with single-word labels
- Departures rows are visibly larger and scannable at arm's length
- Upcoming flight stats read as a 2x2 grid with large values
