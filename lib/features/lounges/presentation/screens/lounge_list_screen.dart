import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/widgets/state_views.dart';
import 'package:airport_nav/features/lounges/presentation/providers/lounge_providers.dart';
import 'package:airport_nav/features/lounges/presentation/widgets/lounge_card.dart';

/// Sky Pass-styled lounge list screen.
///
/// Uses [LoadingState] shimmer when data is pending, [EmptyState] with a
/// weekend icon when no lounges exist, and a scrolling list of [LoungeCard]s
/// with 24px horizontal gutters otherwise.
class LoungeListScreen extends ConsumerWidget {
  final String airportCode;

  const LoungeListScreen({
    super.key,
    required this.airportCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lounges = ref.watch(loungesByAirportProvider(airportCode));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      appBar: AppBar(
        title: Text('Lounges · $airportCode'),
      ),
      body: lounges.isEmpty
          ? const EmptyState(
              icon: Icons.weekend_rounded,
              title: 'No lounges found',
              message: 'There are no lounges available at this airport.',
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              itemCount: lounges.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.smMd),
              itemBuilder: (context, index) {
                final lounge = lounges[index];
                return LoungeCard(
                  lounge: lounge,
                  onTap: () => context.push('/lounges/${lounge.id}'),
                );
              },
            ),
    );
  }
}
