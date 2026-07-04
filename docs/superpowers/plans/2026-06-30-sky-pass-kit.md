# Sky Pass Component Kit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a shared Sky Pass widget kit for AirportNav — 7 new components, 3 restyled existing widgets, and a smoke-test suite — so every screen can import from `lib/core/widgets/` without duplicating token-driven UI code.

**Architecture:** All widgets are stateless (or minimally stateful for press animation) and read design tokens exclusively from `AppColors`, `AppSpacing`, `AppTypography`, and `AppShadows`. Brightness-awareness is achieved with `Theme.of(context).brightness == Brightness.dark` (same pattern as `boarding_pass_card.dart`). No widget reads a hardcoded hex value or pixel size.

**Tech Stack:** Flutter/Dart 3.11, Material 3, `shimmer ^3.0.0`, `google_fonts ^6.2.1` (via `AppTypography`), `flutter_test` for widget tests.

## Global Constraints

- Never hard-code hex colors or pixel sizes — always use `AppColors.*`, `AppSpacing.*`, `AppTypography.*`, `AppShadows.*`.
- Brightness-awareness via `Theme.of(context).brightness == Brightness.dark`.
- Public APIs (constructor signatures) of existing widgets must not change.
- `flutter analyze lib test` must produce 0 errors.
- `flutter test test/core` must be green.
- `flutter build web --no-tree-shake-icons` must succeed.
- Commit trailer: `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`
- Repo root for all flutter/git commands: `C:/Users/Haim/Documents/projects/example-project/airport_nav`

---

### Task 1: `app_card.dart` — Tappable surface card

**Files:**
- Create: `lib/core/widgets/app_card.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`, `AppShadows`
- Produces: `AppCard({Key? key, required Widget child, EdgeInsetsGeometry? padding, VoidCallback? onTap, bool selected = false})`

- [ ] **Step 1: Create `lib/core/widgets/app_card.dart`**

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../theme/app_theme.dart';

/// Generic surface card for the Sky Pass kit.
///
/// - Brightness-aware: white/dSurface bg, hairline/dHairline border.
/// - `onTap` → wraps in Material+InkWell + AnimatedScale press (0.98).
/// - `selected` → sky border at 1.5px width.
/// - Default padding: `EdgeInsets.all(AppSpacing.md)`.
class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool selected;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.selected = false,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.dSurface : AppColors.card;
    final borderColor = widget.selected
        ? AppColors.sky
        : (isDark ? AppColors.dHairline : AppColors.hairline);
    final borderWidth = widget.selected ? 1.5 : 1.0;

    final content = Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.hardEdge,
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
      child: widget.child,
    );

    if (widget.onTap == null) return content;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: content,
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyze to confirm no issues**

Run from `C:/Users/Haim/Documents/projects/example-project/airport_nav`:
```
flutter analyze lib/core/widgets/app_card.dart
```
Expected: No issues found.

---

### Task 2: `status_badge.dart` — Flight status badge

**Files:**
- Create: `lib/core/widgets/status_badge.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`
- Produces: `StatusBadge({Key? key, required String status, int? delayMinutes, bool onDark = false})`

Status values handled: `on_time`, `boarding`, `delayed`, `cancelled`, `scheduled`, `landed`, fallback.

- [ ] **Step 1: Create `lib/core/widgets/status_badge.dart`**

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Dot + label badge for flight statuses.
///
/// Status values: on_time, boarding, delayed (+delay mins), cancelled,
/// scheduled, landed, and a generic fallback.
///
/// `onDark`: white text + whiteAlpha20 bg (for use on dark hero surfaces).
class StatusBadge extends StatelessWidget {
  final String status;
  final int? delayMinutes;
  final bool onDark;

