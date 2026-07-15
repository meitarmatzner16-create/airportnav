import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

/// Home top bar: "AirportNav" wordmark + airport selector on the left,
/// notifications + profile icon buttons on the right.
class HomeHeader extends StatelessWidget {
  final String airport;
  final List<String> airports;
  final ValueChanged<String> onAirportChanged;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  const HomeHeader({
    super.key,
    required this.airport,
    required this.airports,
    required this.onAirportChanged,
    required this.onNotifications,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.dText : AppColors.ink;
    final mutedColor = isDark ? AppColors.dMuted : AppColors.muted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AirportNav',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              _AirportSelector(
                airport: airport,
                airports: airports,
                onChanged: onAirportChanged,
                color: mutedColor,
              ),
            ],
          ),
        ),
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          semanticLabel: 'Notifications',
          onTap: onNotifications,
        ),
        const SizedBox(width: AppSpacing.smMd),
        _HeaderIconButton(
          icon: Icons.person_outline_rounded,
          semanticLabel: 'Profile',
          onTap: onProfile,
        ),
      ],
    );
  }
}

class _AirportSelector extends StatelessWidget {
  final String airport;
  final List<String> airports;
  final ValueChanged<String> onChanged;
  final Color color;

  const _AirportSelector({
    required this.airport,
    required this.airports,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: airport,
        isDense: true,
        icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: color),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        style: theme.textTheme.titleMedium?.copyWith(color: color),
        selectedItemBuilder: (context) => [
          for (final _ in airports)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$airport Airport',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        items: [
          for (final a in airports)
            DropdownMenuItem(value: a, child: Text('$a Airport')),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final border = isDark ? AppColors.dHairline : AppColors.hairline;
    final iconColor = isDark ? AppColors.dText : AppColors.ink;
    final fill = isDark ? AppColors.dSurface : AppColors.card;

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: border, width: 1),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
        ),
      ),
    );
  }
}
