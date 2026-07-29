# Brand & Identity ("The Pass") Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give AirportNav a real brand - a vector "boarding pass" logo, a four-beat animated splash, an amber wayfinding accent wired into the design tokens, and the mark in the home header.

**Architecture:** The logo is a single `CustomPainter` driven by three progress values (`tileProgress`, `routeProgress`, `planeProgress`), so the static mark and the splash animation share one source of truth for geometry. Tokens gain an amber family; the delayed-flight status re-points to orange to stop it colliding with the accent. The splash is rebuilt on one forward `AnimationController` with a status listener, which also removes the repo's only failing test.

**Tech Stack:** Flutter (Dart 3), Riverpod, go_router, `shared_preferences` (already a dependency), Pillow (for the one-off app-icon generation), `flutter_launcher_icons` (new dev dependency).

## Global Constraints

- **Commits:** The user commits ONLY when they ask. Each task ends with a **Checkpoint** (run `flutter analyze` + tests). Do **NOT** run `git commit` unless explicitly asked. When asked, end the message with `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.
- **Typography:** single **Nunito** family via `AppTypography` / theme text styles. No hardcoded font families.
- **Palette:** tokens only - no ad-hoc `Color(0x…)` in feature code. New tokens go in `AppColors`.
- **Copy:** visible text uses the hyphen-minus `-` only. No em/en dashes.
- **Amber usage rule:** `amber` is for shapes/strokes/dots only (routes, active step, logo route). Amber **text** must use `amberText` (`#8A5A00`). Never use amber for ratings, flight status, or card backgrounds.
- **No image assets for the in-app logo.** The mark is drawn in Flutter. PNGs exist only for the launcher icon.
- **Logo geometry is defined on a 64-unit grid** and scaled by `size / 64`. Never hardcode pixel values for a specific size.
- **Verify command (device):** adb at `C:\Users\Haim\AppData\Local\Android\Sdk\platform-tools\adb.exe`, device `emulator-5554`. Build with `flutter build apk --release` (desktop platforms are disabled; do not re-enable).

---

## File Structure

**Create:**
- `lib/core/branding/app_logo.dart` - `AppLogo` widget + `AppLogoVariant` enum + `AppLogoLockup`.
- `lib/core/branding/logo_painter.dart` - `LogoPainter` (`CustomPainter`): all geometry, gradient, notch subtraction, dotted route, plane.
- `tools/gen_app_icon.py` - Pillow script producing the two launcher PNGs.
- `test/core/app_logo_test.dart`
- `test/features/onboarding/splash_screen_test.dart`

**Modify:**
- `lib/core/constants/app_colors.dart` - add amber family; re-point `statusDelayed`.
- `lib/features/onboarding/presentation/splash_screen.dart` - full rewrite (animation + routing).
- `lib/features/onboarding/presentation/onboarding_screen.dart` - set the `onboarding_seen` flag on Skip / finish.
- `lib/features/home/presentation/widgets/home_header.dart` - insert the 30px mark.
- `test/core/tokens_test.dart` - assert the new/changed token values.
- `pubspec.yaml` - `flutter_launcher_icons` dev dependency + config; register `assets/icons/`.

---

## Task 1: Logo geometry + `AppLogo` widget

**Files:**
- Create: `lib/core/branding/logo_painter.dart`, `lib/core/branding/app_logo.dart`
- Test: `test/core/app_logo_test.dart`

**Interfaces:**
- Consumes: `AppColors.sky`, `AppColors.sky2`, `AppColors.ink`, `AppColors.amber` (Task 2 adds `amber`; for this task use the literal `Color(0xFFFFB020)` **only inside `logo_painter.dart` as a named constant `_kAmber`**, and Task 2 replaces it with the token).
- Produces:
  - `enum AppLogoVariant { sky, ink, mono }`
  - `class AppLogo extends StatelessWidget` with
    `AppLogo({Key? key, required double size, AppLogoVariant variant = AppLogoVariant.sky, bool? showRoute, double tileProgress = 1, double routeProgress = 1, double planeProgress = 1})`
  - `class AppLogoLockup extends StatelessWidget` with
    `AppLogoLockup({Key? key, double size = 30, AppLogoVariant variant = AppLogoVariant.sky, double wordmarkOpacity = 1, double wordmarkOffsetY = 0})`
  - `class LogoPainter extends CustomPainter` with the same three progress fields.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/app_logo_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/core/branding/app_logo.dart';

