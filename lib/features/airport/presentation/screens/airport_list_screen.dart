import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/constants/app_typography.dart';
import 'package:airport_nav/core/widgets/app_card.dart';
import 'package:airport_nav/core/widgets/search_bar_widget.dart';
import 'package:airport_nav/core/widgets/state_views.dart';
import 'package:airport_nav/features/airport/domain/entities/airport.dart';
import 'package:airport_nav/features/airport/presentation/providers/airport_providers.dart';

/// Sky Pass-styled airport list screen.
///
/// Token SearchBarWidget + a list of AppCard airport rows.
/// IATA code in .mono, EmptyState when no airports match.
class AirportListScreen extends ConsumerWidget {
  const AirportListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final airports = ref.watch(filteredAirportsProvider);
    final query = ref.watch(airportSearchQueryProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      appBar: AppBar(
        title: Text(
          'Explore Airports',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: isDark ? AppColors.dText : AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ────────────────────────────────────────────────
          SearchBarWidget(
            hint: 'Search airports, cities, or codes…',
            onChanged: (value) {
              ref.read(airportSearchQueryProvider.notifier).state = value;
            },
          ),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: airports.isEmpty
                ? EmptyState(
                    icon: Icons.flight_takeoff_rounded,
                    title: 'No airports found',
                    message: query.isNotEmpty
                        ? 'Try a different search term or code.'
                        : 'No airports are available right now.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.xs,
                      bottom: AppSpacing.xl,
                    ),
                    itemCount: airports.length,
                    itemBuilder: (context, index) {
                      final airport = airports[index];
                      return _AirportRow(
                        airport: airport,
                        onTap: () =>
                            context.go('/explore/airport/${airport.iataCode}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AirportRow extends StatelessWidget {
  final Airport airport;
  final VoidCallback onTap;

  const _AirportRow({required this.airport, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.dMuted : AppColors.muted;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            // ── IATA badge ────────────────────────────────────────────
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? AppColors.dSurfaceVariant : AppColors.skyTint,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              alignment: Alignment.center,
              child: Text(
                airport.iataCode,
                style: AppTypography.mono(
                  fontSize: 13,
                  weight: FontWeight.w700,
                  color: isDark ? AppColors.dSky : AppColors.sky,
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.smMd),

            // ── Name + city/country ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    airport.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? AppColors.dText : AppColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${airport.city}, ${airport.country}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Chevron ───────────────────────────────────────────────
            Icon(
              Icons.chevron_right_rounded,
              size: AppSpacing.iconMd,
              color: mutedColor,
            ),
          ],
        ),
      ),
    );
  }
}
