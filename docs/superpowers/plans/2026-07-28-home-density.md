# Home Density Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Strip the home screen back to icons and short labels, and give the two flight surfaces bigger type and more air.

**Architecture:** A small drawn icon set (`AppIcon`, same vector approach as the logo) replaces stock Material glyphs in Quick Start, whose model loses its `subtitle` field. Live Departures drops its 5-column table for two-line rows; the upcoming-flight card's four stats become a 2x2 grid.

**Tech Stack:** Flutter (Dart 3), Riverpod, existing `AppColors` / `AppTypography` / `AppShadows` tokens.

## Global Constraints

- **Commits:** user commits ONLY when they ask. Each task ends with a **Checkpoint** (analyze + tests). Do NOT `git commit` unless asked; when asked use trailer `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.
- **Tokens only** - no ad-hoc `Color(0x…)` in feature code.
- **Copy:** hyphen-minus `-` only, no em/en dashes.
- **Amber rule:** amber is wayfinding only. In this workstream it appears in the `navigate` icon and nowhere else.
- **Do not remove `IntrinsicHeight`** from the Quick Start row - it is what prevents the infinite-height crash that produced a blank home screen in release builds.
- **Icon geometry on a 24-unit grid**, scaled by `size / 24`. Never hardcode pixels for one size.

---

## File Structure

**Create:**
- `lib/core/branding/app_icons.dart` - `AppIconKind`, `AppIcon`, `_AppIconPainter`.
- `test/core/app_icons_test.dart`
- `test/features/home/home_density_test.dart`

**Modify:**
- `lib/features/home/presentation/widgets/quick_start_section.dart` - drop `subtitle`, use `AppIcon`, resize.
- `lib/features/home/presentation/home_screen.dart` - update the four `QuickStartItem`s.
- `lib/features/home/presentation/widgets/live_departures_section.dart` - table -> two-line rows.
- `lib/features/home/presentation/widgets/upcoming_flight_card.dart` - 4-across stats -> 2x2 grid.

---

## Task 1: Drawn icon set

**Files:**
- Create: `lib/core/branding/app_icons.dart`
- Test: `test/core/app_icons_test.dart`

**Interfaces:**
- Produces: `enum AppIconKind { flights, navigate, food, shops }`; `class AppIcon extends StatelessWidget` with `AppIcon(AppIconKind kind, {double size = 26, Color? color})`.
- Consumes: `AppColors.ink`, `AppColors.sky`, `AppColors.amber`.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/app_icons_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/core/branding/app_icons.dart';

void main() {
  testWidgets('every icon renders at every size without exception', (t) async {
    for (final k in AppIconKind.values) {
      for (final s in [16.0, 26.0, 44.0]) {
        await t.pumpWidget(MaterialApp(
          home: Scaffold(body: Center(child: AppIcon(k, size: s))),
        ));
        await t.pump();
        expect(t.takeException(), isNull, reason: '$k at $s threw');
      }
    }
  });

  testWidgets('honours an explicit primary colour', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(child: AppIcon(AppIconKind.food, size: 26, color: Colors.red)),
      ),
    ));
    await t.pump();
    expect(t.takeException(), isNull);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/core/app_icons_test.dart`
Expected: FAIL - `Target of URI doesn't exist: '.../app_icons.dart'`.

- [ ] **Step 3: Create `lib/core/branding/app_icons.dart`**

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// The four Quick Start actions, drawn rather than taken from a stock set.
enum AppIconKind { flights, navigate, food, shops }

/// Brand icon. Geometry lives on a 24-unit grid and is scaled by `size / 24`,
/// the same approach as [AppLogo], so the set stays crisp at any size.
class AppIcon extends StatelessWidget {
  final AppIconKind kind;
  final double size;

  /// Overrides the primary (ink) stroke only. The sky detail and the amber
  /// route keep their brand colours so the set stays recognisable.
  final Color? color;

  const AppIcon(this.kind, {super.key, this.size = 26, this.color});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _AppIconPainter(kind: kind, primary: color ?? AppColors.ink),
        ),
      );
}

class _AppIconPainter extends CustomPainter {
  final AppIconKind kind;
  final Color primary;