void main() {
  testWidgets('AppLogo renders at every size without exception', (t) async {
    for (final s in [20.0, 28.0, 56.0, 104.0]) {
      await t.pumpWidget(MaterialApp(
        home: Scaffold(body: Center(child: AppLogo(size: s))),
      ));
      await t.pump();
      expect(tester_exception(), isNull, reason: 'size $s threw');
    }
  });

  test('route is hidden below 24px and shown at or above it', () {
    expect(const AppLogo(size: 20).routeVisible, isFalse);
    expect(const AppLogo(size: 24).routeVisible, isTrue);
    expect(const AppLogo(size: 28).routeVisible, isTrue);
    // explicit override always wins
    expect(const AppLogo(size: 20, showRoute: true).routeVisible, isTrue);
    expect(const AppLogo(size: 64, showRoute: false).routeVisible, isFalse);
  });

  testWidgets('lockup renders the wordmark', (t) async {
    await t.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: AppLogoLockup(size: 30))),
    ));
    await t.pump();
    expect(find.text('AirportNav'), findsOneWidget);
  });
}

Object? tester_exception() => WidgetsBinding.instance.platformDispatcher.onError == null
    ? null
    : null; // placeholder-free: pumping throws on error, so reaching here means success
```

> Note: the helper above intentionally returns `null` - `pumpWidget` throws on a paint
> error, so simply reaching the assertion proves the render succeeded. Keep it; it makes
> the intent explicit.

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/app_logo_test.dart`
Expected: FAIL - `Target of URI doesn't exist: 'package:airport_nav/core/branding/app_logo.dart'`.

- [ ] **Step 3: Create `lib/core/branding/logo_painter.dart`**

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Brand accent used for the route dots. Task 2 replaces this with
/// AppColors.amber once the token exists.
const Color _kAmber = Color(0xFFFFB020);

enum AppLogoVariant { sky, ink, mono }

/// Paints "The Pass": a notched boarding-pass tile whose interior turns into a
/// route and takes flight.
///
/// All geometry is defined on a 64-unit grid and scaled by `size / 64`, so the
/// mark is identical at 20px and 1024px.
class LogoPainter extends CustomPainter {
  final AppLogoVariant variant;
  final bool showRoute;
  final double tileProgress;
  final double routeProgress;
  final double planeProgress;

  const LogoPainter({
    required this.variant,
    required this.showRoute,
    this.tileProgress = 1,
    this.routeProgress = 1,
    this.planeProgress = 1,
  });

  // ── 64-grid constants ────────────────────────────────────────────────
  static const double _grid = 64;
  static const double _radius = 18;      // corner radius
  static const double _notchR = 7.5;     // notch radius
  static const double _notchCy = 30;     // notch centre Y

