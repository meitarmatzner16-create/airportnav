import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../journey/domain/entities/journey.dart';

/// One of the three ways into the airport.
///
/// Before it is chosen it describes a choice. Once it is the active stage it
/// carries live status instead, so the second launch tells the traveller
/// something rather than asking the same question again.
class StageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color tint;
  final Journey? liveJourney;
  final VoidCallback onTap;

  const StageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.tint,
    required this.onTap,
    this.liveJourney,
  });

  bool get _isActive => liveJourney != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sky = isDark ? AppColors.dSky : AppColors.sky;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.dSurface : AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: _isActive
            ? Border.all(color: sky, width: 2)
            : Border.all(color: hairline, width: 1),
        boxShadow: isDark ? null : AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.mdLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: tint,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(icon, size: 20, color: textColor),
                    ),
                    const SizedBox(width: AppSpacing.smMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (_isActive) ...[
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: sky,
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusFull),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style:
                                        theme.textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isActive
                                ? 'Next: ${liveJourney!.currentStep.title}'
                                    '${liveJourney!.currentStep.queueMinutes > 0 ? ' · ${liveJourney!.currentStep.queueMinutes} min queue' : ''}'
                                : description,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: muted, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(Icons.chevron_right_rounded, size: 20, color: muted),
                  ],
                ),
                if (_isActive) ...[
                  const SizedBox(height: AppSpacing.smMd),
                  Divider(height: 1, color: hairline),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _MiniStat(
                        label: 'Step',
                        value:
                            '${liveJourney!.currentIndex + 1} of ${liveJourney!.steps.length}',
                      ),
                      _MiniStat(
                          label: 'Gate', value: liveJourney!.effectiveGate),
                      if (liveJourney!.boardingTime != null)
                        _MiniStat(
                          label: 'Boards',
                          value:
                              '${liveJourney!.boardingTime!.hour.toString().padLeft(2, '0')}:${liveJourney!.boardingTime!.minute.toString().padLeft(2, '0')}',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({required this.label, required this.value});

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
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 1),
          Text(value,
              style: AppTypography.mono(
                  fontSize: 14, weight: FontWeight.w700, color: textColor)),
        ],
      ),
    );
  }
}
