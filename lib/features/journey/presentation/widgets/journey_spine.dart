import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/journey.dart';
import '../../domain/entities/journey_step.dart';

/// Where you are in the airport, at a glance.
///
/// Amber marks the path already walked - the brand's wayfinding accent, used
/// as a shape only. Sky marks where you are now. Renders one dot per step,
/// so a spine with passport control is simply longer.
class JourneySpine extends StatelessWidget {
  final Journey journey;
  final VoidCallback? onTap;

  const JourneySpine({super.key, required this.journey, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final track = isDark ? AppColors.dHairline : AppColors.hairlineCool;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final sky = isDark ? AppColors.dSky : AppColors.sky;

    return Semantics(
      label: 'Step ${journey.currentIndex + 1} of ${journey.steps.length}',
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < journey.steps.length; i++)
                Expanded(
                  child: _SpineStep(
                    label: journey.steps[i].kind.short,
                    status: journey.statusOf(i),
                    isLast: i == journey.steps.length - 1,
                    track: track,
                    muted: muted,
                    sky: sky,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpineStep extends StatelessWidget {
  final String label;
  final StepStatus status;
  final bool isLast;
  final Color track;
  final Color muted;
  final Color sky;

  const _SpineStep({
    required this.label,
    required this.status,
    required this.isLast,
    required this.track,
    required this.muted,
    required this.sky,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrent = status == StepStatus.current;
    final isDone = status == StepStatus.done;
    final dotSize = isCurrent ? 13.0 : 11.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 16,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Connector, drawn behind the dot and only to the right.
              if (!isLast)
                Positioned(
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      const Spacer(),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isDone ? AppColors.amber : track,
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? AppColors.amber
                      : isCurrent
                          ? sky
                          : track,
                  border: isCurrent
                      ? Border.all(color: sky.withValues(alpha: 0.25), width: 3)
                      : null,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: isCurrent ? sky : muted,
          ),
        ),
      ],
    );
  }
}
