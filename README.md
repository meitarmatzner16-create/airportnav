# AirportNav

**Every piece of information in an airport is physical. This app makes it digital.**

Departure boards you have to walk to and squint at. Paper maps bolted to a wall.
Gate changes announced over a speaker you cannot hear. Lounge rules printed on a
door. Today a traveller reconstructs their journey from scattered physical
signage - AirportNav puts all of it in one place, personalised to the flight you
are actually on.

### Try it

**[Open the live demo](https://meitarmatzner16-create.github.io/airportnav/)** -
runs in any browser, no install. Best viewed on a phone.

<img src="docs/portfolio/airportnav-qr.png" alt="QR code linking to the live AirportNav demo" width="200">

---

## The idea

An airport is one of the few places left where you are surrounded by information
you cannot search, filter, or take with you. The product thesis is a single
inversion:

| Today - physical | AirportNav - digital |
| --- | --- |
| Departure board on a wall | Live board in your hand, your flight pinned |
| Paper terminal map | Route drawn from where you stand to where you need to be |
| Lounge rules on a door | Entry price, showers, nap pods, food, phone booths - before you walk there |
| Gate change over a speaker | The change reaches you wherever you are |
| Asking a staff member | Ask in plain language, get an answer and a route |

## What is in the app

| Screen | What it answers | How the information gets there |
| --- | --- | --- |
| **Home** | "What am I doing today?" | The one question the app cannot infer: departing, connecting or arrived. The active stage carries your live step, gate and boarding time |
| **Journey** | "What do I do right now?" | A spine from choosing your flight to boarding. Each step carries where, by when, queue plus walk minutes, and what changed - with live queue drift and a scripted gate change |
| **Connecting** | "Can I make my connection?" | Step one is the board twice: the flight you came in on and the one you leave on. The journey builds itself the moment both are tapped |
| **Trip** | "Take me back to my journey" | One tab, one job - returns you to wherever you are in the airport |
| **Arrived** | "I've landed - now what?" | Ways out first, services second: exit, baggage, transport and lounges with walk times |
| **Explore** | "Where can I eat, rest, work, shop?" | Venue catalog enriched with the physical facts: price band, opening hours, walk time, amenities |
| **Venue detail** | "Is it worth the walk?" | Lounges show entry cost, showers, nap pods, food style and phone booths - grouped as rest / food / work / access |
| **Map** | "How do I get there?" | Vector terminal map with the route drawn as a dashed path, start and end marked |
| **Assistant** | "Just tell me what to do" | Natural-language entry point that builds routes and finds services |

The free-time number is the one no sign in the building can give you: the sum
of your remaining queues and walks against your boarding time. Positive, and
the app suggests what fits; negative, and it tells you to skip the stop.

## Design

The whole app is driven by one design system - no ad-hoc colours or fonts
anywhere in feature code.

- **Type:** Poppins throughout, one family, a fixed scale in `AppTypography`
- **Colour:** sky blue for action, ink for text, amber reserved for wayfinding,
  orange for delays so it never collides with the accent - all in `AppColors`
- **Brand:** "The Pass" - a boarding-pass tile with real notched geometry, a
  route line and a plane. One `CustomPainter` drives the logo, the animated
  splash and the app icon, so the mark can never drift between them
- **Surface:** shared radius, spacing and shadow tokens in `AppSpacing` /
  `AppShadows`

## Built with

Flutter (Dart 3) - Riverpod for state, go_router for navigation, Hive and
shared_preferences for local persistence. Clean architecture: each feature owns
its `domain` / `data` / `presentation` layers, with shared tokens and widgets in
`core`.

## Running it locally

```bash
flutter pub get
flutter run            # device or emulator
flutter run -d chrome  # browser
```

Verify:

```bash
flutter analyze
flutter test
```

## Deployment

Every push builds the web app and publishes it to GitHub Pages, gated on
`flutter analyze` and the full test suite - see
[`.github/workflows/deploy-web.yml`](.github/workflows/deploy-web.yml). The live
demo can never drift from the code in this repo.

To regenerate the QR code after changing the URL:

```bash
python tools/gen_qr.py
```

## Project notes

Design specs and implementation plans live in [`docs/superpowers/`](docs/superpowers/) -
they document the reasoning behind each round of work, not just the result.

---

*A portfolio project exploring product thinking, user experience, and
AI-assisted prototyping. Airline codes are shown as brand-coloured tiles rather
than logos; no airline artwork is reproduced.*
