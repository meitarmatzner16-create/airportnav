import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../features/flight/presentation/providers/flight_providers.dart';
import '../../../features/journey/domain/entities/journey.dart';
import '../../../features/journey/presentation/providers/journey_providers.dart';
import 'widgets/home_header.dart';
import 'widgets/stage_card.dart';

const _gutter = AppSpacing.gutter;
const _sectionGap = AppSpacing.sectionGap;

/// Home asks the one question the app cannot answer for itself: are you
/// departing, connecting or arriving? Knowing the flight does not settle it -
/// the same boarding pass belongs to someone about to check in and to someone
/// who just landed with 90 minutes to make the connection.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _airports = ['JFK', 'LAX', 'LHR', 'CDG', 'DXB', 'SIN', 'NRT', 'SFO'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final detectedAirport = ref.watch(detectedAirportProvider);
    final journey = ref.watch(journeyProvider);
    final muted = isDark ? AppColors.dMuted : AppColors.muted;

    void start(JourneyStage stage) {
      ref.read(journeyStageProvider.notifier).state = stage;
      context.push('/journey');
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: AppSpacing.smMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: HomeHeader(
                airport: detectedAirport,
                airports: _airports,
                onAirportChanged: (v) =>
                    ref.read(detectedAirportProvider.notifier).state = v,
                onNotifications: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                        const SnackBar(content: Text("You're all caught up.")));
                },
                onProfile: () => context.go('/more'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hey there', style: theme.textTheme.displaySmall),
                  const SizedBox(height: 3),
                  Text(
                    "Let's get you where you need to go.\nWhat are you doing today?",
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: muted, height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: StageCard(
                icon: Icons.flight_takeoff_rounded,
                title: 'Departing',
                description: "I'm at the airport and heading to my gate.",
                tint: isDark ? AppColors.skyAlpha15 : AppColors.skyTint,
                liveJourney:
                    journey?.stage == JourneyStage.departing ? journey : null,
                onTap: () => start(JourneyStage.departing),
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: StageCard(
                icon: Icons.swap_horiz_rounded,
                title: 'Connecting',
                description: 'I have a connection to another flight.',
                tint: isDark ? AppColors.amberAlpha15 : AppColors.amberTint,
                liveJourney:
                    journey?.stage == JourneyStage.connecting ? journey : null,
                onTap: () => start(JourneyStage.connecting),
              ),
            ),
            const SizedBox(height: AppSpacing.smMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: StageCard(
                icon: Icons.flight_land_rounded,
                title: 'Arrived',
                description: "I've landed and want services or transport.",
                tint: AppColors.successAlpha15,
                onTap: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(const SnackBar(
                        content: Text('Arrived is coming next.')));
                },
              ),
            ),
            const SizedBox(height: _sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _gutter),
              child: _PopularRow(onExplore: () => context.go('/explore')),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _PopularRow extends StatelessWidget {
  final VoidCallback onExplore;
  const _PopularRow({required this.onExplore});

  static const _items = <(IconData, String)>[
    (Icons.restaurant_rounded, 'Food'),
    (Icons.weekend_rounded, 'Lounges'),
    (Icons.shower_rounded, 'Showers'),
    (Icons.shopping_bag_outlined, 'Shops'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? AppColors.dText : AppColors.ink;
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Popular right now',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor, fontWeight: FontWeight.w700)),
            ),
            InkWell(
              onTap: onExplore,
              child: Text('View all',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDark ? AppColors.dSky : AppColors.sky,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.smMd),
        Row(
          children: [
            for (var i = 0; i < _items.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dSurface : AppColors.card,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: hairline, width: 1),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onExplore,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.smMd),
                        child: Column(
                          children: [
                            Icon(_items[i].$1, size: 20, color: textColor),
                            const SizedBox(height: 6),
                            Text(_items[i].$2,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
