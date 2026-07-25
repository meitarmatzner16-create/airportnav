import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/widgets/venue_image.dart';
import 'package:airport_nav/features/venues/domain/entities/venue.dart';
import 'package:airport_nav/features/venues/domain/entities/venue_details.dart';
import 'package:airport_nav/features/venues/presentation/providers/explore_providers.dart';

const _gutter = AppSpacing.gutter;

/// Full-screen, category-adaptive venue detail. Built around the airport's
/// physical facts: lounges show a "What's inside" amenity grid + access/cost,
/// dining shows menu highlights, shops show featured products.
class VenueDetailScreen extends ConsumerWidget {
  final String venueId;
  const VenueDetailScreen({super.key, required this.venueId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final venue = ref.watch(venueByIdProvider(venueId));

    if (venue == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: const Center(child: Text('Venue not found')),
      );
    }

    final isFav = ref.watch(favoriteVenuesProvider).contains(venue.id);
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Image header + overlaid controls ──────────────────────
          Stack(
            children: [
              VenueImage(venue: venue, height: 210, radius: BorderRadius.zero),
              Positioned(
                top: topInset + 8,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RoundBtn(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => context.pop()),
                    _RoundBtn(
                      icon: isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isFav ? AppColors.star : AppColors.ink,
                      onTap: () => toggleFavorite(ref, venue.id),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Title block ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(_gutter, 16, _gutter, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(venue.name, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 2),
                Text(venue.location,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.muted)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _OpenBadge(isOpen: venue.isOpenNow),
                    const SizedBox(width: 12),
                    const Icon(Icons.star_rounded, size: 15, color: AppColors.star),
                    const SizedBox(width: 3),
                    Text(
                      '${venue.rating.toStringAsFixed(1)} · ${venue.reviewCount ?? 0} reviews',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),
          _StatRow(venue: venue),

          // ── About ─────────────────────────────────────────────────
          _Section(
            label: 'ABOUT',
            child: Text(venue.description, style: theme.textTheme.bodyMedium),
          ),

          if (venue.bestTime != null) _BestTimeCard(bt: venue.bestTime!),

          _AdaptiveSection(venue: venue),

          if (venue.directions != null) _DirectionsBlock(d: venue.directions!),

          const SizedBox(height: 28),
        ],
      ),
      bottomNavigationBar: _Footer(
        onDirections: () => context.push('/map'),
        onAddToPlan: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added to your plan')),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Adaptive middle section
// ─────────────────────────────────────────────────────────────────────
class _AdaptiveSection extends StatelessWidget {
  final Venue venue;
  const _AdaptiveSection({required this.venue});

  @override
  Widget build(BuildContext context) {
    if (venue.type == VenueType.lounge) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Section(
            label: "WHAT'S INSIDE",
            child: venue.amenities.isEmpty
                ? Text('More info coming soon',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.muted))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final a in venue.amenities) _AmenityChip(amenity: a),
                    ],
                  ),
          ),
          if (venue.access != null) _AccessBlock(access: venue.access!),
        ],
      );
    }

    final isDining = venue.category == 'dining';
    return _Section(
      label: isDining ? 'HIGHLIGHTS' : 'FEATURED',
      trailing: isDining
          ? Text('Full menu',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.sky, fontWeight: FontWeight.w700))
          : (venue.priceLevel != null
              ? Text(venue.priceLevel!.symbols,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: AppColors.muted, fontWeight: FontWeight.w700))
              : null),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (venue.highlights.isEmpty)
            Text('Details coming soon',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.muted))
          else
            for (final h in venue.highlights) _HighlightRow(item: h),
          if (isDining) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final a in venue.amenities)
                  if (a == Amenity.vegan ||
                      a == Amenity.vegetarian ||
                      a == Amenity.halal)
                    _DietChip(amenity: a),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Reusable pieces
