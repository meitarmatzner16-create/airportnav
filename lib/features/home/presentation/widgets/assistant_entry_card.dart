import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/section_header.dart';

/// "What would you like to do?" → a wide entry into the assistant.
class AssistantEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const AssistantEntryCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.dSurface : AppColors.card;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final mutedColor = isDark ? AppColors.dMuted : AppColors.muted;
    final tileBg = isDark ? AppColors.skyAlpha15 : AppColors.skyTint;
    final chevronBg = isDark ? AppColors.dBg : AppColors.paper;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'What would you like to do?'),
        const SizedBox(height: AppSpacing.smMd),
        // Shadow on the outer Container so it follows the rounded corners.
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: isDark ? Border.all(color: hairline, width: 1) : null,
            boxShadow: isDark ? null : AppShadows.card,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: tileBg,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(Icons.auto_awesome_rounded,
                          size: 22, color: AppColors.sky),
                    ),
                    const SizedBox(width: AppSpacing.smMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ask Assistant',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Build a route, find services, get help - just ask.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: mutedColor,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.smMd),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: chevronBg,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(color: hairline, width: 1),
                      ),
                      child: Icon(Icons.chevron_right_rounded,
                          size: 20, color: mutedColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
