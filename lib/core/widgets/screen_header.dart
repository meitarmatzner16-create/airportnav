import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TonalPill — sky-tint background, sky text, radiusFull, ≥44px touch target.
// Used for header action buttons ("Flights", "← Home", airport chips, etc.)
// ─────────────────────────────────────────────────────────────────────────────

/// A gentle tonal action pill: sky-tint bg (skyAlpha10/skyAlpha15 in dark),
/// sky text, full-radius, ≥44px. Matches Home's "Flights" and "← Home" chips.
class TonalPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const TonalPill({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? AppColors.skyAlpha15 : AppColors.skyTint;
    final fg = isDark ? AppColors.dSky : AppColors.sky;

    final pill = Container(
      constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smMd,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return pill;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: pill,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ScreenHeader — the canonical title block from the Home dashboard.
// Every screen that needs a header should use this widget.
// ─────────────────────────────────────────────────────────────────────────────

/// Canonical screen header block matching the Home dashboard style.
///
/// Layout (top → bottom inside 24px gutters, 8px top pad):
///   [optional] greeting / eyebrow   — bodyMedium 14, muted
///   title                            — displaySmall 28, w700 −0.6 tracking, ink/dText
///   [optional] subtitle / meta       — bodyMedium 14, muted
///
/// [actions] are right-aligned in a Row alongside the title — pass
/// [TonalPill] widgets for the header action chips.
///
/// The widget does NOT add its own Padding; callers place it directly at the
/// top of a ListView/Column, respecting the 24px gutter via [horizontalPadding].
class ScreenHeader extends StatelessWidget {
  final String? greeting;
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  /// Horizontal padding applied to the outer container. Default: 24 (gutter).
  final double horizontalPadding;

  /// Top padding inside the header block. Default: 8.
  final double topPadding;

  /// Bottom padding below the header block. Default: 24.
  final double bottomPadding;

  const ScreenHeader({
    super.key,
    this.greeting,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.horizontalPadding = AppSpacing.gutter,
    this.topPadding = 8,
    this.bottomPadding = AppSpacing.lg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.dText : AppColors.ink;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting / eyebrow + right-aligned actions row ──────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Greeting (if provided) takes leftmost space
              if (greeting != null)
                Expanded(
                  child: Text(
                    greeting!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                )
              else
                const Spacer(),
              // Right-aligned action pills
              if (actions.isNotEmpty) ...[
                ...actions.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: a,
                  ),
                ),
              ],
            ],
          ),

          // ── Title ─────────────────────────────────────────────────
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: titleColor,
            ),
          ),

          // ── Subtitle / meta ────────────────────────────────────────
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