  const StatusBadge({
    super.key,
    required this.status,
    this.delayMinutes,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, dotColor, textColor, bgColor) = _resolve();

    final resolvedTextColor = onDark ? Colors.white : textColor;
    final resolvedBg = onDark ? AppColors.whiteAlpha20 : bgColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onDark ? Colors.white : dotColor,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: resolvedTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, Color, Color) _resolve() {
    return switch (status) {
      'on_time' => ('On time', AppColors.success, AppColors.success, AppColors.successAlpha15),
      'boarding' => ('Boarding', AppColors.sky, AppColors.sky, AppColors.skyAlpha15),
      'delayed' => (
          delayMinutes != null ? 'Delayed +${delayMinutes}m' : 'Delayed',
          AppColors.warning,
          AppColors.warning,
          AppColors.warningAlpha15,
        ),
      'cancelled' => ('Cancelled', AppColors.error, AppColors.error, AppColors.errorAlpha15),
      'scheduled' => ('Scheduled', AppColors.muted, AppColors.muted, AppColors.inkAlpha10),
      'landed' => ('Landed', AppColors.ink, AppColors.ink, AppColors.inkAlpha10),
      _ => (
          '${status[0].toUpperCase()}${status.substring(1)}',
          AppColors.muted,
          AppColors.muted,
          AppColors.inkAlpha10,
        ),
    };
  }
}
```

- [ ] **Step 2: Run analyze**

```
flutter analyze lib/core/widgets/status_badge.dart
```
Expected: No issues found.

---

### Task 3: `state_views.dart` — EmptyState, ErrorState, LoadingState

**Files:**
- Create: `lib/core/widgets/state_views.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`, `shimmer` package, `app_buttons.dart` (Task 7's `PrimaryButton`)
- Produces:
  - `EmptyState({Key? key, required IconData icon, required String title, String? message, Widget? action})`
  - `ErrorState({Key? key, required String message, VoidCallback? onRetry})`
  - `LoadingState({Key? key, int itemCount = 4})`

Note: `state_views.dart` imports `PrimaryButton` from `app_buttons.dart`. Implement Task 7 (`app_buttons.dart`) before this file, or use a forward-reference pattern. The plan orders Task 7 before Task 3 in the file-writing sequence — see the commit order.

- [ ] **Step 1: Create `lib/core/widgets/state_views.dart`** (write after Task 7)

```dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import 'app_buttons.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EmptyState
// ─────────────────────────────────────────────────────────────────────────────

/// Empty state: icon in a skyTint circle, title, optional message + action.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final circleBg = isDark ? AppColors.dSurfaceVariant : AppColors.skyTint;
    final iconColor = isDark ? AppColors.dSky : AppColors.sky;
    final titleColor = isDark ? AppColors.dText : AppColors.ink;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleBg,
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.muted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ErrorState
// ─────────────────────────────────────────────────────────────────────────────

/// Error state with optional "Try again" button.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.dText : AppColors.ink;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.errorAlpha15,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                color: titleColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(label: 'Try again', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LoadingState
// ─────────────────────────────────────────────────────────────────────────────

/// Shimmer placeholder rows. Uses skyTint as the shimmer highlight.
class LoadingState extends StatelessWidget {
  final int itemCount;

