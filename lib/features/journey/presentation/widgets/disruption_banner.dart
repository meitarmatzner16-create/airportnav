import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/disruption.dart';
import '../providers/journey_providers.dart';

/// The announcement you may not have heard, delivered where you are.
///
/// Tapping acknowledges rather than dismisses: the banner collapses to a
/// single line and stays until the affected step is done. A gate change must
/// not be able to leave the screen because somebody tapped once.
class DisruptionBanner extends ConsumerWidget {
  final Disruption disruption;

  const DisruptionBanner({super.key, required this.disruption});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final acknowledged = ref
        .watch(acknowledgedDisruptionsProvider)
        .contains(disruption.affectedStep);

    final isUrgent = disruption.kind == DisruptionKind.gateChange ||
        disruption.kind == DisruptionKind.boardingEarly;
    final fill =
        isUrgent ? AppColors.statusDelayedAlpha15 : AppColors.amberAlpha15;
    final line = isUrgent ? AppColors.statusDelayed : AppColors.amber;
    final ink = isUrgent ? AppColors.statusDelayed : AppColors.amberText;

    return Semantics(
      liveRegion: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => ref
              .read(acknowledgedDisruptionsProvider.notifier)
              .update((s) => {...s, disruption.affectedStep}),
          child: Container(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: line, width: 1),
            ),
            padding: const EdgeInsets.all(AppSpacing.smMd),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_iconFor(disruption.kind), size: 18, color: line),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        disruption.headline,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!acknowledged) ...[
                        const SizedBox(height: 2),
                        Text(
                          disruption.detail,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: ink, height: 1.35),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(DisruptionKind kind) => switch (kind) {
        DisruptionKind.gateChange => Icons.swap_horiz_rounded,
        DisruptionKind.queueSpike => Icons.trending_up_rounded,
        DisruptionKind.boardingEarly => Icons.schedule_rounded,
        DisruptionKind.laneClosed => Icons.block_rounded,
      };
}
