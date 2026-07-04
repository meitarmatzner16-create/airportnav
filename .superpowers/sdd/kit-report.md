# Sky Pass Component Kit — Build Report

## Components Built

### New Widgets (`lib/core/widgets/`)

| File | Widget(s) | Signature |
|------|-----------|-----------|
| `app_card.dart` | `AppCard` | `AppCard({Key? key, required Widget child, EdgeInsetsGeometry? padding, VoidCallback? onTap, bool selected = false})` |
| `status_badge.dart` | `StatusBadge` | `StatusBadge({Key? key, required String status, int? delayMinutes, bool onDark = false})` |
| `state_views.dart` | `EmptyState` | `EmptyState({Key? key, required IconData icon, required String title, String? message, Widget? action})` |
| `state_views.dart` | `ErrorState` | `ErrorState({Key? key, required String message, VoidCallback? onRetry})` |
| `state_views.dart` | `LoadingState` | `LoadingState({Key? key, int itemCount = 4})` |
| `gradient_hero.dart` | `GradientHero` | `GradientHero({Key? key, required Widget child, List<Color>? colors, double height = 200})` |
| `info_row.dart` | `InfoRow` | `InfoRow({Key? key, required IconData icon, required String label, required String value})` |
| `gold_divider.dart` | `GoldDivider` | `GoldDivider({Key? key})` |
| `app_buttons.dart` | `PrimaryButton` | `PrimaryButton({Key? key, required String label, IconData? icon, VoidCallback? onPressed, bool loading = false})` |
| `app_buttons.dart` | `SecondaryButton` | `SecondaryButton({Key? key, required String label, IconData? icon, VoidCallback? onPressed, bool loading = false})` |

### Restyled Widgets (public API unchanged)

| File | Change |
|------|--------|
| `rating_stars.dart` | Default color changed from `Colors.amber` → `AppColors.gold` |
| `category_filter_chips.dart` | Full restyle: pill chips with `radiusFull`, `card`+`hairline` unselected, `ink`+white selected. Replaced Material `FilterChip` with custom `AnimatedContainer`. |
| `search_bar_widget.dart` | Full restyle: `card`/`dSurface` fill, `radiusMd` border, focus `sky` 1.5px, muted icons. Changed from `StatelessWidget` to `StatefulWidget` for focus tracking. |

## Smoke Test Coverage

File: `test/core/widgets/kit_smoke_test.dart`

- **37 tests, 37 passed, 0 failed**
- All components pumped in both `AppTheme.light` and `AppTheme.dark`
- All 6 `StatusBadge` status values covered (`on_time`, `boarding`, `delayed`, `cancelled`, `scheduled`, `landed`)
- `AppCard` tap interaction verified with `pumpAndSettle`
- Loading states verified (spinner present, label absent)
- `RatingStars` icon count verified (3 full + 1 half + 1 border for rating=3.5)

## Analyze / Test / Build Results

| Check | Result |
|-------|--------|
| `flutter analyze lib/core/widgets/ test/core/widgets/` | 0 issues |
| `flutter test test/core` | 37/37 passed |
| `flutter build web --no-tree-shake-icons` | `Built build/web` — success |

**Note on analyze:** Running `flutter analyze lib test` (all project files) shows 24 pre-existing info/warning issues in other feature files (`deprecated_member_use` for `.value` on Color, `unused_local_variable`, `unnecessary_underscores`). None are in the new/modified kit files.

## Design Decisions

- `AppCard` uses a stateful `GestureDetector` + `AnimatedScale` for press feedback (0.98 scale, 100ms). No `InkWell`/`Material` wrapper on the outer container since `clipBehavior: hardEdge` would clip the ink ripple; the scale animation is cleaner.
- `StatusBadge` mirrors the `_StatusPill` widget pattern from `home_screen.dart` but generalizes it with `onDark` support and the full 6-status mapping.
- `SearchBarWidget` became `StatefulWidget` to track focus state for the border color/width transition without requiring an external `FocusNode`.
- `CategoryFilterChips` replaced Material `FilterChip` with a custom `AnimatedContainer` for full control over the pill style.
- `GoldDivider` uses a `Stack` with a 1px base hairline and a 80px centered gradient overlay so the gold reads as a thin accent rather than a full-width gold line.
- `LoadingState` shimmer uses `skyTint`/`card` (light) and `dSurfaceVariant`/`dSurface` (dark) as shimmer base/highlight to stay within the token system.

## Concerns

None blocking. Two minor notes:

1. The pre-existing `deprecated_member_use` warnings (`.value` on Color) in `lounge_detail_screen.dart`, `shop_card.dart`, etc. should be addressed separately — they'll become errors in a future Dart SDK.
2. `SearchBarWidget`'s focus border now only updates when `Focus.onFocusChange` fires. If a parent explicitly manages focus via `FocusNode` and rebuilds the widget without focus events, the border may lag. For the current usage pattern (no external `FocusNode` control) this is fine.
