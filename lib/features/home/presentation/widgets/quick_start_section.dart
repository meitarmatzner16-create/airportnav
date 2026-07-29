import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/section_header.dart';

/// A single Quick Start action - an icon and a short label.
class QuickStartItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickStartItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// "Quick Start" - a title plus a row of four equal action cards.
class QuickStartSection extends StatelessWidget {
  final List<QuickStartItem> items;

  const QuickStartSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Quick Start'),
        const SizedBox(height: AppSpacing.smMd),
        // IntrinsicHeight bounds the row height to the tallest card so
        // CrossAxisAlignment.stretch is valid inside the scrolling list.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(child: _QuickStartCard(item: items[i])),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickStartCard extends StatelessWidget {
  final QuickStartItem item;

  const _QuickStartCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = isDark ? AppColors.dSurface : AppColors.card;
    final border = isDark ? AppColors.dHairline : AppColors.hairline;
    final iconColor = isDark ? AppColors.dText : AppColors.ink;
    final titleColor = isDark ? AppColors.dText : AppColors.ink;

    // The shadow lives on an outer Container, not on an `Ink` decoration.
    // `Ink` paints into the parent Material's canvas, where the shadow does
    // not follow the rounded clip and the corners read as square.
    return Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: isDark ? Border.all(color: border, width: 1) : null,
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: item.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 24, color: iconColor),
                const SizedBox(height: 14),
                Text(
                  item.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.25,
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
