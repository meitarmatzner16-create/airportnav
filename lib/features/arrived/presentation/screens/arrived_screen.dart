import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/app_theme.dart';

const _gutter = AppSpacing.gutter;

/// "Welcome! You've arrived" - not a step journey. An arriving traveller
/// needs services and a way out, so this is a directory with walk times,
/// not a spine.
class ArrivedScreen extends StatelessWidget {
  const ArrivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: AppSpacing.smMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.go('/home'),
                    child: Text(
                      '‹ Home',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isDark ? AppColors.dSky : AppColors.sky,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text("Welcome! You've arrived",
                      style: theme.textTheme.displaySmall),
                  const SizedBox(height: 2),
                  Text("Let's help you find what you need.",
                      style: theme.textTheme.bodySmall?.copyWith(color: muted)),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.mdLg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: Row(
                children: [
                  _CategoryTile(
                    icon: Icons.wc_rounded,
                    label: 'Toilets',
                    onTap: () => context.go('/map'),
                  ),
                  _CategoryTile(
                    icon: Icons.restaurant_rounded,
                    label: 'Food &\nDrink',
                    onTap: () => context.go('/explore'),
                  ),
                  _CategoryTile(
                    icon: Icons.directions_bus_rounded,
                    label: 'Transport',
                    onTap: () => context.push('/arrived/options'),
                  ),
                  _CategoryTile(
                    icon: Icons.weekend_rounded,
                    label: 'Lounges',
                    onTap: () => context.go('/explore'),
                  ),
                  _CategoryTile(
                    icon: Icons.more_horiz_rounded,
                    label: 'More',
                    onTap: () => context.push('/arrived/options'),
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Popular near you',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                  InkWell(
                    onTap: () => context.push('/arrived/options'),
                    child: Text('View all ›',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isDark ? AppColors.dSky : AppColors.sky,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: Row(
                children: [
                  _NearTile(
                      icon: Icons.hail_rounded,
                      label: 'Pick up',
                      minutes: 2,
                      onTap: () => context.push('/arrived/options')),
                  const SizedBox(width: AppSpacing.sm),
                  _NearTile(
                      icon: Icons.luggage_rounded,
                      label: 'Baggage claim',
                      minutes: 3,
                      onTap: () => context.push('/arrived/options')),
                  const SizedBox(width: AppSpacing.sm),
                  _NearTile(
                      icon: Icons.wc_rounded,
                      label: 'Toilets',
                      minutes: 1,
                      onTap: () => context.go('/map')),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: _LoungeCard(onTap: () => context.go('/explore')),
            ),
            const SizedBox(height: AppSpacing.smMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: _UpdatesStrip(onTap: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                      content:
                          Text('Gate changes and delays appear here live.')));
              }),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool last;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.dText : AppColors.ink;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: last ? 0 : AppSpacing.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Column(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dSurface : AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.dHairline : AppColors.hairline,
                    width: 1,
                  ),
                  boxShadow: isDark ? null : AppShadows.card,
                ),
                child: Icon(icon, size: 20, color: textColor),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int minutes;
  final VoidCallback onTap;

  const _NearTile({
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
                  horizontal: AppSpacing.sm, vertical: AppSpacing.smMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: textColor),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
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

class _LoungeCard extends StatelessWidget {
  final VoidCallback onTap;
  const _LoungeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final muted = isDark ? AppColors.dMuted : AppColors.muted;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final sky = isDark ? AppColors.dSky : AppColors.sky;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.skyAlpha15 : AppColors.skyTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Airport Lounge',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 2),
                      Text('Relax before your next journey',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: muted)),
                      const SizedBox(height: AppSpacing.sm),
                      Text('View lounges ›',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: sky,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
                Icon(Icons.chair_rounded, size: 44, color: sky),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpdatesStrip extends StatelessWidget {
  final VoidCallback onTap;
  const _UpdatesStrip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.amberAlpha15,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.amber, width: 1),
          ),
          padding: const EdgeInsets.all(AppSpacing.smMd),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 18, color: AppColors.amberText),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Live airport updates',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.amberText,
                          fontWeight: FontWeight.w700,
                        )),
                    Text('Check gate changes, delays and queue times.',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.amberText)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
