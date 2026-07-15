import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Canonical section header row.
///
/// - Title: `titleLarge` (~16px), w600, ink/dText.
/// - Optional right action: sky, ~13px, w600, ≥44px touch target.
/// - No horizontal padding — callers wrap in their own Padding (gutter).
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.dText : AppColors.ink;
    final actionColor = isDark ? AppColors.dSky : AppColors.sky;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
        ),
        if (actionText != null) const SizedBox(width: 12),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  actionText!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: actionColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