  const LoadingState({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.dSurfaceVariant : AppColors.skyTint;
    final highlightColor = isDark ? AppColors.dSurface : AppColors.card;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          children: List.generate(
            itemCount,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.smMd),
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyze**

```
flutter analyze lib/core/widgets/state_views.dart
```
Expected: No issues found.

---

### Task 4: `gradient_hero.dart` — Sky→sky2 gradient banner with gold hairline

**Files:**
- Create: `lib/core/widgets/gradient_hero.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`
- Produces: `GradientHero({Key? key, required Widget child, List<Color>? colors, double height = 200})`

- [ ] **Step 1: Create `lib/core/widgets/gradient_hero.dart`**

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Sky→sky2 gradient container with a 3px gold hairline across the top.
///
/// `colors` defaults to [AppColors.sky, AppColors.sky2].
/// NO perforation — that belongs to BoardingPassCard exclusively.
class GradientHero extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final double height;

  const GradientHero({
    super.key,
    required this.child,
    this.colors,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ?? [AppColors.sky, AppColors.sky2];

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Gradient body
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: child,
            ),
          ),
          // 3px gold top hairline (gradient: gold → goldSoft → gold)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.gold, AppColors.goldSoft, AppColors.gold],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyze**

```
flutter analyze lib/core/widgets/gradient_hero.dart
```
Expected: No issues found.

---

### Task 5: `info_row.dart` — Icon + label/value pair

**Files:**
- Create: `lib/core/widgets/info_row.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`
- Produces: `InfoRow({Key? key, required IconData icon, required String label, required String value})`

- [ ] **Step 1: Create `lib/core/widgets/info_row.dart`**

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Compact icon + stacked label/value pair.
///
/// Icon: muted color, 18px.
/// Label: labelSmall, muted.
/// Value: bodyMedium ink (dark: dText).
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final valueColor = isDark ? AppColors.dText : AppColors.ink;
    final iconColor = isDark ? AppColors.dMuted : AppColors.muted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: AppSpacing.smMd),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.muted,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Run analyze**

```
flutter analyze lib/core/widgets/info_row.dart
```
Expected: No issues found.

---

### Task 6: `gold_divider.dart` — Hairline with gold accent

**Files:**
- Create: `lib/core/widgets/gold_divider.dart`

**Interfaces:**
- Consumes: `AppColors`
- Produces: `GoldDivider()`

- [ ] **Step 1: Create `lib/core/widgets/gold_divider.dart`**

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A 1px hairline divider with a short centered gold accent gradient.
///
/// The base line uses `hairline` (light) / `dHairline` (dark).
/// The 80px center accent fades gold → goldSoft → gold.
class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.dHairline : AppColors.hairline;

    return SizedBox(
      height: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Full-width hairline
          Container(color: lineColor),
          // Centered 80px gold accent
          Container(
            width: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.goldAlpha15,
                  AppColors.gold,
                  AppColors.goldAlpha15,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyze**

```
flutter analyze lib/core/widgets/gold_divider.dart
```
Expected: No issues found.

---

### Task 7: `app_buttons.dart` — PrimaryButton + SecondaryButton

**Files:**
- Create: `lib/core/widgets/app_buttons.dart`

**Interfaces:**
- Consumes: `AppColors`, `AppSpacing`
- Produces:
  - `PrimaryButton({Key? key, required String label, IconData? icon, VoidCallback? onPressed, bool loading = false})`
  - `SecondaryButton({Key? key, required String label, IconData? icon, VoidCallback? onPressed, bool loading = false})`

- [ ] **Step 1: Create `lib/core/widgets/app_buttons.dart`**

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Sky-blue primary button. Height: `AppSpacing.buttonHeight` (52px).
/// Shows `CircularProgressIndicator` and disables tap when `loading`.
class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.dSky : AppColors.sky;
    final pressedColor = isDark ? AppColors.sky : AppColors.skyPressed;

    return SizedBox(
      height: AppSpacing.buttonHeight,
      child: Material(
        color: loading || onPressed == null ? bgColor.withAlpha(153) : bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: loading || onPressed == null ? null : onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          splashColor: pressedColor.withAlpha(51),
          highlightColor: pressedColor.withAlpha(26),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Outline/hairline secondary button. Same height as PrimaryButton.
class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;

  const SecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.dHairline : AppColors.hairline;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final bgColor = isDark ? AppColors.dSurface : AppColors.card;

    return SizedBox(
      height: AppSpacing.buttonHeight,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: loading || onPressed == null ? null : onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: loading || onPressed == null
                    ? borderColor.withAlpha(102)
                    : borderColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: textColor,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 18, color: textColor),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyze**

```
flutter analyze lib/core/widgets/app_buttons.dart
```
Expected: No issues found.

---

### Task 8: Restyle `rating_stars.dart` → gold stars

**Files:**
- Modify: `lib/core/widgets/rating_stars.dart`

**Interfaces:**
- Public API unchanged: `RatingStars({Key? key, required double rating, double size = 16, Color? color})`
- Change: default `color` is now `AppColors.gold` instead of `Colors.amber`.

- [ ] **Step 1: Edit `lib/core/widgets/rating_stars.dart`**

Replace the entire file:

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Star rating row.
///
/// Default color is `AppColors.gold` (Sky Pass palette).
/// Pass a custom `color` to override.
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? AppColors.gold;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, size: size, color: starColor);
        } else if (index < rating) {
          return Icon(Icons.star_half, size: size, color: starColor);
        } else {
          return Icon(Icons.star_border, size: size, color: starColor);
        }
      }),
    );
  }
}
```

- [ ] **Step 2: Run analyze**

```
flutter analyze lib/core/widgets/rating_stars.dart
```
Expected: No issues found.

---

### Task 9: Restyle `category_filter_chips.dart` → pill chips

**Files:**
- Modify: `lib/core/widgets/category_filter_chips.dart`

**Interfaces:**
- Public API unchanged: `CategoryFilterChips({Key? key, required List<String> categories, required String selected, required ValueChanged<String> onSelected})`
- Change: unselected = `card` bg + `hairline` border + `muted` text, `radiusFull`. Selected = `ink` bg + white text, `radiusFull`.

- [ ] **Step 1: Edit `lib/core/widgets/category_filter_chips.dart`**

Replace the entire file:

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Horizontal scrolling filter chips for categories.
///
/// Sky Pass pill style:
///   Unselected: card bg, hairline border (1px), muted text, radiusFull.
///   Selected:   ink bg, white text, radiusFull.
class CategoryFilterChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selected;

          final bgColor = isSelected
              ? (isDark ? AppColors.dText : AppColors.ink)
              : (isDark ? AppColors.dSurface : AppColors.card);
          final textColor = isSelected
              ? Colors.white
              : (isDark ? AppColors.dMuted : AppColors.muted);
          final borderColor = isDark ? AppColors.dHairline : AppColors.hairline;

          return GestureDetector(
            onTap: () => onSelected(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.smMd,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: isSelected
                    ? null
                    : Border.all(color: borderColor, width: 1),
              ),
              child: Text(
                category,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyze**

```
flutter analyze lib/core/widgets/category_filter_chips.dart
```
Expected: No issues found.

---

### Task 10: Restyle `search_bar_widget.dart` → Sky Pass search field

**Files:**
- Modify: `lib/core/widgets/search_bar_widget.dart`

**Interfaces:**
- Public API unchanged: `SearchBarWidget({Key? key, required String hint, required ValueChanged<String> onChanged, TextEditingController? controller})`
- Change: `card` fill, `hairline` border (1px), `radiusMd`, search icon muted, focus border `sky` 1.5px.

- [ ] **Step 1: Edit `lib/core/widgets/search_bar_widget.dart`**

Replace the entire file:

```dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Sky Pass styled search field.
///
/// Fill: card (light) / dSurface (dark).
/// Border: hairline 1px; focus → sky 1.5px.
/// Radius: radiusMd (14px).
/// Search icon: muted color.
class SearchBarWidget extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;
  bool _ownsController = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _ownsController = true;
    } else {
      _controller = widget.controller!;
    }
    _controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AppColors.dSurface : AppColors.card;
    final borderColor = isDark ? AppColors.dHairline : AppColors.hairline;
    final focusBorderColor = isDark ? AppColors.dSky : AppColors.sky;
    final iconColor = isDark ? AppColors.dMuted : AppColors.muted;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      borderSide: BorderSide(
        color: _hasFocus ? focusBorderColor : borderColor,
        width: _hasFocus ? 1.5 : 1.0,
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Focus(
        onFocusChange: (v) => setState(() => _hasFocus = v),
        child: TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: fill,
            prefixIcon: Icon(Icons.search, color: iconColor),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: iconColor),
                    onPressed: () {
                      _controller.clear();
                      widget.onChanged('');
                    },
                  )
                : null,
            border: border,
            enabledBorder: border,
            focusedBorder: border,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.smMd,
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Run analyze**

