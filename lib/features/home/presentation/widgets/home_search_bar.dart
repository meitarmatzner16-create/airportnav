import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Presentational search entry on Home: looks like an input but taps through
/// to the flight-search screen. A trailing scan button is a placeholder for
/// boarding-pass scanning.
class HomeSearchBar extends StatelessWidget {
  final String hint;
  final VoidCallback onTap;
  final VoidCallback onScan;

  const HomeSearchBar({
    super.key,
    required this.hint,
    required this.onTap,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = isDark ? AppColors.dSurface : AppColors.card;
    final border = isDark ? AppColors.dHairline : AppColors.hairline;
    final iconColor = isDark ? AppColors.dMuted : AppColors.muted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: border, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 22, color: iconColor),
                const SizedBox(width: AppSpacing.smMd),
                Expanded(
                  child: Text(
                    hint,
                    style: theme.textTheme.bodyMedium?.copyWith(color: iconColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Semantics(
                  label: 'Scan boarding pass',
                  button: true,
                  child: GestureDetector(
                    onTap: onScan,
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 22,
                      color: iconColor,
                    ),
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
