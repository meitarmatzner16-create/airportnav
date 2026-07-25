import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../theme/app_theme.dart';

/// Generic surface card for the Sky Pass kit.
///
/// - Brightness-aware: white/dSurface bg, hairline/dHairline border.
/// - `onTap` → wraps in GestureDetector + AnimatedScale press (0.98).
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
    // Light: shadow-only float (no border) for a clean, un-gridded look.
    // Dark: faint border for separation (shadows read poorly on dark).
    final content = Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: widget.selected
            ? Border.all(color: AppColors.sky, width: 1.5)
            : (isDark
                ? Border.all(color: AppColors.dHairline, width: 1)
                : null),
        boxShadow: isDark ? null : AppShadows.card,
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