  const _AppIconPainter({required this.kind, required this.primary});

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.shortestSide / 24.0;

    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Paint fill(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.fill;

    switch (kind) {
      case AppIconKind.flights:
        // Magnifier ring + handle, with a plane inside the lens.
        canvas.drawCircle(Offset(10.5 * k, 10.5 * k), 7.2 * k, stroke(primary, 1.9));
        canvas.drawLine(Offset(15.8 * k, 15.8 * k), Offset(21 * k, 21 * k),
            stroke(primary, 2.1));
        canvas.drawPath(
          Path()
            ..moveTo(14 * k, 7.4 * k)
            ..lineTo(7.2 * k, 10.6 * k)
            ..lineTo(10.1 * k, 11.9 * k)
            ..lineTo(11.3 * k, 14.8 * k)
            ..close(),
          fill(AppColors.sky),
        );
        break;

      case AppIconKind.navigate:
        // Amber dotted route rising to a solid heading arrow.
        final route = Path()
          ..moveTo(3.4 * k, 19.6 * k)
          ..quadraticBezierTo(8 * k, 19 * k, 10.4 * k, 14.4 * k);
        final dot = fill(AppColors.amber);
        for (final m in route.computeMetrics()) {
          for (double d = 0; d <= m.length; d += 4.4 * k) {
            final tan = m.getTangentForOffset(d);
            if (tan != null) canvas.drawCircle(tan.position, 1.05 * k, dot);
          }
        }
        canvas.drawPath(
          Path()
            ..moveTo(20.4 * k, 4.2 * k)
            ..lineTo(12 * k, 9.2 * k)
            ..lineTo(16 * k, 11 * k)
            ..lineTo(17.6 * k, 15 * k)
            ..close(),
          fill(primary),
        );
        canvas.drawCircle(Offset(3.4 * k, 19.6 * k), 2 * k, fill(primary));
        break;

      case AppIconKind.food:
        // Fork (ink) + knife (sky).
        canvas.drawLine(Offset(6.6 * k, 3.4 * k), Offset(6.6 * k, 20.6 * k),
            stroke(primary, 1.9));
        canvas.drawArc(
          Rect.fromLTWH(4 * k, 3.4 * k, 5.2 * k, 7.2 * k),
          0, 3.14159, false, stroke(primary, 1.8),
        );
        canvas.drawLine(Offset(4 * k, 4.2 * k), Offset(4 * k, 7 * k), stroke(primary, 1.8));
        canvas.drawLine(Offset(9.2 * k, 4.2 * k), Offset(9.2 * k, 7 * k), stroke(primary, 1.8));
        canvas.drawPath(
          Path()
            ..moveTo(16.6 * k, 3.4 * k)
            ..cubicTo(14.6 * k, 5 * k, 14.2 * k, 8 * k, 15.2 * k, 10 * k)
            ..lineTo(18 * k, 10 * k)
            ..cubicTo(19 * k, 8 * k, 18.6 * k, 5 * k, 16.6 * k, 3.4 * k)
            ..close(),
          stroke(AppColors.sky, 1.8),
        );
        canvas.drawLine(Offset(16.6 * k, 10 * k), Offset(16.6 * k, 20.6 * k),
            stroke(AppColors.sky, 1.9));
        break;

      case AppIconKind.shops:
        // Bag body (ink) + handle (sky).
        canvas.drawPath(
          Path()
            ..moveTo(4.6 * k, 8.4 * k)
            ..lineTo(19.4 * k, 8.4 * k)
            ..lineTo(18.3 * k, 20 * k)
            ..arcToPoint(Offset(16.7 * k, 21.4 * k),
                radius: Radius.circular(1.6 * k))
            ..lineTo(7.3 * k, 21.4 * k)
            ..arcToPoint(Offset(5.7 * k, 20 * k),
                radius: Radius.circular(1.6 * k))
            ..close(),
          stroke(primary, 1.9),
        );
        canvas.drawArc(
          Rect.fromLTWH(8.9 * k, 3.5 * k, 6.2 * k, 6.2 * k),
          3.14159, 3.14159, false, stroke(AppColors.sky, 1.9),
        );
        canvas.drawLine(Offset(8.9 * k, 6.6 * k), Offset(8.9 * k, 10.4 * k),
            stroke(AppColors.sky, 1.9));
        canvas.drawLine(Offset(15.1 * k, 6.6 * k), Offset(15.1 * k, 10.4 * k),
            stroke(AppColors.sky, 1.9));
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _AppIconPainter old) =>
      old.kind != kind || old.primary != primary;
}
```

- [ ] **Step 4: Run tests + analyze**

Run: `flutter test test/core/app_icons_test.dart` -> Expected: PASS (2 tests).
Run: `flutter analyze lib/core/branding` -> Expected: `No issues found!`

- [ ] **Step 5: Checkpoint** - do not commit.

---

## Task 2: Quick Start - icon + one word

**Files:**
- Modify: `lib/features/home/presentation/widgets/quick_start_section.dart`, `lib/features/home/presentation/home_screen.dart`
- Test: `test/features/home/home_density_test.dart` (create)

**Interfaces:**
- Consumes: `AppIcon`, `AppIconKind`.
- Produces: `QuickStartItem({required AppIconKind icon, required String label, required VoidCallback onTap})` - **`subtitle` and the old `title` are gone**; the field is now `label`.

- [ ] **Step 1: Write the failing test**

```dart
// test/features/home/home_density_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/core/branding/app_icons.dart';
import 'package:airport_nav/features/home/presentation/widgets/quick_start_section.dart';

void main() {
  testWidgets('Quick Start shows one word per card and no subtitles',
      (t) async {
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: QuickStartSection(items: [
          QuickStartItem(icon: AppIconKind.flights, label: 'Flights', onTap: () {}),
          QuickStartItem(icon: AppIconKind.navigate, label: 'Navigate', onTap: () {}),
          QuickStartItem(icon: AppIconKind.food, label: 'Food', onTap: () {}),
          QuickStartItem(icon: AppIconKind.shops, label: 'Shops', onTap: () {}),
        ]),
      ),
    ));
    await t.pump();

