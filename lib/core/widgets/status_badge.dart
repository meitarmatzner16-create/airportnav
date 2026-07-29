import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Dot + label badge for flight statuses.
///
/// Status values: on_time, boarding, delayed (+delay mins), cancelled,
/// scheduled, landed, and a generic fallback.
///
/// `onDark`: white text + whiteAlpha20 bg (for use on dark hero surfaces).
class StatusBadge extends StatelessWidget {
  final String status;
  final int? delayMinutes;
  final bool onDark;

  const StatusBadge({
    super.key,
    required this.status,
    this.delayMinutes,
    this.onDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, dotColor, textColor, bgColor) = _resolve();

    final resolvedTextColor = onDark ? Colors.white : textColor;
    final resolvedBg = onDark ? AppColors.whiteAlpha20 : bgColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: resolvedBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onDark ? Colors.white : dotColor,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: resolvedTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, Color, Color) _resolve() {
    return switch (status) {
      'on_time' => (
          'On time',
          AppColors.success,
          AppColors.success,
          AppColors.successAlpha15,
        ),
      'boarding' => (
          'Boarding',
          AppColors.sky,
          AppColors.sky,
          AppColors.skyAlpha15,
        ),
      'delayed' => (
          delayMinutes != null ? 'Delayed +${delayMinutes}m' : 'Delayed',
          AppColors.statusDelayed,
          AppColors.statusDelayed,
          AppColors.statusDelayedAlpha15,
        ),
      'cancelled' => (
          'Cancelled',
          AppColors.error,
          AppColors.error,
          AppColors.errorAlpha15,
        ),
      'scheduled' => (
          'Scheduled',
          AppColors.muted,
          AppColors.muted,
          AppColors.inkAlpha10,
        ),
      'landed' => (
          'Landed',
          AppColors.ink,
          AppColors.ink,
          AppColors.inkAlpha10,
        ),
      _ => (
          '${status[0].toUpperCase()}${status.substring(1)}',
          AppColors.muted,
          AppColors.muted,
          AppColors.inkAlpha10,
        ),
    };
  }
}
