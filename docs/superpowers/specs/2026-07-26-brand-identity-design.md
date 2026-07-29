# AirportNav - Brand & Identity ("The Pass") - Design Spec

- **Date:** 2026-07-26
- **Branch:** `redesign/airportnav-wireframe`
- **Status:** Design approved; pending implementation plan
- **Workstream:** A of 4 (A Brand -> B Home density -> C+D Trip ingestion / connections / lounge)

## 1. Thesis

The airport's information is trapped in **physical objects** - the departure board, the
overhead signs, the paper boarding pass. AirportNav frees it into the phone.

The mark chosen is **"The Pass"**: a boarding-pass tile (with its punched notches)
whose interior turns into a route and takes flight. A physical artifact becoming
navigation - the product thesis in one shape.

## 2. The mark

### 2.1 Geometry (all values as fractions of the rendered size `S`, from a 64-unit grid)

| Element | Spec |
|---|---|
| Tile | Rounded rect, full bleed, corner radius `0.281 * S` (18/64) |
| Notches | Two circles subtracted from the left and right edges, centres `(0, 0.469S)` and `(S, 0.469S)`, radius `0.117S` (7.5/64) |
| Fill (sky variant) | Linear gradient `#5895F3` -> `#3577E7`, top-left to bottom-right |
| Fill (ink variant) | Flat `#0F2350` |
| Plane | Path on the 64-grid: `M49 15 L27 25.5 L36.5 29.5 L40 39 Z`, white |
| Route | Quadratic `M13 48 Q25 47 33 38`, stroke `0.053S` (3.4/64), round cap, dotted, `amber` |

The notches are **real geometry** - `Path.combine(PathOperation.difference, rrect, circles)` -
not an overlay, so they stay crisp at any size and over any background.

### 2.2 Variants
- `AppLogoVariant.sky` (default) - gradient tile, white plane, amber route
- `AppLogoVariant.ink` - flat ink tile, white plane, amber route (for light-on-dark)
- `AppLogoVariant.mono` - single-colour tile, white plane, **no route** (fallback / print)

### 2.3 Small-size rule
Below **24 logical px** the route dots are omitted automatically and the plane carries
the mark - at that scale the dots turn to mud. Implemented as a default:
`showRoute ??= size >= 24`.

### 2.4 Lockup
`AppLogo` (mark) + "AirportNav" in Nunito `w800`, letter-spacing `-0.3`. Gap `0.28 * S`.
Exposed as `AppLogo.lockup(size: ...)`.

## 3. Tokens

### 3.1 Added to `AppColors`
| Token | Value | Meaning |
|---|---|---|
| `amber` | `#FFB020` | Brand accent - "your path" |
| `amberTint` | `#FFF4E0` | Amber-tinted surfaces |
| `amberText` | `#8A5A00` | Amber semantics carrying **text** |
| `amberAlpha15` | `0x26FFB020` | Amber at 15% |

`amberText` exists for accessibility: `#FFB020` on white is ~1.9:1 contrast, which fails
WCAG AA for small text. Any amber-coloured **label** uses `amberText`; `amber` is for
shapes, strokes, dots and fills only.

### 3.2 Changed
| Token | From | To | Why |
|---|---|---|---|
| `statusDelayed` | `#E8A93B` | `#F5731F` | The old value was nearly identical to the brand amber, so the accent read as "something is wrong" wherever it appeared. Delayed becomes clearly orange. |

`warning` (`#E8A93B`) stays as-is for genuine warning semantics; only the **delayed flight
status** re-points to the new orange. `warningAlpha15` is unchanged.

### 3.3 Usage rules (the part that makes it a system, not decoration)
**Amber means "your path / your current step".** Permitted:
1. Route and wayfinding lines ("How to get there", map route overlays)
2. The active step in a sequence ("you are here" in a connection stepper)
3. The logo's own route dots

