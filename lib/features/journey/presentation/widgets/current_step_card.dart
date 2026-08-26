import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/journey.dart';
import '../../domain/entities/journey_step.dart';

/// "Do this now" - the one thing the traveller should act on.
class CurrentStepCard extends StatelessWidget {
  final Journey journey;

  const CurrentStepCard({super.key, required this.journey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final step = journey.currentStep;
    final sky = isDark ? AppColors.dSky : AppColors.sky;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final clock = DateFormat('H:mm');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.dSurface : AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: sky, width: 2),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step ${journey.currentIndex + 1} of ${journey.steps.length} · do this now',
              style: theme.textTheme.labelSmall?.copyWith(
                color: sky,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              step.title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(color: textColor, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              step.where,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: textColor, fontWeight: FontWeight.w600),
            ),
            if (step.note != null) ...[
              const SizedBox(height: 2),
              Text(step.note!,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            ],
            const SizedBox(height: AppSpacing.smMd),
            Divider(
              height: 1,
              color: isDark ? AppColors.dHairline : AppColors.hairline,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                // Skipped rather than shown as zero when there is no queue.
                if (step.queueMinutes > 0)
                  _Stat(
                    label: 'Queue',
                    value: '${step.queueMinutes} min',
                    emphasise: step.queueMinutes >= 15,
                  ),
                if (step.walkMinutes > 0)
                  _Stat(label: 'Walk', value: '${step.walkMinutes} min'),
                if (step.deadline != null)
                  _Stat(
                    label: 'Be there by',
                    value: clock.format(step.deadline!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasise;

  const _Stat({
    required this.label,
    required this.value,
    this.emphasise = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: muted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: AppTypography.mono(
              fontSize: 15,
              weight: FontWeight.w700,
              color: emphasise ? AppColors.statusDelayed : textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// The step after the current one, kept deliberately quiet.
class ThenCard extends StatelessWidget {
  final JourneyStep step;
  final String gate;

  const ThenCard({super.key, required this.step, required this.gate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.dSurface : AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.dHairline : AppColors.hairline,
          width: 1,
        ),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.smMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THEN',
              style: theme.textTheme.labelSmall?.copyWith(
                color: muted,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    step.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: textColor, fontWeight: FontWeight.w700),
                  ),
                ),
                if (step.walkMinutes > 0)
                  Text(
                    '${step.walkMinutes} min walk',
                    style: AppTypography.mono(fontSize: 12, color: muted),
                  ),
              ],
            ),
            if (step.note != null) ...[
              const SizedBox(height: 2),
              Text(step.where,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            ],
          ],
        ),
      ),
    );
  }
}