```
flutter analyze lib/core/widgets/search_bar_widget.dart
```
Expected: No issues found.

---

### Task 11: Smoke tests

**Files:**
- Create: `test/core/widgets/kit_smoke_test.dart`

**Interfaces:**
- Consumes: all new widgets (Tasks 1–7) and all restyled widgets (Tasks 8–10).
- Tests: each component pumps in `MaterialApp(theme: AppTheme.light)` and `AppTheme.dark`; asserts key text/icon renders; `tester.takeException()` is null.

- [ ] **Step 1: Create `test/core/widgets/kit_smoke_test.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/core/widgets/app_card.dart';
import 'package:airport_nav/core/widgets/status_badge.dart';
import 'package:airport_nav/core/widgets/state_views.dart';
import 'package:airport_nav/core/widgets/gradient_hero.dart';
import 'package:airport_nav/core/widgets/info_row.dart';
import 'package:airport_nav/core/widgets/gold_divider.dart';
import 'package:airport_nav/core/widgets/app_buttons.dart';
import 'package:airport_nav/core/widgets/rating_stars.dart';
import 'package:airport_nav/core/widgets/category_filter_chips.dart';
import 'package:airport_nav/core/widgets/search_bar_widget.dart';

Widget _wrap(Widget child, {bool dark = false}) => MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  // ── AppCard ────────────────────────────────────────────────────────────────
  group('AppCard', () {
    testWidgets('renders child in light mode', (t) async {
      await t.pumpWidget(_wrap(const AppCard(child: Text('Hello'))));
      expect(find.text('Hello'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('renders child in dark mode', (t) async {
      await t.pumpWidget(_wrap(const AppCard(child: Text('Dark')), dark: true));
      expect(find.text('Dark'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('selected border does not throw', (t) async {
      await t.pumpWidget(_wrap(const AppCard(selected: true, child: Text('Sel'))));
      expect(find.text('Sel'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('tappable variant does not throw', (t) async {
      await t.pumpWidget(_wrap(AppCard(onTap: () {}, child: const Text('Tap'))));
      await t.tap(find.text('Tap'));
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  });

  // ── StatusBadge ───────────────────────────────────────────────────────────
  group('StatusBadge', () {
    for (final s in ['on_time', 'boarding', 'delayed', 'cancelled', 'scheduled', 'landed']) {
      testWidgets('renders status=$s', (t) async {
        await t.pumpWidget(_wrap(StatusBadge(status: s, delayMinutes: 15)));
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('onDark variant renders', (t) async {
      await t.pumpWidget(_wrap(const StatusBadge(status: 'boarding', onDark: true)));
      expect(t.takeException(), isNull);
    });
  });

  // ── EmptyState ────────────────────────────────────────────────────────────
  group('EmptyState', () {
    testWidgets('renders title and message', (t) async {
      await t.pumpWidget(_wrap(const EmptyState(
        icon: Icons.inbox,
        title: 'Nothing here',
        message: 'Check back later',
      )));
      expect(find.text('Nothing here'), findsOneWidget);
      expect(find.text('Check back later'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('renders with action widget', (t) async {
      await t.pumpWidget(_wrap(EmptyState(
        icon: Icons.inbox,
        title: 'Empty',
        action: PrimaryButton(label: 'Refresh', onPressed: () {}),
      )));
      expect(find.text('Refresh'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── ErrorState ────────────────────────────────────────────────────────────
  group('ErrorState', () {
    testWidgets('renders message', (t) async {
      await t.pumpWidget(_wrap(const ErrorState(message: 'Network error')));
      expect(find.text('Network error'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('renders Try again button when onRetry provided', (t) async {
      await t.pumpWidget(_wrap(ErrorState(message: 'Oops', onRetry: () {})));
      expect(find.text('Try again'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── LoadingState ──────────────────────────────────────────────────────────
  group('LoadingState', () {
    testWidgets('renders shimmer rows', (t) async {
      await t.pumpWidget(_wrap(const LoadingState(itemCount: 3)));
      expect(t.takeException(), isNull);
    });

    testWidgets('renders in dark mode', (t) async {
      await t.pumpWidget(_wrap(const LoadingState(), dark: true));
      expect(t.takeException(), isNull);
    });
  });

  // ── GradientHero ──────────────────────────────────────────────────────────
  group('GradientHero', () {
    testWidgets('renders child', (t) async {
      await t.pumpWidget(_wrap(const GradientHero(child: Text('Hero'))));
      expect(find.text('Hero'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('custom colors and height do not throw', (t) async {
      await t.pumpWidget(_wrap(const GradientHero(
        height: 150,
        colors: [Colors.blue, Colors.purple],
        child: SizedBox(),
      )));
      expect(t.takeException(), isNull);
    });
  });

  // ── InfoRow ───────────────────────────────────────────────────────────────
  group('InfoRow', () {
    testWidgets('renders label and value', (t) async {
      await t.pumpWidget(_wrap(const InfoRow(
        icon: Icons.place,
        label: 'Gate',
        value: 'B22',
      )));
      expect(find.text('Gate'), findsOneWidget);
      expect(find.text('B22'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── GoldDivider ───────────────────────────────────────────────────────────
  group('GoldDivider', () {
    testWidgets('renders without error', (t) async {
      await t.pumpWidget(_wrap(const GoldDivider()));
      expect(t.takeException(), isNull);
    });

    testWidgets('renders in dark mode', (t) async {
      await t.pumpWidget(_wrap(const GoldDivider(), dark: true));
      expect(t.takeException(), isNull);
    });
  });

  // ── PrimaryButton ─────────────────────────────────────────────────────────
  group('PrimaryButton', () {
    testWidgets('renders label', (t) async {
      await t.pumpWidget(_wrap(PrimaryButton(label: 'Book', onPressed: () {})));
      expect(find.text('Book'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('loading state shows no label', (t) async {
      await t.pumpWidget(_wrap(const PrimaryButton(label: 'Book', loading: true)));
      expect(find.text('Book'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('icon variant renders', (t) async {
      await t.pumpWidget(_wrap(PrimaryButton(
        label: 'Search',
        icon: Icons.search,
        onPressed: () {},
      )));
      expect(find.text('Search'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── SecondaryButton ───────────────────────────────────────────────────────
  group('SecondaryButton', () {
    testWidgets('renders label', (t) async {
      await t.pumpWidget(_wrap(SecondaryButton(label: 'Cancel', onPressed: () {})));
      expect(find.text('Cancel'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('loading state', (t) async {
      await t.pumpWidget(_wrap(const SecondaryButton(label: 'Cancel', loading: true)));
      expect(find.text('Cancel'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── RatingStars ───────────────────────────────────────────────────────────
  group('RatingStars', () {
    testWidgets('renders 5 star icons', (t) async {
      await t.pumpWidget(_wrap(const RatingStars(rating: 3.5)));
      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_half), findsOneWidget);
      expect(find.byIcon(Icons.star_border), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── CategoryFilterChips ───────────────────────────────────────────────────
  group('CategoryFilterChips', () {
    testWidgets('renders categories and highlights selected', (t) async {
      await t.pumpWidget(_wrap(CategoryFilterChips(
        categories: const ['Food', 'Shopping', 'Lounge'],
        selected: 'Shopping',
        onSelected: (_) {},
      )));
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  // ── SearchBarWidget ───────────────────────────────────────────────────────
  group('SearchBarWidget', () {
    testWidgets('renders hint text', (t) async {
      await t.pumpWidget(_wrap(SearchBarWidget(
        hint: 'Search venues',
        onChanged: (_) {},
      )));
      expect(find.text('Search venues'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('dark mode renders without error', (t) async {
      await t.pumpWidget(_wrap(
        SearchBarWidget(hint: 'Find', onChanged: (_) {}),
        dark: true,
      ));
      expect(t.takeException(), isNull);
    });
  });
}
```