    for (final w in ['Flights', 'Navigate', 'Food', 'Shops']) {
      expect(find.text(w), findsOneWidget);
    }
    // The old three-line copy must be gone.
    expect(find.text('See live departures'), findsNothing);
    expect(find.text('Get to your gate'), findsNothing);
    expect(find.text('Find My Flight'), findsNothing);
    expect(find.byType(AppIcon), findsNWidgets(4));
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/home/home_density_test.dart`
Expected: FAIL - `QuickStartItem` has no named parameter `label`.

- [ ] **Step 3: Rewrite `QuickStartItem` and `_QuickStartCard`**

In `quick_start_section.dart`, add the import:

```dart
import '../../../../core/branding/app_icons.dart';
```

Replace the `QuickStartItem` class with:

```dart
/// A single Quick Start action - a drawn icon and one word.
class QuickStartItem {
  final AppIconKind icon;
  final String label;
  final VoidCallback onTap;

  const QuickStartItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
```

Replace the body of `_QuickStartCard.build`'s `Padding`/`Column` with:

```dart
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon(item.icon, size: 26, color: iconColor),
                const SizedBox(height: 12),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
```

Delete the now-unused `subColor` local.

- [ ] **Step 4: Update the four items in `home_screen.dart`**

Add the import `import '../../../core/branding/app_icons.dart';` and replace the
four `QuickStartItem(...)` entries with:

```dart
                  QuickStartItem(
                    icon: AppIconKind.flights,
                    label: 'Flights',
                    onTap: () => context.go('/flights'),
                  ),
                  QuickStartItem(
                    icon: AppIconKind.navigate,
                    label: 'Navigate',
                    onTap: () => context.go('/map'),
                  ),
                  QuickStartItem(
                    icon: AppIconKind.food,
                    label: 'Food',
                    onTap: () => context.go('/explore'),
                  ),
                  QuickStartItem(
                    icon: AppIconKind.shops,
                    label: 'Shops',
                    onTap: () => context.go('/explore'),
                  ),
```

- [ ] **Step 5: Run tests + analyze**

Run: `flutter test test/features/home/home_density_test.dart test/home_screen_test.dart`
-> Expected: PASS.
Run: `flutter analyze lib` -> Expected: `No issues found!`

- [ ] **Step 6: Checkpoint** - do not commit.

---

## Task 3: Live Departures - two-line rows

**Files:**
- Modify: `lib/features/home/presentation/widgets/live_departures_section.dart`
- Test: `test/features/home/home_density_test.dart` (add)

**Interfaces:**
- Public API of `LiveDeparturesSection` is unchanged (`flights`, `selectedFlightId`, `onSelect`, `onSeeAll`), so `home_screen.dart` needs no edit.

- [ ] **Step 1: Add the failing test**

Append to `test/features/home/home_density_test.dart`:

```dart
  testWidgets('Live Departures uses rows, not a column-header table', (t) async {
    final now = DateTime.now().add(const Duration(hours: 1));
    final flight = Flight(
      id: 'f1', flightNumber: 'DL 1234', airline: 'Delta', airlineLogo: '',
      departureAirport: 'JFK', departureCity: 'New York',
      arrivalAirport: 'ATL', arrivalCity: 'Atlanta',
      departureTime: now, arrivalTime: now.add(const Duration(hours: 2)),
      status: 'on_time', gate: 'A12', terminal: '4',
    );

    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LiveDeparturesSection(
          flights: [flight],
          selectedFlightId: null,
          onSelect: (_) {},
          onSeeAll: () {},
        ),
      ),
    ));
    await t.pump();