// ─────────────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? trailing;
  const _Section({required this.label, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(_gutter, 22, _gutter, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _gutter),
          child: child,
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final Venue venue;
  const _StatRow({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: _gutter),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      child: Row(
        children: [
          _StatCell(
            icon: Icons.directions_walk_rounded,
            value: venue.walkMinutes != null ? '${venue.walkMinutes}m' : '-',
            label: 'Walk',
          ),
          _cellDivider(),
          _StatCell(
            icon: Icons.schedule_rounded,
            value:
                venue.avgVisitMinutes != null ? '${venue.avgVisitMinutes}m' : '-',
            label: 'Avg visit',
          ),
          _cellDivider(),
          _StatCell(
            icon: Icons.meeting_room_rounded,
            value: venue.nearestGate ?? '-',
            label: 'Nearest',
          ),
        ],
      ),
    );
  }

  Widget _cellDivider() =>
      Container(width: 1, height: 34, color: AppColors.hairline);
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatCell({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.sky),
          const SizedBox(height: 5),
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 1),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final Amenity amenity;
  const _AmenityChip({required this.amenity});

  @override
  Widget build(BuildContext context) {
    final info = AmenityInfo.of(amenity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.skyTint,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 16, color: AppColors.sky),
          const SizedBox(width: 7),
          Text(info.label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  )),
        ],
      ),
    );
  }
}

class _DietChip extends StatelessWidget {
  final Amenity amenity;
  const _DietChip({required this.amenity});

  @override
  Widget build(BuildContext context) {
    final info = AmenityInfo.of(amenity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.successAlpha15,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 13, color: AppColors.success),
          const SizedBox(width: 5),
          Text(info.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  )),
        ],
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  final VenueHighlight item;
  const _HighlightRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(Icons.local_offer_rounded,
                size: 16, color: AppColors.muted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
                if (item.note != null)
                  Text(item.note!,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          if (item.price.isNotEmpty) ...[
            const SizedBox(width: 10),
            Text(item.price,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink)),
          ],
        ],
      ),
    );
  }
}

class _AccessBlock extends StatelessWidget {
  final VenueAccess access;
  const _AccessBlock({required this.access});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Section(
      label: 'ACCESS & COST',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (access.rules.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final r in access.rules)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(r,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.ink, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          if (access.entryCost != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.confirmation_number_rounded,
                    size: 16, color: AppColors.sky),
                const SizedBox(width: 8),
                Text('Walk-in ',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.muted)),
                Text(access.entryCost!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.ink, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BestTimeCard extends StatelessWidget {
  final BestTimeWindow bt;
  const _BestTimeCard({required this.bt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Section(
      label: 'BEST TIME FOR YOU',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.skyTint,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 20, color: AppColors.sky),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${bt.start} - ${bt.end}',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(bt.reason,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectionsBlock extends StatelessWidget {
  final DirectionsHint d;
  const _DirectionsBlock({required this.d});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _Section(
      label: 'HOW TO GET THERE',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.hairline, width: 1),
        ),
        child: Row(
          children: [
            const _RouteGlyph(),
            const SizedBox(width: 12),
            Expanded(
              child: Text('${d.text} · ${d.minutes} min',
                  style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteGlyph extends StatelessWidget {
  const _RouteGlyph();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: AppColors.sky, shape: BoxShape.circle),
          ),
          Expanded(child: Container(height: 2, color: AppColors.skyAlpha15)),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.sky, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  final bool isOpen;
  const _OpenBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppColors.success : AppColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.successAlpha15 : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(isOpen ? 'Open now' : 'Closed',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: color ?? AppColors.ink),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final VoidCallback onDirections;
  final VoidCallback onAddToPlan;
  const _Footer({required this.onDirections, required this.onAddToPlan});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.hairline, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(_gutter, 10, _gutter, 10),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: onDirections,
                icon: const Icon(Icons.navigation_rounded, size: 18),
                label: const Text('Directions'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.sky,
                  side: const BorderSide(color: AppColors.sky, width: 1.4),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onAddToPlan,
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: const Text('Add to plan'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.sky,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
