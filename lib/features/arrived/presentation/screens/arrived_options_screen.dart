import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

const _gutter = AppSpacing.gutter;

/// The arriving traveller's directory: ways out first, services second.
class ArrivedOptionsScreen extends StatelessWidget {
  const ArrivedOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Arrived', style: theme.textTheme.titleMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(_gutter, 0, _gutter, AppSpacing.xxl),
        children: [
          Text("You've arrived", style: theme.textTheme.displaySmall),
          const SizedBox(height: 3),
          Text('Here are some helpful options',
              style: theme.textTheme.bodySmall?.copyWith(color: muted)),
          const SizedBox(height: AppSpacing.mdLg),
          Row(
            children: [
              _WayTile(
                  icon: Icons.exit_to_app_rounded,
                  label: 'To airport exit',
                  minutes: 2,
                  onTap: () => context.go('/map')),
              const SizedBox(width: AppSpacing.sm),
              _WayTile(
                  icon: Icons.luggage_rounded,
                  label: 'To baggage claim',
                  minutes: 3,
                  onTap: () => context.go('/map')),
              const SizedBox(width: AppSpacing.sm),
              _WayTile(
                  icon: Icons.directions_bus_rounded,
                  label: 'To transport',
                  minutes: 5,
                  onTap: () => context.go('/map')),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'POPULAR SERVICES NEARBY',
            style: theme.textTheme.labelSmall?.copyWith(
              color: muted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ServiceRow(
            icon: Icons.restaurant_rounded,
            title: 'Food & Drink',
            subtitle: '3 options nearby',
            onTap: () => context.go('/explore'),
          ),
          _ServiceRow(
            icon: Icons.wc_rounded,
            title: 'Restrooms',
            subtitle: '1 min away',
            onTap: () => context.go('/map'),
          ),
          _ServiceRow(
            icon: Icons.directions_bus_rounded,
            title: 'Transport',
            subtitle: 'Buses, trains, taxis',
            onTap: () => context.go('/map'),
          ),
          _ServiceRow(
            icon: Icons.luggage_rounded,
            title: 'Baggage Services',
            subtitle: 'Lost & found, assistance',
            onTap: () => context.go('/map'),
          ),
          _ServiceRow(
            icon: Icons.storefront_rounded,
            title: 'Explore the airport',
            subtitle: 'Shops, lounges and more',
            onTap: () => context.go('/explore'),
          ),
        ],
      ),
    );
  }
}

class _WayTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int minutes;
  final VoidCallback onTap;

  const _WayTile({
    required this.icon,
    required this.label,
    required this.minutes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.dSurface : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.dHairline : AppColors.hairline,
            width: 1,
          ),
          boxShadow: isDark ? null : AppShadows.card,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.md),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.skyAlpha15 : AppColors.skyTint,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon,
                        size: 18,
                        color: isDark ? AppColors.dSky : AppColors.sky),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('$minutes min',
                      style: AppTypography.mono(fontSize: 11, color: muted)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ServiceRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.dSurface : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isDark ? AppColors.dHairline : AppColors.hairline,
            width: 1,
          ),
          boxShadow: isDark ? null : AppShadows.card,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
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
                    child: Icon(icon,
                        size: 18,
                        color: isDark ? AppColors.dSky : AppColors.sky),
                  ),
                  const SizedBox(width: AppSpacing.smMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            )),
                        Text(subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: muted)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 18, color: muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
