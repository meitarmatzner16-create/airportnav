# The Airport Journey - design

**Date:** 2026-07-31
**Status:** approved by user, ready for planning
**Proposal mockups:** https://claude.ai/code/artifact/26ba6341-c527-4ea6-9df0-b44538c2b94a

---

## 1. The problem

AirportNav's thesis is that every piece of information in an airport is physical -
printed on a wall, a desk sign, or announced over a speaker - and the product exists to
make it digital. Home does not currently honour that. It tells you about your **flight**;
it says nothing about your **passage through the building**.

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

## 2. The model

Treat the airport as what it is: a sequence of gates you must pass. The app answers the
**same four questions at every step**, which is what makes this a system rather than a
pile of screens.

**Departing spine:** Check-in → Bag drop → Security → Passport → Gate → Boarding

**Connecting spine:** Arrive → Transfer walk → Security (again) → Passport → Next gate → Boarding

Four questions per step:

| Question | Meaning |
| --- | --- |
| **Where** | The thing currently printed on a sign - zone 3, lane B, gate B22 |
| **By when** | The deadline that actually matters, not the departure time |
| **How long** | Queue minutes **plus** walking minutes |
| **What changed** | Gate moved, lane closed, boarding early |

### The number that only this app can produce

Summing the remaining steps yields projected gate arrival, and therefore **free time**:

```
projectedGateArrival = now + Σ(remaining step.queueMinutes + step.walkMinutes)
freeTime             = boardingTime - projectedGateArrival
```

No sign in the building can compute that. It is what turns process data into a
recommendation - "you have 25 minutes, the Centurion Lounge is 4 minutes away" - and it
is what connects this feature to the venue and lounge work already built.

## 3. Decisions taken

| Decision | Choice |
| --- | --- |
| Home | **Concept A - Next Step.** One dominant card plus a compact spine |
| Trip tab | **Concept B - full timeline.** The whole journey, one row per step |
| Navigation | Home · Explore · Assistant · **Trip** · Map. Trip replaces Flights |
| Data | **Live-feeling mock.** Queue times drift, steps advance, one scripted disruption |
| Stages | **Departing + Connecting.** Arrived is deferred |

Rejected from the source wireframe, with reasons:

- **"What are you doing today?" as a home page.** It is a first-run question. The app
  already knows the flight; asking every launch makes Home a menu.
- **Stage cards carrying no data.** Three doors with no information contradict the thesis.
- **"Popular right now".** Duplicates Explore and is identical for every user. Replaced by
  "fits in your free time", which is personal and computable.
- **Nav bar of Home · Map · My Trip · Saved · Profile.** Drops Explore and Assistant, both
  built, and Assistant is the app's signature centre tab.

## 4. Domain model

New feature: `lib/features/journey/`.

```dart
enum JourneyStage { departing, connecting }

enum StepKind {
  checkIn, bagDrop, security, passport, gate, boarding,   // departing
  arrive, transfer, transferSecurity,                      // connecting extras
}

enum StepStatus { done, current, upcoming, skipped }

class JourneyStep {
  final StepKind kind;
  final String title;          // "Security"
  final String where;          // "Terminal 4 · Main checkpoint · Lane B"
  final String? note;          // "Fast Track open - your ticket qualifies"
  final DateTime? deadline;    // by when
  final int queueMinutes;      // how long - the live-drifting value
  final int walkMinutes;
  final StepStatus status;
  final DateTime? completedAt;
  final String? mapAnchorId;   // ties a step to a point on the terminal map
}

class Journey {
  final JourneyStage stage;
  final Flight flight;         // the flight being caught
  final Flight? inboundFlight; // connecting only
  final List<JourneyStep> steps;
  final DateTime boardingTime;
  final DateTime gateClosesAt;

  int get currentIndex;
  JourneyStep? get currentStep;
  JourneyStep? get nextStep;
  Duration get projectedGateArrival;
  Duration get freeTime;       // may be negative - see states below
}
```

`Flight` is unchanged. Journey data is layered on top by id, so nothing existing breaks.

### Disruption