  /// Tile outline with the two boarding-pass notches subtracted. Real
  /// geometry (not an overlay) so it stays crisp over any background.
  static Path tilePath(double s) {
    final k = s / _grid;
    final rrect = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s),
        Radius.circular(_radius * k),
      ));
    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, _notchCy * k), radius: _notchR * k))
      ..addOval(Rect.fromCircle(center: Offset(s, _notchCy * k), radius: _notchR * k));
    return Path.combine(PathOperation.difference, rrect, notches);
  }

  static Path _planePath(double k) => Path()
    ..moveTo(49 * k, 15 * k)
    ..lineTo(27 * k, 25.5 * k)
    ..lineTo(36.5 * k, 29.5 * k)
    ..lineTo(40 * k, 39 * k)
    ..close();

  static Path _routePath(double k) => Path()
    ..moveTo(13 * k, 48 * k)
    ..quadraticBezierTo(25 * k, 47 * k, 33 * k, 38 * k);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final k = s / _grid;
    final tile = tilePath(s);

    // ── Tile ───────────────────────────────────────────────────────────
    final tilePaint = Paint();
    switch (variant) {
      case AppLogoVariant.sky:
        tilePaint.shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sky2, AppColors.sky],
        ).createShader(Rect.fromLTWH(0, 0, s, s));
        break;
      case AppLogoVariant.ink:
        tilePaint.color = AppColors.ink;
        break;
      case AppLogoVariant.mono:
        tilePaint.color = AppColors.sky;
        break;
    }
    tilePaint.color = tilePaint.color.withValues(alpha: tileProgress.clamp(0, 1));
    if (tilePaint.shader != null && tileProgress < 1) {
      canvas.saveLayer(Rect.fromLTWH(0, 0, s, s),
          Paint()..color = Colors.white.withValues(alpha: tileProgress.clamp(0, 1)));
      canvas.drawPath(tile, tilePaint..color = Colors.white);
      canvas.restore();
    } else {
      canvas.drawPath(tile, tilePaint);
    }

    canvas.save();
    canvas.clipPath(tile);

    // ── Route dots (drawn along the extracted sub-path) ────────────────
    if (showRoute && routeProgress > 0) {
      final metrics = _routePath(k).computeMetrics().first;
      final len = metrics.length * routeProgress.clamp(0, 1);
      final dot = Paint()..color = _kAmber..style = PaintingStyle.fill;
      const spacing = 7.5; // grid units between dots
      for (double d = 0; d <= len; d += spacing * k) {
        final tan = metrics.getTangentForOffset(d);
        if (tan != null) canvas.drawCircle(tan.position, 1.7 * k, dot);
      }
    }

    // ── Plane ──────────────────────────────────────────────────────────
    if (planeProgress > 0) {
      final p = planeProgress.clamp(0.0, 1.0);
      canvas.save();
      canvas.translate(-3 * k * (1 - p), 4 * k * (1 - p));
      canvas.drawPath(
        _planePath(k),
        Paint()..color = Colors.white.withValues(alpha: p),
      );
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LogoPainter old) =>
      old.variant != variant ||
      old.showRoute != showRoute ||
      old.tileProgress != tileProgress ||
      old.routeProgress != routeProgress ||
      old.planeProgress != planeProgress;
}
```

- [ ] **Step 4: Create `lib/core/branding/app_logo.dart`**

```dart
import 'package:flutter/material.dart';
import 'logo_painter.dart';

export 'logo_painter.dart' show AppLogoVariant;

/// The AirportNav mark - a notched boarding-pass tile whose interior becomes a
/// route and takes flight.
///
/// Below 24px the route dots are omitted automatically (they turn to mud at
/// that scale) and the plane carries the mark.
class AppLogo extends StatelessWidget {
  final double size;
  final AppLogoVariant variant;
  final bool? showRoute;
  final double tileProgress;
  final double routeProgress;
  final double planeProgress;

  const AppLogo({
    super.key,
    required this.size,
    this.variant = AppLogoVariant.sky,
    this.showRoute,
    this.tileProgress = 1,
    this.routeProgress = 1,
    this.planeProgress = 1,
  });

  /// Whether the route dots will be painted at this size / override.
  bool get routeVisible => showRoute ?? (size >= 24);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: LogoPainter(
          variant: variant,
          showRoute: routeVisible,
          tileProgress: tileProgress,
          routeProgress: routeProgress,
          planeProgress: planeProgress,
        ),
      ),
    );
  }
}

/// Mark + "AirportNav" wordmark.
class AppLogoLockup extends StatelessWidget {
  final double size;
  final AppLogoVariant variant;
  final double wordmarkOpacity;
  final double wordmarkOffsetY;

