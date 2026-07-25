import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:airport_nav/core/constants/app_colors.dart';
import 'package:airport_nav/core/constants/app_spacing.dart';
import 'package:airport_nav/core/theme/app_theme.dart';
import 'package:airport_nav/core/widgets/app_buttons.dart';
import 'package:airport_nav/core/widgets/state_views.dart';
import 'package:airport_nav/features/map/domain/entities/map_floor.dart';
import 'package:airport_nav/features/map/presentation/providers/map_providers.dart';
import 'package:airport_nav/features/map/presentation/widgets/map_painter.dart';
import 'package:airport_nav/features/voice_chat/domain/entities/chat_message.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Route Navigation Screen
// ─────────────────────────────────────────────────────────────────────────────

class RouteNavigationScreen extends ConsumerStatefulWidget {
  const RouteNavigationScreen({super.key});

  @override
  ConsumerState<RouteNavigationScreen> createState() =>
      _RouteNavigationScreenState();
}

class _RouteNavigationScreenState extends ConsumerState<RouteNavigationScreen>
    with TickerProviderStateMixin {
  late AnimationController _markerAnimController;
  late Animation<double> _markerAnim;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  int _lastStopIndex = -1;

  @override
  void initState() {
    super.initState();

    _markerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    _markerAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _markerAnimController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Listen for auto-advance when animation completes (playing mode).
    _markerAnimController.addStatusListener(_onMarkerComplete);
  }

  void _onMarkerComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      final navState = ref.read(routeNavProvider);
      if (navState.playing && !navState.arrived) {
        ref.read(routeNavProvider.notifier).next();
      }
    }
  }

  void _restartAnimation(int stopIndex, int walkMinutes,
      {required bool reducedMotion}) {
    if (_lastStopIndex == stopIndex) return;
    _lastStopIndex = stopIndex;

    if (reducedMotion) {
      _markerAnimController.value = 1.0;
      return;
    }

    // Clamp animation duration to [2500ms, 5000ms] based on walkMinutes.
    final durationMs =
        (walkMinutes * 1000).clamp(2500, 5000).toInt();
    _markerAnimController.duration = Duration(milliseconds: durationMs);
    _markerAnimController.forward(from: 0);
  }

  @override
  void dispose() {
    _markerAnimController.removeStatusListener(_onMarkerComplete);
    _markerAnimController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = ref.watch(activeRoutePlanProvider);
    final navState = ref.watch(routeNavProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reducedMotion = MediaQuery.of(context).disableAnimations;

    if (plan == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Navigation'),
          leading: const BackButton(),
        ),
        body: EmptyState(
          icon: Icons.route_rounded,
          title: 'No active route',
          message: 'Go to Voice Chat and create a route plan to get started.',
          action: PrimaryButton(
            label: 'Go back',
            onPressed: () => context.pop(),
          ),
        ),
      );
    }

    final stops = plan.stops;
    final N = stops.length;
    final idx = navState.currentStopIndex.clamp(0, N - 1);
    final currentStop = stops[idx];

    // Floors for this airport
    final floors = ref.watch(airportFloorsProvider);
    final selectedFloorIndex = ref.watch(selectedFloorIndexProvider);
    final selectedFloor = ref.watch(selectedFloorProvider);

    // Auto-switch floor to match current stop's floor number
    final targetFloorIdx = _floorIndexForStop(floors, currentStop.floor);
    if (targetFloorIdx != null && targetFloorIdx != selectedFloorIndex) {
      // Use post-frame to avoid calling setState during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(selectedFloorIndexProvider.notifier).state = targetFloorIdx;
        }
      });
    }

    // Restart marker animation whenever stop changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _restartAnimation(idx, currentStop.walkMinutes,
            reducedMotion: reducedMotion);
      }
    });

    // Fallback canvas dimensions: first available floor's size, else 1000×600.
    final fallbackWidth =
        floors.isNotEmpty ? floors.first.width : 1000.0;
    final fallbackHeight =
        floors.isNotEmpty ? floors.first.height : 600.0;

    // Build stop positions for the current floor (or synthetic on fallback canvas).
    final stopPositions = _buildStopPositions(
      stops,
      selectedFloor,
      fallbackWidth: fallbackWidth,
      fallbackHeight: fallbackHeight,
    );

    // Remaining minutes = sum of (walkMinutes + stayMinutes) for remaining stops
    final remainingMin = stops
        .skip(idx)
        .fold<int>(0, (acc, s) => acc + s.walkMinutes + s.stayMinutes);

    // Progress fraction
    final progress = N > 1 ? (idx + 1) / N : 1.0;

    final bannerBg = isDark ? AppColors.dSurface : AppColors.card;
    final bannerBorder = isDark ? AppColors.dHairline : AppColors.hairline;
    final controlBg = isDark ? AppColors.dSurface : AppColors.card;

    // Instruction text
    final instructionText = _buildInstruction(stops, idx);
    final instructionIcon = _buildInstructionIcon(stops, idx);

    // Next stop preview
    final nextStop = idx + 1 < N ? stops[idx + 1] : null;

    final bool isFinalStop = navState.arrived || idx == N - 1;

    return Scaffold(
      backgroundColor: isDark ? AppColors.dBg : AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress bar ─────────────────────────────────────────
            Container(
              height: 3,
              color: isDark ? AppColors.dSurfaceVariant : AppColors.skyTint,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.dSky : AppColors.sky,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                  ),
                ),
              ),
            ),

            // ── Top instruction banner ────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.smMd,
                AppSpacing.md,
                0,
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: bannerBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: bannerBorder, width: 1),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Large direction icon
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.skyAlpha20
                              : AppColors.skyAlpha10,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Icon(
                          instructionIcon,
                          color: isDark ? AppColors.dSky : AppColors.sky,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.smMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              instructionText,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: isDark ? AppColors.dText : AppColors.ink,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stop ${idx + 1} of $N · $remainingMin min left',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Close / back button
                      Semantics(
                        label: 'Back',
                        button: true,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Center(
                              child: Icon(Icons.close_rounded,
                                  size: 20, color: AppColors.muted),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Map area ──────────────────────────────────────────────
            // Always render the map canvas. When the real floor plan is
            // unavailable (e.g. stop on floor 3 but mock only has floors 1-2)
            // we fall back to a schematic canvas with synthetic stop positions.
            Expanded(
              child: _MapArea(
                floor: selectedFloor,
                fallbackWidth: fallbackWidth,
                fallbackHeight: fallbackHeight,
                fallbackFloorNumber: currentStop.floor,
                stops: stops,
                stopPositions: stopPositions,
                currentStopIndex: idx,
                markerAnim: reducedMotion ? null : _markerAnim,
                pulseAnim: reducedMotion ? null : _pulseAnim,
              ),
            ),

            // ── Bottom control bar ────────────────────────────────────
            _BottomBar(
              isDark: isDark,
              controlBg: controlBg,
              navState: navState,
              nextStop: nextStop,
              isFinalStop: isFinalStop,
              currentStopName:
                  navState.arrived ? currentStop.name : null,
              onPlayPause: () =>
                  ref.read(routeNavProvider.notifier).togglePlay(),
              onNext: () => ref.read(routeNavProvider.notifier).next(),
              onEnd: () {
                ref.read(routeNavProvider.notifier).end();
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  int? _floorIndexForStop(List<MapFloor> floors, int floorNumber) {
    for (int i = 0; i < floors.length; i++) {
      if (floors[i].floorNumber == floorNumber) return i;
    }
    return null;
  }

  /// Resolve each stop to a pixel position on the given floor.
  ///
  /// When [floor] is non-null, only stops whose [RouteStop.floor] matches
  /// the floor's [MapFloor.floorNumber] are included. Each is resolved via a
  /// case-insensitive POI name match first; falls back to synthetic zig-zag.
  ///
  /// When [floor] is null (missing floor plan), ALL stops are given synthetic
  /// positions spread across the fallback canvas so the map always renders.
  Map<int, Offset> _buildStopPositions(
    List<RouteStop> stops,
    MapFloor? floor, {
    required double fallbackWidth,
    required double fallbackHeight,
  }) {
    final result = <int, Offset>{};

    if (floor == null) {
      // Schematic fallback: spread every stop across the fallback canvas.
      final total = stops.length;
      for (int i = 0; i < total; i++) {
        result[i] = _syntheticPosition(i, total, fallbackWidth, fallbackHeight);
      }
      return result;
    }

    final pois = floor.pois;

    // Only include stops that are on this floor's floorNumber.
    final stopsOnFloor = <int>[];
    for (int i = 0; i < stops.length; i++) {
      if (stops[i].floor == floor.floorNumber) {
        stopsOnFloor.add(i);
      }
    }

    int syntheticCount = 0;
    for (final i in stopsOnFloor) {
      final stop = stops[i];
      // Try POI name match (case-insensitive contains).
      PointOfInterest? matched;
      for (final poi in pois) {
        if (poi.name.toLowerCase().contains(stop.name.toLowerCase()) ||
            stop.name.toLowerCase().contains(poi.name.toLowerCase())) {
          matched = poi;
          break;
        }
      }
      if (matched != null) {
        result[i] = Offset(matched.x, matched.y);
      } else {
        // Synthetic position: deterministic zig-zag across the floor
        result[i] = _syntheticPosition(
          syntheticCount,
          stopsOnFloor.length,
          floor.width,
          floor.height,
        );
        syntheticCount++;
      }
    }
    return result;
  }

  /// Distribute stops in a zig-zag across the floor (deterministic).
  Offset _syntheticPosition(
      int rank, int total, double width, double height) {
    // Divide floor into columns, alternate rows top/bottom.
    final cols = math.max(1, total);
    final colWidth = (width - 160) / cols;
    final x = 80 + colWidth * rank + colWidth / 2;
    final y = (rank % 2 == 0) ? height * 0.3 : height * 0.7;
    return Offset(x, y);
  }

  String _buildInstruction(List<RouteStop> stops, int idx) {
    final stop = stops[idx];
    if (stop.directions.isNotEmpty) {
      return stop.directions.first.instruction;
    }
    if (idx > 0) {
      final prev = stops[idx - 1];
      if (prev.floor != stop.floor) {
        return 'Take the escalator to Floor ${stop.floor}';
      }
      return 'Walk ${stop.walkMinutes} min to ${stop.name} · Floor ${stop.floor}';
    }
    return 'Head to ${stop.name} · Floor ${stop.floor}';
  }

  IconData _buildInstructionIcon(List<RouteStop> stops, int idx) {
    final stop = stops[idx];
    if (stop.directions.isNotEmpty) {
      return _directionIcon(stop.directions.first.icon);
    }
    if (idx > 0 && stops[idx - 1].floor != stop.floor) {
      return Icons.escalator_rounded;
    }
    return Icons.directions_walk_rounded;
  }

  IconData _directionIcon(String icon) {
    switch (icon) {
      case 'turn_left':
        return Icons.turn_left_rounded;
      case 'turn_right':
        return Icons.turn_right_rounded;
      case 'straight':
        return Icons.straight_rounded;
      case 'escalator_up':
        return Icons.escalator_rounded;
      case 'escalator_down':
        return Icons.escalator_rounded;
      case 'elevator_up':
      case 'elevator_down':
        return Icons.elevator_rounded;
      case 'destination':
        return Icons.flag_rounded;
      default:
        return Icons.directions_walk_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map Area - draws the floor with route polyline + animated markers.
// When [floor] is null the real floor plan is unavailable (e.g. stop on a
// floor the mock data doesn't define). In that case we render a schematic
// fallback canvas of [fallbackWidth]×[fallbackHeight] and still draw the
// route polyline, numbered stop markers, and the "you are here" dot so the
// map is never blank.
// ─────────────────────────────────────────────────────────────────────────────

class _MapArea extends StatelessWidget {
  /// Real floor plan. Null when the current stop's floor has no map data.
  final MapFloor? floor;

  /// Canvas dimensions used when [floor] is null.
  final double fallbackWidth;
  final double fallbackHeight;

  /// Floor number shown in the schematic label when [floor] is null.
  final int fallbackFloorNumber;

  final List<RouteStop> stops;
  final Map<int, Offset> stopPositions;
  final int currentStopIndex;
  final Animation<double>? markerAnim;
  final Animation<double>? pulseAnim;

  const _MapArea({
    required this.floor,
    required this.fallbackWidth,
    required this.fallbackHeight,
    required this.fallbackFloorNumber,
    required this.stops,
    required this.stopPositions,
    required this.currentStopIndex,
    required this.markerAnim,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final canvasWidth = floor?.width ?? fallbackWidth;
    final canvasHeight = floor?.height ?? fallbackHeight;

    return ClipRect(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        boundaryMargin: const EdgeInsets.all(80),
        child: SizedBox(
          width: canvasWidth,
          height: canvasHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Floor plan background - real plan when available, schematic otherwise.
              Positioned.fill(
                child: floor != null
                    ? CustomPaint(
                        painter: MapPainter(floor: floor!),
                      )
                    : _SchematicBackground(
                        width: canvasWidth,
                        height: canvasHeight,
                        isDark: isDark,
                        floorNumber: fallbackFloorNumber,
                        theme: theme,
                      ),
              ),

              // Route polyline through stop positions on this floor
              if (stopPositions.length >= 2)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: markerAnim ?? const AlwaysStoppedAnimation(1.0),
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _RoutePolylinePainter(
                          stopPositions: stopPositions,
                          stops: stops,
                          currentIndex: currentStopIndex,
                        ),
                      );
                    },
                  ),
                ),

              // Stop markers
              ...stopPositions.entries.map((entry) {
                final i = entry.key;
                final pos = entry.value;
                final isCurrent = i == currentStopIndex;
                final isDone = i < currentStopIndex;
                return Positioned(
                  left: pos.dx - 16,
                  top: pos.dy - 16,
                  child: _StopMarker(
                    index: i,
                    isCurrent: isCurrent,
                    isDone: isDone,
                  ),
                );
              }),

              // Animated "you are here" dot moving from current to next
              if (stopPositions.containsKey(currentStopIndex))
                AnimatedBuilder(
                  animation: markerAnim ?? const AlwaysStoppedAnimation(1.0),
                  builder: (context, _) {
                    final t = markerAnim?.value ?? 1.0;
                    final fromPos = stopPositions[currentStopIndex]!;
                    final toPos = currentStopIndex + 1 < stops.length
                        ? stopPositions[currentStopIndex + 1] ?? fromPos
                        : fromPos;
                    final interpX = fromPos.dx + (toPos.dx - fromPos.dx) * t;
                    final interpY = fromPos.dy + (toPos.dy - fromPos.dy) * t;
                    return Positioned(
                      left: interpX - 12,
                      top: interpY - 12,
                      child: AnimatedBuilder(
                        animation:
                            pulseAnim ?? const AlwaysStoppedAnimation(1.0),
                        builder: (context, _) {
                          final scale = pulseAnim?.value ?? 1.0;
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.sky.withAlpha(0x33),
                                border: Border.all(
                                  color: AppColors.sky,
                                  width: 2.5,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Schematic background - shown when the real floor plan is unavailable.
// Draws a clean grid canvas with a subtle "Floor N - schematic view" label,
// using Sky Pass tokens so it's light/dark aware.
// ─────────────────────────────────────────────────────────────────────────────

class _SchematicBackground extends StatelessWidget {
  final double width;
  final double height;
  final bool isDark;
  final int floorNumber;
  final ThemeData theme;

  const _SchematicBackground({
    required this.width,
    required this.height,
    required this.isDark,
    required this.floorNumber,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SchematicPainter(
        width: width,
        height: height,
        isDark: isDark,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.dSurfaceVariant
                  : AppColors.skyAlpha10,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              'Floor $floorNumber - schematic view',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? AppColors.dSky : AppColors.sky,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SchematicPainter extends CustomPainter {
  final double width;
  final double height;
  final bool isDark;

  _SchematicPainter({
    required this.width,
    required this.height,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color = isDark ? AppColors.dSurface : AppColors.paper,
    );

    // Outer border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(12, 12, size.width - 24, size.height - 24),
        const Radius.circular(12),
      ),
      Paint()
        ..color = isDark ? AppColors.dHairline : AppColors.hairlineCool
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Subtle grid lines
    final gridPaint = Paint()
      ..color =
          (isDark ? AppColors.dHairline : AppColors.hairline).withAlpha(0x60)
      ..strokeWidth = 0.5;

    final scaleX = size.width / width;
    final scaleY = size.height / height;

    for (double x = 100; x < width; x += 100) {
      canvas.drawLine(
        Offset(x * scaleX, 12),
        Offset(x * scaleX, size.height - 12),
        gridPaint,
      );
    }
    for (double y = 100; y < height; y += 100) {
      canvas.drawLine(
        Offset(12, y * scaleY),
        Offset(size.width - 12, y * scaleY),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SchematicPainter old) =>
      old.isDark != isDark || old.width != width || old.height != height;
}

// ─────────────────────────────────────────────────────────────────────────────
// Route polyline painter
// ─────────────────────────────────────────────────────────────────────────────

class _RoutePolylinePainter extends CustomPainter {
  final Map<int, Offset> stopPositions;
  final List<RouteStop> stops;
  final int currentIndex;

  _RoutePolylinePainter({
    required this.stopPositions,
    required this.stops,
    required this.currentIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sortedKeys = stopPositions.keys.toList()..sort();
    if (sortedKeys.length < 2) return;

    // Shadow
    final shadowPaint = Paint()
      ..color = AppColors.skyAlpha20
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Dashed sky line
    final linePaint = Paint()
      ..color = AppColors.sky
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    bool started = false;
    for (final k in sortedKeys) {
      final pos = stopPositions[k]!;
      if (!started) {
        path.moveTo(pos.dx, pos.dy);
        started = true;
      } else {
        path.lineTo(pos.dx, pos.dy);
      }
    }
    canvas.drawPath(path, shadowPaint);
    _drawDashed(canvas, path, linePaint);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dash = 12.0;
    const gap = 8.0;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        final end = (d + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePolylinePainter old) =>
      old.currentIndex != currentIndex ||
      old.stopPositions.length != stopPositions.length;
}

// ─────────────────────────────────────────────────────────────────────────────
// Stop marker widget
// ─────────────────────────────────────────────────────────────────────────────

class _StopMarker extends StatelessWidget {
  final int index;
  final bool isCurrent;
  final bool isDone;

  const _StopMarker({
    required this.index,
    required this.isCurrent,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isCurrent
        ? AppColors.sky
        : isDone
            ? AppColors.muted
            : Colors.white;
    final Color border = isCurrent
        ? AppColors.sky
        : isDone
            ? AppColors.muted
            : AppColors.hairline;
    final Color textColor = isCurrent || isDone ? Colors.white : AppColors.ink;
    final double size = isCurrent ? 36.0 : 28.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        border: Border.all(color: border, width: isCurrent ? 2.5 : 1.5),
        boxShadow: isCurrent ? AppShadows.card : null,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontSize: isCurrent ? 13 : 11,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom control bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final bool isDark;
  final Color controlBg;
  final RouteNavState navState;
  final RouteStop? nextStop;
  final bool isFinalStop;
  final String? currentStopName; // non-null when arrived
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onEnd;

  const _BottomBar({
    required this.isDark,
    required this.controlBg,
    required this.navState,
    required this.nextStop,
    required this.isFinalStop,
    required this.currentStopName,
    required this.onPlayPause,
    required this.onNext,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hairline = isDark ? AppColors.dHairline : AppColors.hairline;

    return Container(
      decoration: BoxDecoration(
        color: controlBg,
        border: Border(top: BorderSide(color: hairline, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.smMd, AppSpacing.md, AppSpacing.md),
      child: isFinalStop
          ? _ArrivedBar(
              isDark: isDark,
              stopName: currentStopName ?? (nextStop?.name ?? 'destination'),
              theme: theme,
              onDone: onEnd,
            )
          : _NavigatingBar(
              isDark: isDark,
              theme: theme,
              navState: navState,
              nextStop: nextStop,
              onPlayPause: onPlayPause,
              onNext: onNext,
              onEnd: onEnd,
            ),
    );
  }
}

class _NavigatingBar extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  final RouteNavState navState;
  final RouteStop? nextStop;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onEnd;

  const _NavigatingBar({
    required this.isDark,
    required this.theme,
    required this.navState,
    required this.nextStop,
    required this.onPlayPause,
    required this.onNext,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Next stop preview
        if (nextStop != null) ...[
          Row(
            children: [
              Icon(Icons.arrow_forward_rounded,
                  size: 14,
                  color: isDark ? AppColors.dMuted : AppColors.muted),
              const SizedBox(width: 6),
              Text(
                'Next: ${nextStop!.name}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.dMuted : AppColors.muted,
                ),
              ),
              const SizedBox(width: 8),
              // Stay pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.skyAlpha10,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '${nextStop!.stayMinutes} min',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isDark ? AppColors.dSky : AppColors.sky,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.smMd),
        ],

        // Action row
        Row(
          children: [
            // Play/Pause
            Semantics(
              label: navState.playing ? 'Pause auto-advance' : 'Play auto-advance',
              button: true,
              child: GestureDetector(
                onTap: onPlayPause,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    color: isDark
                        ? AppColors.dSurfaceVariant
                        : AppColors.skyTint,
                  ),
                  child: Icon(
                    navState.playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: isDark ? AppColors.dSky : AppColors.sky,
                    size: 26,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Next
            Expanded(
              child: Semantics(
                label: 'Next stop',
                button: true,
                child: PrimaryButton(
                  label: 'Next',
                  icon: Icons.skip_next_rounded,
                  onPressed: onNext,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // End
            Semantics(
              label: 'End navigation',
              button: true,
              child: GestureDetector(
                onTap: onEnd,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                    color: isDark
                        ? AppColors.dSurfaceVariant
                        : AppColors.skyTint,
                  ),
                  child: Icon(
                    Icons.stop_rounded,
                    color: isDark ? AppColors.dMuted : AppColors.muted,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ArrivedBar extends StatelessWidget {
  final bool isDark;
  final String stopName;
  final ThemeData theme;
  final VoidCallback onDone;

  const _ArrivedBar({
    required this.isDark,
    required this.stopName,
    required this.theme,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Icon(Icons.flag_rounded,
                color: AppColors.success, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                "You've arrived at $stopName",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? AppColors.dText : AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.smMd),
        Semantics(
          label: 'Done - end navigation',
          button: true,
          child: PrimaryButton(
            label: 'Done',
            icon: Icons.check_rounded,
            onPressed: onDone,
          ),
        ),
      ],
    );
  }
}
