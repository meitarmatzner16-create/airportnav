import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../domain/entities/journey.dart';
import '../../domain/entities/journey_step.dart';
import '../providers/journey_providers.dart';

const _gutter = AppSpacing.gutter;

/// Page two of a journey. Departing gets the guide - a timeline with what is
/// already complete and what is left. Connecting gets the plan - a checklist
/// of what this connection involves, then the steps and a way to navigate.
class JourneyStepsScreen extends ConsumerWidget {
  const JourneyStepsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final journey = ref.watch(journeyProvider);
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final isConnecting = journey?.stage == JourneyStage.connecting;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          isConnecting ? 'Connection journey' : 'Departure guide',
          style: theme.textTheme.titleMedium,
        ),
      ),
      body: journey == null
          ? Center(
              child: Text('No journey yet',
                  style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                  _gutter, 0, _gutter, AppSpacing.xxl),
              children: [
                Text(
                  isConnecting
                      ? 'Your connection plan'
                      : 'Your departure journey',
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(height: 3),
                Text(
                  isConnecting
                      ? "You're all set!"
                      : 'Follow these steps to your gate',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                const SizedBox(height: AppSpacing.mdLg),
                if (isConnecting) ...[
                  _PlanChecklist(journey: journey),
                  const SizedBox(height: AppSpacing.mdLg),
                  Text(
                    'YOUR NEXT STEPS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                // The flight choice is step zero of the process, not a walk -
                // the guide starts where the walking starts.
                for (var i = 1; i < journey.steps.length; i++)
                  _TimelineRow(
                    step: journey.steps[i],
                    status: journey.statusOf(i),
                    isLast: i == journey.steps.length - 1,
                  ),
                if (isConnecting) ...[
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Start Navigation',
                    icon: Icons.near_me_rounded,
                    onPressed: () => context.push('/navigate'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(const SnackBar(
                              content: Text('Added to your calendar.')));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 15, color: muted),
                            const SizedBox(width: 6),
                            Text('Add to calendar',
                                style: theme.textTheme.labelLarge
                                    ?.copyWith(color: muted)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else if (journey.flight != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _DepartureFooter(journey: journey),
                ],
              ],
            ),
    );
  }
}

/// "Everything looks good" - what this connection does and does not involve,
/// derived from the steps that were actually built rather than asserted.
class _PlanChecklist extends StatelessWidget {
  final Journey journey;
  const _PlanChecklist({required this.journey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kinds = journey.steps.map((s) => s.kind).toSet();
    final items = <String>[
      if (kinds.contains(StepKind.security)) 'Security required',
      kinds.contains(StepKind.passport)
          ? 'Passport control required'
          : 'No passport control',
      'No baggage to collect',
      kinds.contains(StepKind.transfer)
          ? 'Terminal transfer needed'
          : 'No terminal transfer',
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.successAlpha15,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.success, width: 1),
      ),
      padding: const EdgeInsets.all(AppSpacing.smMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Everything looks good',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded,
                      size: 14, color: AppColors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// "Departure: 15:30 - have a great flight."
class _DepartureFooter extends StatelessWidget {
  final Journey journey;
  const _DepartureFooter({required this.journey});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final clock = DateFormat('H:mm');

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
      padding: const EdgeInsets.all(AppSpacing.smMd),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? AppColors.skyAlpha15 : AppColors.skyTint,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(Icons.luggage_rounded,
                size: 18, color: isDark ? AppColors.dSky : AppColors.sky),
          ),
          const SizedBox(width: AppSpacing.smMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Departure: ${clock.format(journey.flight!.departureTime)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text('Have a great flight!',
                    style: theme.textTheme.bodySmall?.copyWith(color: muted)),
              ],
            ),
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
            width: 18,
            child: Column(
              children: [
                const SizedBox(height: 3),
                isDone
                    ? Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success,
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 11, color: Colors.white),
                      )
                    : Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent ? sky : track,
                        ),
                      ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: isDone ? AppColors.success : track,
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
                      if (step.deadline != null && !isDone)
                        Text(
                          clock.format(step.deadline!),
                          style: AppTypography.mono(fontSize: 11, color: muted),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDone ? 'Complete' : step.where,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                  if (!isDone && step.totalMinutes > 0) ...[
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
