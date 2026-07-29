import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/features/map/presentation/providers/map_providers.dart';
import 'package:airport_nav/features/map/presentation/widgets/map_painter.dart';
import 'package:airport_nav/features/map/presentation/widgets/nav_path_painter.dart';
import 'package:airport_nav/features/map/presentation/widgets/poi_marker.dart';
import 'package:airport_nav/features/map/presentation/widgets/poi_detail_sheet.dart';

class AirportMapScreen extends ConsumerStatefulWidget {
  const AirportMapScreen({super.key});

  @override
  ConsumerState<AirportMapScreen> createState() => _AirportMapScreenState();
}

class _AirportMapScreenState extends ConsumerState<AirportMapScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  static const _airports = ['JFK', 'LAX'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedAirport = ref.watch(selectedMapAirportProvider);
    final floors = ref.watch(airportFloorsProvider);
    final selectedFloorIndex = ref.watch(selectedFloorIndexProvider);
    final selectedFloor = ref.watch(selectedFloorProvider);
    final selectedPoi = ref.watch(selectedPoiProvider);
    final activeNavPath = ref.watch(activeNavPathProvider);
    final searchResults = ref.watch(mapSearchResultsProvider);
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
        child: Column(
        children: [
          // ── Header (consistent with Home / Explore) ──────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter, 12, AppSpacing.gutter, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$selectedAirport Map',
                          style: theme.textTheme.displaySmall),
                      const SizedBox(height: 2),
                      Text(
                        selectedFloor != null
                            ? '${selectedFloor.floorName} · Terminal 4'
                            : 'Terminal 4',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                _MapAirportChip(
                  value: selectedAirport,
                  airports: _airports,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(selectedMapAirportProvider.notifier).state = value;
                      ref.read(selectedFloorIndexProvider.notifier).state = 0;
                      ref.read(selectedPoiProvider.notifier).state = null;
                      ref.read(navigationFromPoiProvider.notifier).state = null;
                      ref.read(navigationToPoiProvider.notifier).state = null;
                    }
                  },
                ),
                const SizedBox(width: 8),
                _MapCircleButton(
                  icon: _showSearch ? Icons.close_rounded : Icons.search_rounded,
                  onTap: () => setState(() {
                    _showSearch = !_showSearch;
                    if (!_showSearch) {
                      _searchController.clear();
                      ref.read(mapSearchQueryProvider.notifier).state = '';
                    }
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Search bar
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search gates, shops, restaurants...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.skyAlpha10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                onChanged: (value) {
                  ref.read(mapSearchQueryProvider.notifier).state = value;
                },
              ),
            ),

          // Search results overlay
          if (_showSearch && searchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.hairline, width: 1),
                boxShadow: AppShadows.card,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final poi = searchResults[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      _poiIcon(poi.category),
                      color: AppColors.accent,
                      size: 20,
                    ),
                    title: Text(poi.name),
                    subtitle: Text(poi.category),
                    onTap: () {
                      ref.read(selectedPoiProvider.notifier).state = poi;
                      setState(() => _showSearch = false);
                      _searchController.clear();
                      ref.read(mapSearchQueryProvider.notifier).state = '';
                    },
                  );
                },
              ),
            ),

          // Floor selector tabs
          if (floors.isNotEmpty)
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: List.generate(floors.length, (index) {
                  final floor = floors[index];
                  final isSelected = index == selectedFloorIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedFloorIndexProvider.notifier).state =
                            index;
                        ref.read(selectedPoiProvider.notifier).state = null;
                        ref.read(navigationFromPoiProvider.notifier).state =
                            null;
                        ref.read(navigationToPoiProvider.notifier).state = null;
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.sky
                              : AppColors.skyTint,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'F${floor.floorNumber}: ${floor.floorName}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

          // Map area
          Expanded(
            child: selectedFloor == null
                ? Center(
                    child: Text(
                      'No map data available',
                      style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                    ),
                  )
                : Stack(
                    children: [
                      // Interactive map
                      InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        boundaryMargin: const EdgeInsets.all(100),
                        child: SizedBox(
                          width: selectedFloor.width,
                          height: selectedFloor.height,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Floor plan background
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: MapPainter(floor: selectedFloor),
                                ),
                              ),

                              // Navigation path overlay
                              if (activeNavPath != null)
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: NavPathPainter(
                                      navPath: activeNavPath,
                                      mapWidth: selectedFloor.width,
                                      mapHeight: selectedFloor.height,
                                    ),
                                  ),
                                ),

                              // POI markers
                              ...selectedFloor.pois.map((poi) {
                                final isSelected =
                                    selectedPoi?.id == poi.id;
                                return Positioned(
                                  left: poi.x - (isSelected ? 18 : 14),
                                  top: poi.y - (isSelected ? 18 : 14),
                                  child: PoiMarker(
                                    poi: poi,
                                    isSelected: isSelected,
                                    onTap: () {
                                      ref
                                          .read(
                                              selectedPoiProvider.notifier)
                                          .state = poi;
                                    },
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                      // Navigation info bar - AppCard-style sky banner
                      if (activeNavPath != null)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            margin: const EdgeInsets.all(AppSpacing.sm),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.smMd,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.sky,
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadowSky,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.navigation,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  '${activeNavPath.distanceMeters.toInt()}m',
                                  style:
                                      theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Icon(Icons.timer,
                                    color: AppColors.whiteAlpha80, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '~${activeNavPath.estimatedMinutes} min',
                                  style:
                                      theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.whiteAlpha80,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(navigationFromPoiProvider
                                            .notifier)
                                        .state = null;
                                    ref
                                        .read(
                                            navigationToPoiProvider.notifier)
                                        .state = null;
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteAlpha20,
                                      borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusSm),
                                    ),
                                    child: Text(
                                      'End',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // POI detail bottom sheet
                      if (selectedPoi != null && activeNavPath == null)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: PoiDetailSheet(
                            poi: selectedPoi,
                            onNavigate: () {
                              // Set this POI as the destination, pick nearest gate as origin
                              final gates = selectedFloor.pois
                                  .where((p) => p.category == 'gate')
                                  .toList();
                              if (gates.isNotEmpty) {
                                ref
                                    .read(navigationFromPoiProvider.notifier)
                                    .state = gates.first;
                                ref
                                    .read(navigationToPoiProvider.notifier)
                                    .state = selectedPoi;
                                ref
                                    .read(selectedPoiProvider.notifier)
                                    .state = null;
                              }
                            },
                            onClose: () {
                              ref.read(selectedPoiProvider.notifier).state =
                                  null;
                            },
                          ),
                        ),
                    ],
                  ),
          ),
        ],
        ),
      ),
    );
  }

  IconData _poiIcon(String category) {
    switch (category) {
      case 'gate':
        return Icons.flight_takeoff;
      case 'shop':
        return Icons.store;
      case 'lounge':
        return Icons.airline_seat_individual_suite;
      case 'restaurant':
        return Icons.restaurant;
      case 'restroom':
        return Icons.wc;
      case 'info':
        return Icons.info_outline;
      case 'security':
        return Icons.security;
      case 'immigration':
        return Icons.badge;
      default:
        return Icons.place;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────
// Header controls (consistent with Home / Explore)
// ─────────────────────────────────────────────────────────────────────
class _MapCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      shape: const CircleBorder(side: BorderSide(color: AppColors.hairline)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: AppColors.ink),
        ),
      ),
    );
  }
}

class _MapAirportChip extends StatelessWidget {
  final String value;
  final List<String> airports;
  final ValueChanged<String?> onChanged;
  const _MapAirportChip({
    required this.value,
    required this.airports,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.hairline, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          icon: const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: AppColors.muted),
          ),
          items: airports
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: onChanged,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.ink,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
