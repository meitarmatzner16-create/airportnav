import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/section_header.dart';

/// A single Quick Start action.
class QuickStartItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const QuickStartItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
}

/// "Quick Start" — a title plus a row of four equal action cards.
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
    final subColor = isDark ? AppColors.dMuted : AppColors.muted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: border, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: AppSpacing.smMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, size: 24, color: iconColor),
                const SizedBox(height: 14),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: subColor,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
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