- [ ] **Step 2: Run tests**

```
flutter test test/core/widgets/kit_smoke_test.dart -v
```
Expected: All tests pass, 0 failures.

---

### Task 12: Full analyze + test + build + commit

**Files:**
- No new files. Verification and git commit only.

- [ ] **Step 1: Full analyze**

```
flutter analyze lib test
```
Expected: No issues found (0 errors, 0 warnings).

- [ ] **Step 2: Full test suite for core**

```
flutter test test/core
```
Expected: All tests pass.

- [ ] **Step 3: Web build**

```
flutter build web --no-tree-shake-icons
```
Expected: Build succeeds (exit code 0).

- [ ] **Step 4: Write kit report to `.superpowers/sdd/kit-report.md`**

See report template in the implementation brief. Include: components built + signatures, restyles, smoke-test coverage, analyze/test/build results, concerns.

- [ ] **Step 5: Git commit**

```bash
git -C "C:/Users/Haim/Documents/projects/example-project/airport_nav" add \
  lib/core/widgets/app_card.dart \
  lib/core/widgets/status_badge.dart \
  lib/core/widgets/state_views.dart \
  lib/core/widgets/gradient_hero.dart \
  lib/core/widgets/info_row.dart \
  lib/core/widgets/gold_divider.dart \
  lib/core/widgets/app_buttons.dart \
  lib/core/widgets/rating_stars.dart \
  lib/core/widgets/category_filter_chips.dart \
  lib/core/widgets/search_bar_widget.dart \
  test/core/widgets/kit_smoke_test.dart \
  .superpowers/sdd/kit-report.md

git -C "C:/Users/Haim/Documents/projects/example-project/airport_nav" commit -m "$(cat <<'EOF'
feat(kit): add Sky Pass shared component kit

7 new token-driven widgets (AppCard, StatusBadge, EmptyState, ErrorState,
LoadingState, GradientHero, InfoRow, GoldDivider, PrimaryButton,
SecondaryButton) plus restyled RatingStars, CategoryFilterChips, and
SearchBarWidget. Smoke tests cover all components in light + dark themes.
flutter analyze 0 errors; flutter test green; web build passes.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
EOF
)"
```

---

## Execution Order Note

Write files in this order to satisfy the import dependency:
1. Task 7 (`app_buttons.dart`) — imported by `state_views.dart`
2. Task 1 (`app_card.dart`)
3. Task 2 (`status_badge.dart`)
4. Task 3 (`state_views.dart`) — imports `app_buttons.dart`
5. Task 4 (`gradient_hero.dart`)
6. Task 5 (`info_row.dart`)
7. Task 6 (`gold_divider.dart`)
8. Task 8 (restyle `rating_stars.dart`)
9. Task 9 (restyle `category_filter_chips.dart`)
10. Task 10 (restyle `search_bar_widget.dart`)
11. Task 11 (smoke tests)
12. Task 12 (verify + commit)