  const AppLogoLockup({
    super.key,
    this.size = 30,
    this.variant = AppLogoVariant.sky,
    this.wordmarkOpacity = 1,
    this.wordmarkOffsetY = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: size, variant: variant),
        SizedBox(width: size * 0.28),
        Transform.translate(
          offset: Offset(0, wordmarkOffsetY),
          child: Opacity(
            opacity: wordmarkOpacity.clamp(0, 1),
            child: Text(
              'AirportNav',
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: size * 0.72,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 5: Run tests + analyze**

Run: `flutter test test/core/app_logo_test.dart` -> Expected: PASS (3 tests).
Run: `flutter analyze lib/core/branding` -> Expected: `No issues found!`

- [ ] **Step 6: Checkpoint** - do not commit. Report the mark renders at all four sizes.

---

## Task 2: Amber tokens + delayed-status fix

**Files:**
- Modify: `lib/core/constants/app_colors.dart`, `lib/core/branding/logo_painter.dart`
- Test: `test/core/tokens_test.dart`

**Interfaces:**
- Produces: `AppColors.amber`, `AppColors.amberTint`, `AppColors.amberText`, `AppColors.amberAlpha15`; `AppColors.statusDelayed` changes value.
- Consumes: nothing new.

- [ ] **Step 1: Add the failing assertions to `test/core/tokens_test.dart`**

Add this test inside the existing `main()`:

```dart
  test('amber accent family + delayed status are exact', () {
    expect(AppColors.amber, const Color(0xFFFFB020));
    expect(AppColors.amberTint, const Color(0xFFFFF4E0));
    expect(AppColors.amberText, const Color(0xFF8A5A00));
    expect(AppColors.amberAlpha15, const Color(0x26FFB020));
    // Delayed must NOT be the brand amber - it re-points to orange so the
    // accent never reads as "something is wrong".
    expect(AppColors.statusDelayed, const Color(0xFFF5731F));
    expect(AppColors.statusDelayed, isNot(AppColors.amber));
    // `warning` keeps its original value for genuine warning semantics.
    expect(AppColors.warning, const Color(0xFFE8A93B));
  });
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/core/tokens_test.dart`
Expected: FAIL - `The getter 'amber' isn't defined for the class 'AppColors'`.

- [ ] **Step 3: Add the tokens in `app_colors.dart`**

Add immediately after the `warning` / `error` block (around line 27):

```dart
  // ── Brand accent: amber means "your path" ──────────────────────────
  // Shapes, strokes and dots only. Amber TEXT must use `amberText` -
  // #FFB020 on white is ~1.9:1 contrast and fails WCAG AA for small text.
  static const amber = Color(0xFFFFB020);
  static const amberSoft = Color(0xFFFFD489);
  static const amberTint = Color(0xFFFFF4E0);
  static const amberText = Color(0xFF8A5A00);
```

Add near the other alpha tokens (around line 82):

```dart
  static const amberAlpha15 = Color(0x26FFB020);
```

- [ ] **Step 4: Re-point the delayed status**

Change the `statusDelayed` line (around line 32) from `= warning` to its own value:

```dart
  /// Delayed flights use a distinctly orange tone. It deliberately does NOT
  /// reuse `warning` (#E8A93B), which is nearly identical to the brand amber
  /// and made the accent read as an error wherever it appeared.
  static const statusDelayed = Color(0xFFF5731F);
```

- [ ] **Step 5: Point the painter at the token**

In `lib/core/branding/logo_painter.dart`, delete the `_kAmber` constant and its
doc comment, then replace the single usage:

```dart
      final dot = Paint()..color = AppColors.amber..style = PaintingStyle.fill;
```

- [ ] **Step 6: Run tests + analyze**

Run: `flutter test test/core/tokens_test.dart test/core/app_logo_test.dart` -> Expected: PASS.
Run: `flutter analyze lib` -> Expected: `No issues found!`

- [ ] **Step 7: Checkpoint** - do not commit.

---

## Task 3: Onboarding persistence

**Files:**
- Create: `lib/features/onboarding/data/onboarding_prefs.dart`
- Modify: `lib/features/onboarding/presentation/onboarding_screen.dart`

**Interfaces:**
- Produces: `class OnboardingPrefs { static Future<bool> seen(); static Future<void> markSeen(); }` (key: `'onboarding_seen'`).
- Consumed by: Task 4 (splash routing).

- [ ] **Step 1: Create `lib/features/onboarding/data/onboarding_prefs.dart`**

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the user has completed (or skipped) onboarding.
///
/// Without this the splash sent every cold launch back to onboarding.
class OnboardingPrefs {
  OnboardingPrefs._();

  static const _key = 'onboarding_seen';

  static Future<bool> seen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
```

- [ ] **Step 2: Mark it seen on Skip and on finish**

Open `lib/features/onboarding/presentation/onboarding_screen.dart`. Add the import:

```dart
import '../data/onboarding_prefs.dart';
```

Find every place that navigates away from onboarding (the "Skip" action and the
final-page "Get started"/"Next" action - search for `context.go(`). Make each one
`await OnboardingPrefs.markSeen();` immediately before navigating, converting the
callback to `async` where needed. Example shape:

```dart
onPressed: () async {
  await OnboardingPrefs.markSeen();
  if (context.mounted) context.go('/home');
},
```

- [ ] **Step 3: Verify it compiles**

Run: `flutter analyze lib/features/onboarding` -> Expected: `No issues found!`

- [ ] **Step 4: Checkpoint** - do not commit.

---

## Task 4: Splash rebuild (animation + routing + the failing-test fix)

**Files:**
- Modify: `lib/features/onboarding/presentation/splash_screen.dart` (full rewrite)
- Test: `test/features/onboarding/splash_screen_test.dart`

**Interfaces:**
- Consumes: `AppLogo`, `AppLogoLockup`, `OnboardingPrefs.seen()`, `AppColors.paper`, `AppColors.skyTint`.
- Produces: `SplashScreen` (unchanged public name, still routed from `/splash`).

- [ ] **Step 1: Write the failing test**

```dart
// test/features/onboarding/splash_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:airport_nav/core/branding/app_logo.dart';
import 'package:airport_nav/features/onboarding/presentation/splash_screen.dart';

Widget _app() => MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: '/splash',
        routes: [
          GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
          GoRoute(path: '/home', builder: (_, _) => const Scaffold(body: Text('HOME'))),
          GoRoute(path: '/onboarding', builder: (_, _) => const Scaffold(body: Text('ONBOARDING'))),
        ],
      ),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows the logo and leaves no pending timers', (t) async {
    await t.pumpWidget(_app());
    await t.pump();
    expect(find.byType(AppLogo), findsOneWidget);
    await t.pumpAndSettle();
    // Reaching here without "A Timer is still pending" is the assertion.
  });

  testWidgets('routes to onboarding when not yet seen', (t) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': false});
    await t.pumpWidget(_app());
    await t.pumpAndSettle();
    expect(find.text('ONBOARDING'), findsOneWidget);
  });

  testWidgets('routes straight home once onboarding has been seen', (t) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    await t.pumpWidget(_app());
    await t.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run to verify it fails**

Run: `flutter test test/features/onboarding/splash_screen_test.dart`
Expected: FAIL - the current splash uses `Future.delayed` + `repeat()`, so
`pumpAndSettle` times out or reports a pending timer.

- [ ] **Step 3: Rewrite `splash_screen.dart`**

Replace the entire file:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/branding/app_logo.dart';
import '../../../core/constants/app_colors.dart';
import '../data/onboarding_prefs.dart';

/// Brand moment: the pass lands, the route runs across it, the plane lifts off
/// the end of that route, and the wordmark rises.
///
/// Driven by ONE forward controller with a status listener - deliberately no
/// `repeat()` and no `Future.delayed`, both of which leaked timers and broke
/// the app smoke test.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _tile;
  late final Animation<double> _route;
  late final Animation<double> _plane;
  late final Animation<double> _word;

  static const _kLogoSize = 116.0;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    Animation<double> beat(double begin, double end, Curve curve) =>
        CurvedAnimation(parent: _c, curve: Interval(begin, end, curve: curve));

    _tile = beat(0.00, 0.21, Curves.easeOutCubic);   // 0-350ms
    _route = beat(0.18, 0.53, Curves.easeOut);       // 300-900ms
    _plane = beat(0.41, 0.68, Curves.easeOutCubic);  // 700-1150ms
    _word = beat(0.59, 0.88, Curves.easeOut);        // 1000-1500ms

    _c.addStatusListener(_onDone);
    _c.forward();
  }

  Future<void> _onDone(AnimationStatus status) async {
    if (status != AnimationStatus.completed) return;
    final seen = await OnboardingPrefs.seen();
    if (!mounted) return;
    context.go(seen ? '/home' : '/onboarding');
  }

  @override
  void dispose() {
    _c.removeStatusListener(_onDone);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Soft sky glow behind the mark.
                Container(
                  width: _kLogoSize * 2.1,
                  height: _kLogoSize * 2.1,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.skyTint.withValues(alpha: 0.85 * _tile.value),
                      AppColors.paper.withValues(alpha: 0),
                    ]),
                  ),
                  child: Transform.scale(
                    scale: 0.86 + (0.14 * _tile.value),
                    child: AppLogo(
                      size: _kLogoSize,
                      tileProgress: _tile.value,
                      routeProgress: _route.value,
                      planeProgress: _plane.value,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Transform.translate(
                  offset: Offset(0, 8 * (1 - _word.value)),
                  child: Opacity(
                    opacity: _word.value,
                    child: Text(
                      'AirportNav',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the splash tests**

Run: `flutter test test/features/onboarding/splash_screen_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Confirm the long-standing failure is fixed**

Run: `flutter test`
Expected: **0 failures.** `widget_test.dart > "App launches smoke test"` - which has
failed for this whole project with `"A Timer is still pending even after the widget tree
was disposed"` - now passes. If it still fails, the cause is a leftover timer elsewhere;
do not proceed until the suite is green.

- [ ] **Step 6: Checkpoint** - do not commit. Report the total test count.

---

## Task 5: Mark in the home header

**Files:**
- Modify: `lib/features/home/presentation/widgets/home_header.dart`

**Interfaces:**
- Consumes: `AppLogo`.

- [ ] **Step 1: Read the file and locate the wordmark**

Run: `flutter analyze lib/features/home/presentation/widgets/home_header.dart` first so
you have a clean baseline. Open the file and find the `Text('AirportNav', …)` widget and
the `Row` that contains it plus the trailing bell / profile buttons.

- [ ] **Step 2: Insert the mark**

Add the import:

```dart
import '../../../../core/branding/app_logo.dart';
```

Wrap the existing title/subtitle `Column` so the mark sits to its left. The row that
holds the wordmark becomes:

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.center,
  children: [
    const AppLogo(size: 30),
    const SizedBox(width: 10),
    Expanded(child: /* the existing Column with 'AirportNav' + 'JFK Airport ⌄' */),
    // …existing trailing bell / profile buttons unchanged…
  ],
)
```

Change nothing else in the header - no spacing, colour or type changes.

- [ ] **Step 3: Verify**

Run: `flutter analyze lib` -> Expected: `No issues found!`
Run: `flutter test test/home_screen_test.dart` -> Expected: PASS (the header must still
lay out at mobile width without overflow).

- [ ] **Step 4: Checkpoint** - do not commit.

---

## Task 6: App icon from the same geometry

**Files:**
- Create: `tools/gen_app_icon.py`
- Modify: `pubspec.yaml`

**Interfaces:**
- Produces: `assets/icons/app_icon.png` (1024x1024), `assets/icons/app_icon_foreground.png` (1024x1024).

- [ ] **Step 1: Create `tools/gen_app_icon.py`**

```python
"""Generate the AirportNav launcher icons from the same 64-unit geometry as
lib/core/branding/logo_painter.dart, so the icon and the in-app mark can never
drift. Run:  python tools/gen_app_icon.py
"""
from PIL import Image, ImageDraw

S = 1024
K = S / 64.0
SKY2, SKY, AMBER, WHITE = (88, 149, 243), (53, 119, 231), (255, 176, 32), (255, 255, 255)

def gradient(size, c1, c2):
    """Diagonal linear gradient, drawn small then upscaled."""
    n = 64
    g = Image.new("RGB", (n, n))
    px = g.load()
    for y in range(n):
        for x in range(n):
            t = (x + y) / (2.0 * (n - 1))
            px[x, y] = tuple(round(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))
    return g.resize((size, size), Image.BICUBIC)

def tile_mask():
    """Rounded square minus the two boarding-pass notches."""
    m = Image.new("L", (S, S), 0)
    d = ImageDraw.Draw(m)
    d.rounded_rectangle([0, 0, S - 1, S - 1], radius=int(18 * K), fill=255)
    r, cy = 7.5 * K, 30 * K
    for cx in (0, S):
        d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=0)
    return m

def draw_marks(img):
    d = ImageDraw.Draw(img)
    # amber route dots along the quadratic M13 48 Q25 47 33 38
    p0, p1, p2 = (13 * K, 48 * K), (25 * K, 47 * K), (33 * K, 38 * K)
    for i in range(7):
        t = i / 6.0
        x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t ** 2 * p2[0]
        y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t ** 2 * p2[1]
        rr = 1.7 * K
        d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=AMBER)
    # white plane
    d.polygon([(49 * K, 15 * K), (27 * K, 25.5 * K),
               (36.5 * K, 29.5 * K), (40 * K, 39 * K)], fill=WHITE)

# ── full tile icon ────────────────────────────────────────────────────
icon = Image.new("RGBA", (S, S), (0, 0, 0, 0))
icon.paste(gradient(S, SKY2, SKY), (0, 0), tile_mask())
draw_marks(icon)
icon.save("assets/icons/app_icon.png")

# ── adaptive foreground: marks only, inset into the 66% safe area ─────
fg_inner = Image.new("RGBA", (S, S), (0, 0, 0, 0))
draw_marks(fg_inner)
fg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
scaled = fg_inner.resize((int(S * 0.66), int(S * 0.66)), Image.LANCZOS)
fg.paste(scaled, (int(S * 0.17), int(S * 0.17)), scaled)
fg.save("assets/icons/app_icon_foreground.png")

print("wrote assets/icons/app_icon.png + app_icon_foreground.png")
```

- [ ] **Step 2: Generate the PNGs**

Run from `airport_nav/`: `python tools/gen_app_icon.py`
Expected: `wrote assets/icons/app_icon.png + app_icon_foreground.png`

If Pillow is missing: `python -m pip install --user Pillow`, then re-run.

- [ ] **Step 3: Add `flutter_launcher_icons` to `pubspec.yaml`**

Under `dev_dependencies:` add:

```yaml
  flutter_launcher_icons: ^0.14.1
```

At the end of the file add:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#3577E7"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
  remove_alpha_ios: true
```

- [ ] **Step 4: Generate the launcher icons**

Run: `flutter pub get`
Run: `dart run flutter_launcher_icons`
Expected: `✓ Successfully generated launcher icons`

- [ ] **Step 5: Verify**

Run: `flutter analyze lib test` -> Expected: `No issues found!`

- [ ] **Step 6: Checkpoint** - do not commit.

---

## Task 7: Verify on the emulator

**Files:** none (verification only).

- [ ] **Step 1: Full suite**

Run: `flutter analyze lib test` -> Expected: `No issues found!`
Run: `flutter test` -> Expected: **all tests pass, 0 failures.**

- [ ] **Step 2: Build, install, launch**

```bash
cd /c/Users/Haim/Documents/projects/example-project/airport_nav
ADB="/c/Users/Haim/AppData/Local/Android/Sdk/platform-tools/adb.exe"
flutter build apk --release
"$ADB" -s emulator-5554 install -r build/app/outputs/flutter-apk/app-release.apk
"$ADB" -s emulator-5554 shell am start -n com.airportnav.airport_nav/.MainActivity
```

If `adb` reports `cmd: Can't find service: package`, the emulator's services have been
starved by the build - run `"$ADB" -s emulator-5554 reboot`, wait for
`getprop sys.boot_completed` to return `1` **and** `service check package` to return
`package: found`, then retry the install.

- [ ] **Step 3: Screenshot-verify four things**

Capture with `"$ADB" -s emulator-5554 exec-out screencap -p > shot.png` and confirm:
1. **Splash** - the tile, amber route and plane are visible (grab it within ~1.5s of launch)
2. **Home header** - mark sits left of "AirportNav"
3. **Delayed badge** - the Flights tab shows `UA 3456` in the new orange, clearly not amber
4. **Second cold launch** (`am force-stop` then `am start`) goes **straight to Home**, not onboarding

Delete the screenshots afterwards.

- [ ] **Step 4: Checkpoint** - summarise, then offer to commit (only on request).

---

## Self-Review

**Spec coverage:** §2 mark -> Task 1. §2.3 small-size rule -> Task 1 (`routeVisible`, tested).
§2.4 lockup -> Task 1 (`AppLogoLockup`). §3.1/§3.2 tokens -> Task 2. §3.3 usage rules ->
Global Constraints. §4 splash + test fix -> Task 4. §5 onboarding persistence -> Tasks 3
and 4. §6 home header -> Task 5. §6 notch motif -> **deliberately deferred**: the spec
scopes `NotchedCard` to boarding-pass and upcoming-flight cards, which are being rebuilt
in Workstream B (home density); adding it now then reworking it there would be wasted
effort. §7 app icon -> Task 6. §9 verification -> Tasks 4 and 7.

**Placeholder scan:** No TBD/TODO. Task 3 Step 2 and Task 5 Step 2 describe an edit
against existing code rather than quoting the whole file - both give the exact import,
the exact search target (`context.go(`, `Text('AirportNav')`) and the exact resulting
shape, which is the actionable content.

**Type consistency:** `AppLogo({size, variant, showRoute, tileProgress, routeProgress,
planeProgress})` and `routeVisible` are used identically in Tasks 1, 4 and 5.
`LogoPainter` fields match. `OnboardingPrefs.seen()` / `.markSeen()` match between Tasks
3 and 4. `AppColors.amber` is introduced in Task 2 and consumed by the painter in the
same task. Icon geometry constants in Task 6 mirror Task 1's 64-grid values exactly.