    // Facts still present.
    expect(find.text('DL 1234'), findsOneWidget);
    expect(find.text('Atlanta (ATL)'), findsOneWidget);
    expect(find.text('A12'), findsOneWidget);
    // Column headers gone.
    expect(find.text('FLIGHT'), findsNothing);
    expect(find.text('DESTINATION'), findsNothing);
    expect(find.text('STATUS'), findsNothing);
  });
```

Add these imports at the top of the test file:

```dart
import 'package:airport_nav/features/flight/domain/entities/flight.dart';
import 'package:airport_nav/features/home/presentation/widgets/live_departures_section.dart';
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/home/home_density_test.dart`
Expected: FAIL - `Expected: no matching candidates / Actual: found 1` for `FLIGHT`.

- [ ] **Step 3: Rewrite the section internals**

In `live_departures_section.dart`:

1. Delete the column-weight constants (`_tileSize`, `_leadGap`, `_leadW`,
   `_flightFlex`, `_destFlex`, `_timeFlex`, `_gateFlex`, `_statusFlex`) and the
   entire `_HeaderRow` class.
2. Remove `_HeaderRow(...)` from the `Column` children and drop the now-unused
   `headerBg` local.
3. Replace `_DeparturesRow.build`'s `rowContent` with:

```dart
    final rowContent = Row(
      children: [
        AirlineTile(
          flightNumber: flight.flightNumber,
          size: 38,
          selected: selected,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Expanded(
                    child: Text(
                      flight.flightNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.mono(
                        fontSize: 16,
                        weight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: AppTypography.mono(
                      fontSize: 16,
                      weight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${flight.arrivalCity} (${flight.arrivalAirport})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: mutedColor, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (flight.gate != null) ...[
                    Text(
                      flight.gate!,
                      style: AppTypography.mono(
                        fontSize: 12,
                        weight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  StatusBadge(
                    status: flight.status,
                    delayMinutes: flight.delayMinutes,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
```

4. Update the two row containers' padding to
   `const EdgeInsets.fromLTRB(12, 13, 12, 13)` (unselected) and
   `const EdgeInsets.symmetric(horizontal: 8, vertical: 11)` (selected).

- [ ] **Step 4: Run tests + analyze**

Run: `flutter test test/features/home/home_density_test.dart` -> Expected: PASS.
Run: `flutter analyze lib` -> Expected: `No issues found!`

- [ ] **Step 5: Checkpoint** - do not commit.

---

## Task 4: Upcoming Flight - 2x2 stats, then verify

**Files:**
- Modify: `lib/features/home/presentation/widgets/upcoming_flight_card.dart`
- Test: `test/features/home/home_density_test.dart` (add)

- [ ] **Step 1: Add the failing test**

Append to `test/features/home/home_density_test.dart` (reuse the `Flight` import
added in Task 3):

```dart
  testWidgets('UpcomingFlightCard shows all four stats with large values',
      (t) async {
    final now = DateTime.now().add(const Duration(hours: 2));
    final flight = Flight(
      id: 'f2', flightNumber: 'AA 2468', airline: 'American', airlineLogo: '',
      departureAirport: 'JFK', departureCity: 'New York',
      arrivalAirport: 'ORD', arrivalCity: 'Chicago',
      departureTime: now, arrivalTime: now.add(const Duration(hours: 3)),
      status: 'on_time', gate: 'C18', terminal: '4',
    );

    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: UpcomingFlightCard(flight: flight, onTap: () {}),
        ),
      ),
    ));
    await t.pump();

    for (final label in ['Gate', 'Departs', 'Est. walk', 'Terminal']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('C18'), findsOneWidget);
    expect(find.text('T4'), findsOneWidget);
  });
```

Add the import:

```dart
import 'package:airport_nav/features/home/presentation/widgets/upcoming_flight_card.dart';
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/home/home_density_test.dart`
Expected: FAIL - `Est. walk` not found (the current label is `Est. Walk`).

- [ ] **Step 3: Replace the stats row with a 2x2 grid**

In `upcoming_flight_card.dart`, replace the four-`_Stat` `Row` with:

```dart
                    // ── Bottom: 2x2 stat grid ─────────────────────────
                    Row(
                      children: [
                        _Stat(
                          icon: Icons.meeting_room_outlined,
                          label: 'Gate',
                          value: flight.gate ?? '-',
                        ),
                        const SizedBox(width: 12),
                        _Stat(
                          icon: Icons.schedule_rounded,
                          label: 'Departs',
                          value: clock.format(flight.departureTime),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _Stat(
                          icon: Icons.directions_walk_rounded,
                          label: 'Est. walk',
                          value: '${estimatedWalkMinutes(flight.gate)} min',
                        ),
                        const SizedBox(width: 12),
                        _Stat(
                          icon: Icons.apartment_rounded,
                          label: 'Terminal',
                          value: 'T${flight.terminal ?? '-'}',
                        ),
                      ],
                    ),
```

Replace `_Stat.build`'s `Column` with an inline icon + label above a large value:

```dart
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: mutedColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: mutedColor, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
```

- [ ] **Step 4: Full verify**

Run: `flutter test` -> Expected: **all pass, 0 failures.**
Run: `flutter analyze lib test` -> Expected: `No issues found!`

- [ ] **Step 5: Emulator**

```bash
cd /c/Users/Haim/Documents/projects/example-project/airport_nav
ADB="/c/Users/Haim/AppData/Local/Android/Sdk/platform-tools/adb.exe"
flutter build apk --release
"$ADB" -s emulator-5554 install -r build/app/outputs/flutter-apk/app-release.apk
"$ADB" -s emulator-5554 shell am force-stop com.airportnav.airport_nav
"$ADB" -s emulator-5554 shell am start -n com.airportnav.airport_nav/.MainActivity
```

Wait ~5s, then `"$ADB" -s emulator-5554 exec-out screencap -p > shot.png` and confirm:
1. Quick Start shows four drawn icons with single-word labels and no subtitles
2. Departures rows are visibly larger, no column header
3. Scrolling down, the upcoming-flight stats read as a 2x2 grid with large values

Delete screenshots afterwards.

- [ ] **Step 6: Checkpoint** - summarise; offer to commit (only on request).

---

## Self-Review

**Spec coverage:** §2 icon set -> Task 1. §3 Quick Start -> Task 2 (incl. `IntrinsicHeight`
preserved via Global Constraints). §4 Live Departures -> Task 3. §5 Upcoming Flight -> Task 4.
§7 verification -> Tasks 1-4 plus Task 4 Step 5.

**Placeholder scan:** none. Task 3 Step 3 describes deletions against existing code by exact
identifier (`_HeaderRow`, the flex constants) and gives the full replacement widget tree.

**Type consistency:** `QuickStartItem({icon: AppIconKind, label: String, onTap})` is used
identically in Tasks 2's widget, its test, and `home_screen.dart`. `AppIcon(kind, {size, color})`
matches between Tasks 1 and 2. `LiveDeparturesSection`'s constructor is unchanged, so Task 3
needs no caller edits. `estimatedWalkMinutes` (already in `upcoming_flight_card.dart`) is reused
in Task 4 rather than redefined.