```dart
enum DisruptionKind { gateChange, queueSpike, boardingEarly, laneClosed }

class Disruption {
  final DisruptionKind kind;
  final String headline;       // "Gate changed to B14"
  final String detail;
  final DateTime firedAt;
}
```

A disruption is not a notification tucked in a strip. When one is live it **takes over the
top of Home**, above the next-step card. If your gate moves, that is the page.

**Dismissal.** A disruption is acknowledged, not dismissed: tapping it collapses the banner
to a single line that stays until the affected step is complete. A gate change must not be
able to scroll out of the user's life because they tapped once.

## 5. Live simulation

A `journeyTickProvider` drives the sense of life. Every 5 seconds it:

1. drifts each upcoming step's `queueMinutes` within a per-step band (security 8-18, passport 2-6)
2. advances `currentIndex` when the current step's dwell has elapsed
3. fires one scripted `Disruption` at a fixed offset from session start

**Constraints, learned from the splash-screen test failure:**

- The ticker lives behind a provider that tests override with a fixed `Journey`. No widget
  test may start a real timer - pending timers fail the suite.
- Drift is seeded and deterministic given a tick count, so tests can assert exact values.
- `Journey` is pure and has no timer of its own; the provider owns all motion.

## 6. Screens

### Home - `/home`

Top to bottom:

1. **Header** - mark, flight number, route, time, status chip
2. **Disruption banner** - conditional, highest priority
3. **JourneySpine** - six compact dots, amber for done, sky for current
4. **NextStepCard** - the hero. Kicker "Do this now", step title, where, note, and a
   three-up stat row: Queue / Walk / Be there by
5. **ThenCard** - the step after, quiet
6. **FreeTimeStrip** - "You'll have 25 free minutes" plus venue suggestions filtered by
   walk time against that number
7. **Live Departures** - kept, unchanged
8. **Assistant entry** - kept, unchanged

**Leaving Home** - flagged for explicit review:

| Element | Why it goes |
| --- | --- |
| Hero banner | The next-step card is now the page's hero; two heroes compete |
| Quick Start (4 tiles) | Its four actions are served by the free-time strip and the tab bar |
| Search bar | Flight search belongs to Trip, where you choose your flight; venue search is already on Explore |

### Trip - `/trip`

Replaces `/flights` in the tab bar. Contains:

1. **Flight summary** - Gate closes / Time left / Steps left
2. **JourneyTimeline** - one row per step, gutter dot and connecting line, each row carrying
   where, when, queue and walk
3. **Stage switch** - Departing / Connecting, only when the trip has a connection
4. **Change flight** - opens the existing flights board, unchanged, as step zero

**Routing.** `/trip` is the new tab route. `/flights` stays exactly as it is - same screen,
same code - but leaves the tab bar and is reached from Trip's "Change flight". Selecting a
flight there returns to Trip with the journey rebuilt around the new flight. Nothing about
the board itself changes.

### Empty state

No flight selected means no journey. Home shows a single card - "Choose your flight to see
your way through the airport" - routing to the board. This is the only state where Home
asks the user for something.

### Edge states

| State | Behaviour |
| --- | --- |
| `freeTime` negative | Strip turns urgent: "You're 6 min behind - skip the stop" |
| All steps done | "You're at the gate" with boarding countdown |
| Queue data missing | Step renders without the queue stat rather than showing zero |
| Connecting, tight | Connection risk surfaces as a disruption, not a quiet number |

## 7. Testing

**Domain (pure, fast)**
- free-time computation across full, partial and completed journeys
- negative free time when queues exceed the buffer
- step status derivation and `currentIndex` advancement
- deterministic drift: same tick count yields the same queue values

**Widget**
- Home renders in each state: no flight, mid-journey, disruption live, all steps done
- Trip timeline renders every step of both spines
- No pending timers in any test - the tick provider is always overridden
- Title placement holds at 12px, per the existing `ScreenHeader` tests

**Regression**
- the existing 112 tests continue to pass; flights-board tests follow the screen to Trip

## 8. Out of scope

- The Arrived stage - baggage belt, exits, ground transport
- Any real data source. All journey data is mock, per airport and flight
- Boarding passes, in any form. Settled previously and unchanged
- Push notifications for disruptions - in-app only for now