**Forbidden:** ratings (stay `sky`), any flight status (green / orange / red only),
card backgrounds, decorative accents, or more than one amber element per view.

## 4. Splash animation

Replaces `splash_screen.dart` entirely.

- **Background:** `AppColors.paper` (white) with a soft `skyTint` radial glow behind the
  mark. Deliberately **not** the current navy gradient, which jolts into the white app.
- **Duration:** 1700ms total, then navigate.

| Beat | Timing | Interval | Motion |
|---|---|---|---|
| Tile lands | 0-350ms | `0.00-0.21` | scale `0.86 -> 1.0` (easeOutCubic), opacity `0 -> 1` |
| Route runs | 300-900ms | `0.18-0.53` | dots reveal along the path, left to right |
| Plane lifts | 700-1150ms | `0.41-0.68` | offset `(-3,+4) -> (0,0)`, opacity `0 -> 1` |
| Wordmark | 1000-1500ms | `0.59-0.88` | rise `8px`, opacity `0 -> 1` |

### 4.1 Technical approach (and the test it fixes)
One `AnimationController(1700ms)`, four `Interval`-driven animations, navigation from an
`addStatusListener` on `completed`.

The current implementation uses `..repeat(reverse: true)` **and** `Future.delayed(2s)`,
which is why `widget_test.dart > "App launches smoke test"` fails with
`"A Timer is still pending even after the widget tree was disposed"` - the single
long-standing test failure in this repo. Removing both fixes it.

`AppLogo` therefore takes progress parameters so the splash can drive partial states:
`AppLogo({size, variant, tileProgress = 1, routeProgress = 1, planeProgress = 1})`.
Route progress uses `PathMetrics.extractPath(0, t * length)` and lays dots along the
extracted sub-path.

## 5. Onboarding persistence (bug fix, in scope)

Onboarding completion is never stored, so **every cold launch returns to onboarding** -
visible repeatedly during emulator testing. Fix: persist `onboarding_seen` via
`shared_preferences` (already a dependency). Splash reads it and routes to `/home` when
seen, `/onboarding` when not. "Skip" and finishing the last page both set it.

## 6. In-app placement

- **Home header:** `AppLogo(size: 30)` immediately left of the "AirportNav" wordmark in
  `home_header.dart`. Nothing else in the header changes.
- **Notch motif:** a `NotchedCard` wrapper using the same notch geometry, applied **only**
  to boarding-pass and upcoming-flight contexts. Explicitly not a global card style -
  applied everywhere it becomes noise.

## 7. App icon

Generated from the same geometry so icon and in-app mark can never drift:
- `tools/gen_app_icon.py` (Pillow) writes `assets/icons/app_icon.png` (1024x1024, full
  tile) and `assets/icons/app_icon_foreground.png` (1024x1024, plane+route with 25%
  safe-area padding for Android adaptive icons).
- Add `flutter_launcher_icons` as a dev dependency with config for `android` and `ios`,
  adaptive background `#3577E7`.

## 8. Out of scope

- Re-theming existing screens beyond adding the tokens above
- Onboarding page content and illustrations
- Any Workstream B/C/D work (home density, trip ingestion, connections, lounge)
- Dark-mode logo variants beyond `ink`
- Animated logo anywhere other than the splash

## 9. Verification

**Tests**
- `AppLogo` renders at 20 / 28 / 56 / 104 px with no exception
- Route is omitted below 24px and present at/above it
- `tokens_test`: `amber`, `amberText`, `statusDelayed` have the exact values above
- Splash: pumps to completion, navigates, and leaves **no pending timers** - i.e.
  `widget_test.dart > "App launches smoke test"` must pass, taking the suite to 0 failures
- `flutter analyze lib test` clean

**Visual (emulator)**
- Splash animation plays through its four beats
- Home header shows mark + wordmark
- A delayed flight shows the new orange badge, distinct from any amber
- Second cold launch goes straight to Home (onboarding not repeated)
