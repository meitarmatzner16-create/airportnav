import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/journey_step.dart';
import '../providers/journey_providers.dart';

const _gutter = AppSpacing.gutter;

/// The whole journey, top to bottom. For the traveller who wants the full
/// picture rather than only the next move.
class JourneyStepsScreen extends ConsumerWidget {
  const JourneyStepsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final journey = ref.watch(journeyProvider);
    final muted = isDark ? AppColors.dMuted : AppColors.muted;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Your journey', style: theme.textTheme.titleMedium),
      ),
      body: journey == null
          ? Center(
              child: Text('No journey yet',
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
            )
          : ListView(
              padding:
                  const EdgeInsets.fromLTRB(_gutter, 0, _gutter, AppSpacing.xxl),
              children: [
                for (var i = 0; i < journey.steps.length; i++)
                  _TimelineRow(
                    step: journey.steps[i],
                    status: journey.statusOf(i),
                    isLast: i == journey.steps.length - 1,
                  ),
              ],
            ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final JourneyStep step;
  final StepStatus status;
  final bool isLast;

  const _TimelineRow({
    required this.step,
    required this.status,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final sky = isDark ? AppColors.dSky : AppColors.sky;
    final track = isDark ? AppColors.dHairline : AppColors.hairlineCool;
    final isDone = status == StepStatus.done;
    final isCurrent = status == StepStatus.current;
    final clock = DateFormat('H:mm');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 16,
            child: Column(
              children: [
                const SizedBox(height: 5),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? AppColors.amber
                        : isCurrent
                            ? sky
                            : track,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: isDone ? AppColors.amber : track,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.smMd),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          step.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDone ? muted : textColor,
                            fontWeight:
                                isDone ? FontWeight.w600 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: sky,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            'NOW',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      if (step.deadline != null)
                        Text(
                          clock.format(step.deadline!),
                          style: AppTypography.mono(fontSize: 11, color: muted),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.where,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                  if (step.totalMinutes > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (step.queueMinutes > 0)
                          '${step.queueMinutes} min queue',
                        if (step.walkMinutes > 0) '${step.walkMinutes} min walk',
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
