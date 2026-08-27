# The Airport Journey - design

**Date:** 2026-07-31
**Status:** approved by user, ready for planning
**Mockups:** [flow](https://claude.ai/code/artifact/d3a38853-c1db-4c21-8150-c7ddb2e52da6) · [home before/after](https://claude.ai/code/artifact/7124bc30-30d2-497a-997c-1efa60f6db79)

---

## 1. The problem

AirportNav's thesis is that every piece of information in an airport is physical -
printed on a wall, a desk sign, or announced over a speaker - and the product exists to
make it digital. Home does not honour that. It tells you about your **flight**; it says
nothing about your **passage through the building**.

Ten questions a traveller actually asks, and where the answer lives today:

| Question | Lives today on | In the app |
| --- | --- | --- |
| Where do I check in? | Overhead zone sign | No |
| When does bag drop close? | Small print at the desk | No |
| Which security lane? | A queue judged by eye | No |
| How long is the queue? | A screen at the entrance, or guesswork | No |
| Do I need passport control? | Signage after security | No |
| Which gate? | The departure board | **Yes** |
| How far is the gate? | Nothing tells you | Map only, never in minutes |
| When do I board, in which group? | Boarding pass + gate screen | No |
| Has my gate changed? | An announcement you may not hear | No |
| Do I have time for coffee? | Mental arithmetic under stress | No |

One of ten. The missing nine are the product.

## 2. The shape of the solution

The app cannot work out for itself whether you are departing, connecting or arriving.
Knowing your flight does not disambiguate it: someone holding a boarding pass for AA 2468
might be about to check in, or might have just landed from Paris with 90 minutes to make
it. Those are different journeys. **That is the one question worth asking, and it is why
it owns Home.**

```
Home (what are you doing?)  →  Journey page  →  All steps
     Departing                  spine + current step        full timeline
     Connecting
     Arrived (deferred)
```

Answering the question starts a journey. The journey opens on its own page whose **spine
is always visible** and whose **body is whatever the current step needs**. Choosing your
flight is step one, so the app never has to render an "I need a flight first" empty state.

### The spine

**Departing:** Flight → Check-in → Bag drop → Security → Gate → Boarding
**Connecting:** Flight → Arrive → Transfer → Security → Gate → Boarding

Passport control is inserted after Security when the flight is international. The spine
therefore renders `steps.length` dots, never a hard-coded six.

### Four questions per step

| Question | Meaning |
| --- | --- |
| **Where** | The thing currently printed on a sign - zone 3, lane B, gate C18 |
| **By when** | The deadline that actually matters, not the departure time |
| **How long** | Queue minutes **plus** walking minutes |
| **What changed** | Gate moved, lane closed, boarding early |

### The number only this app can produce

```
projectedGateArrival = pinnedNow + Σ(remaining step.queueMinutes + step.walkMinutes)
freeTime             = boardingTime - projectedGateArrival
```

No sign in the building can compute that. It turns process data into a recommendation -
"you have 25 minutes, the Centurion Lounge is 4 minutes away" - and is what connects this
feature to the venue work already built. It may be negative; see edge states.

## 3. Decisions taken

| Decision | Choice |
| --- | --- |
| Home | The stage chooser. Three cards, greeting, popular tiles, live-updates strip |
| Active stage card | Once chosen, it carries live status: step N of M, next step, queue, gate, boarding |
| Journey | Its own pushed page. Spine on top, body per step |
| Flight selection | Step one of the journey, using the existing board |
| Trip tab | Returns you to your active journey. Replaces Flights in the tab bar |
| Data | Live-feeling mock. Queue times drift, steps advance, one scripted disruption |
| Stages | Departing and Connecting, both fully built. Arrived deferred |
| Airport picker | Stays in the Home header, unchanged |
| `UpcomingFlightCard` | Deleted |

## 4. Domain model

New feature: `lib/features/journey/`.

```dart
enum JourneyStage { departing, connecting }

enum StepKind {
  flight, checkIn, bagDrop, security, passport, gate, boarding,  // departing
  arrive, transfer,                                              // connecting
}

enum StepStatus { done, current, upcoming }

class JourneyStep {
  final StepKind kind;
  final String title;          // "Security"
  final String where;          // "Terminal 4 · Main checkpoint · Lane B"
  final String? note;          // "Fast Track open - your ticket qualifies"
  final DateTime? deadline;
  final int queueMinutes;
  final int walkMinutes;
  final DateTime? completedAt;
}

class Journey {
  final JourneyStage stage;
  final Flight? flight;        // null until step one is answered
  final Flight? inboundFlight; // connecting only
  final List<JourneyStep> steps;
  final int currentIndex;      // single source of truth for status
  final DateTime pinnedNow;    // frozen at journey creation - see §5
  final Disruption? disruption;

  StepStatus statusOf(int i);  // derived from currentIndex, never stored
  JourneyStep get currentStep;
  JourneyStep? get nextStep;
  DateTime get boardingTime;
  DateTime get gateClosesAt;
  DateTime get projectedGateArrival;
  Duration get freeTime;
  String get effectiveGate;    // honours a gateChange disruption
}
```

`currentIndex` is the only source of truth for progress; `StepStatus` is derived. Storing
both invites silent disagreement.

`Flight` gains a `copyWith` so a gate change can be applied without mutating the mock
repository. Nothing else about `Flight` changes.

### Disruption

```dart
enum DisruptionKind { gateChange, queueSpike, boardingEarly, laneClosed }

class Disruption {
  final DisruptionKind kind;
  final StepKind affectedStep;  // needed for the acknowledge rule
  final String headline;
  final String detail;
  final String? newGate;        // gateChange only
  final DateTime firedAt;
}
```

A live disruption takes over the top of the journey page, above the current-step card.
**Acknowledgement is provider state, not a field on the immutable Disruption**: tapping it
collapses the banner to one line that stays until `affectedStep` is done. A gate change
must not be able to scroll out of the user's life because they tapped once.

## 5. Live simulation

`journeyTickProvider` drives the sense of life. Every 5 seconds it drifts upcoming queue
minutes within a per-step band, advances `currentIndex` when the current step's dwell has
elapsed, and fires one scripted disruption at a fixed offset.

Hard constraints, each earned from a real failure in this codebase:

- **Pin the clock.** `FlightMockDatasource.getAllFlights()` calls `DateTime.now()` on every
  invocation and rebuilds every departure relative to it. A Journey re-read from the
  repository on each tick would have a departure time that never gets closer. The Journey
  captures one `Flight` snapshot and a `pinnedNow` at creation and never re-reads.
- **Never invalidate `allFlightsProvider` from the ticker.** Same reason.
- **`journeyProvider` is a plain `Provider<Journey?>`.** `overrideWithValue` - the only
  override form used anywhere in the suite - does not compile on `StateProvider` or
  `StreamProvider`.
- **The timer lives in an `.autoDispose` provider body with `ref.onDispose(timer.cancel)`,
  never in a widget's `initState`.** The splash screen already broke the suite this way
  once; its header comment documents it.
- **Nothing starts the ticker at app scope.** `test/widget_test.dart` pumps a `const
  ProviderScope`, so no override can be added to it. It survives only because the app
  starts at `/splash`.
- **Compare flights by `id`, never `==`.** `Flight` has no `==`/`hashCode`.
- **Journey providers depend only on flight and venue providers.** Anything touching
  `savedFlightIdsProvider` opens a Hive box in a field initializer and throws in tests.

## 6. Screens

### Home - `/home`

1. **Header** - mark, "AirportNav", airport picker, notifications. Unchanged.
2. **Greeting** - "Hey there. What are you doing today?"
3. **Three stage cards** - Departing, Connecting, Arrived. The active stage carries live
   status; the others stay plain descriptions.
4. **Popular right now** - the existing category tiles.
5. **Live airport updates** - strip linking to gate changes, delays, queue times.

**Leaving Home:** the hero banner (a promise, not information), the search bar (venue
search is on Explore, flight search is now step one of the journey), Quick Start (three of
its four shortcuts are tabs), Live Departures (its content is step one of the journey), and
`UpcomingFlightCard`.

### Journey - `/journey`

Pushed from a Home stage card. One page, two regions:

- **Spine** - always visible, one dot per step, amber done / sky current / grey upcoming
- **Body** - depends on `currentStep.kind`:
  - `flight` → the existing flights board, inline, as "Which flight are you on?"
  - anything else → disruption banner (if live), current-step card, "Then" card,
    free-time strip

### All steps - `/journey/steps`

The full vertical timeline, one row per step with where, when, queue and walk. Reached from
the spine.

### Trip tab

Replaces Flights in the tab bar at index 3. Its job is "return me to my journey": routes to
`/journey` when one is active, else to `/home`. **The tab bar stays at exactly five entries
with the hero at index 2** - appending a sixth un-centres the Assistant disc and truncates
every label.

### Free-time strip

Cost per venue is `2 * walkMinutes + (avgVisitMinutes ?? categoryDefaultDwell)`. Only 10
venues carry authored walk times; the rest use a hash-derived 2-12 minutes and have a null
`avgVisitMinutes`. A per-category default dwell is authored so the strip degrades to a
sensible estimate rather than silently becoming walk-only.

### Edge states

| State | Behaviour |
| --- | --- |
| `freeTime` negative | Strip turns urgent: "You're 6 min behind - skip the stop" |
| All steps done | "You're at the gate" with a boarding countdown |
| Queue data missing | Step renders without the queue stat rather than showing zero |
| Connection tight | Surfaces as a disruption, not a quiet number |
| No journey started | Trip tab routes to Home; there is no empty journey page |

## 7. Testing

**Domain (pure Dart, no Flutter)**
- free-time computation across full, partial and completed journeys
- negative free time when queues exceed the buffer
- `statusOf` derivation and `currentIndex` advancement
- deterministic drift: the same tick count yields the same queue values
- `effectiveGate` reflects a gateChange disruption

**Widget**
- Home renders the three stage cards, and the active one shows live status
- Journey page renders the board at step one and the current-step card after
- Steps page renders every step of both spines
- Every test overrides `journeyProvider`; no test starts a real timer
- No `pumpAndSettle` on the journey page - a 5s ticker never settles

**Honest regression gate.** "All 112 existing tests still pass" is not achievable and
should not be claimed. `app_shell_test.dart` hard-codes `/flights` and the label `Flights`;
`home_density_test.dart` and `home_sections_test.dart` import widget files that are being
deleted, so they fail to compile rather than fail an assertion. The gate is: **the named
retired tests are removed deliberately, every other existing test passes, and the new tests
above are green.**

## 8. Round two: the per-stage pages (user wireframes)

The user supplied wireframes giving each stage two pages. Their structure and
copy are adopted; the app's nav, live simulation, flight picking and visual
style are kept. Mapping:

**Departing** - `/journey` (running) becomes the overview: "Great! You're
departing", illustration-spine card, disruption banner, the do-this-now card,
then the remaining steps as tappable rows and a Need-help card into the
Assistant. `/journey/steps` becomes the Departure Guide: a timeline with green
Complete states, the current step highlighted, and a departure footer card.

**Connecting** - `/journey` (running) is "You're connecting!": a summary card
(estimated process time, departs-in), then the numbered connection journey
with per-step minutes. `/journey/steps` becomes the Connection Plan:
"Everything looks good" checklist derived from the actual steps (passport
present or not, transfer needed), the remaining steps, Start Navigation into
the existing `/navigate` route, and Add to calendar (mock).

**Arrived** - new, not a step journey: `/arrived` is the welcome page with
category shortcuts into Explore, "Popular near you" walk-time tiles, a lounge
card and the live-updates strip. `/arrived/options` lists exits, baggage,
transport and services. The Home card routes there instead of a snackbar.

## 9. Out of scope

- The Arrived stage - baggage belt, exits, ground transport
- Real data of any kind. Journey content is authored mock, per airport
- Boarding passes, in any form. Settled previously and unchanged
- Push notifications for disruptions - in-app only
- Map deep-links from steps. `mapAnchorId` is deferred: the map has no check-in or bag-drop
  POIs, and only one JFK mock gate resolves against the floor data
