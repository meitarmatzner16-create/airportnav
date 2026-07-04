import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/map/data/repositories/map_repository_impl.dart';
import 'package:airport_nav/features/map/domain/entities/map_floor.dart';
import 'package:airport_nav/features/map/domain/repositories/map_repository.dart';
import 'package:airport_nav/features/voice_chat/domain/entities/chat_message.dart';

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  return MapRepositoryImpl();
});

final selectedMapAirportProvider = StateProvider<String>((ref) => 'JFK');

final airportFloorsProvider = Provider<List<MapFloor>>((ref) {
  final airportCode = ref.watch(selectedMapAirportProvider);
  final repository = ref.watch(mapRepositoryProvider);
  return repository.getFloorsByAirport(airportCode);
});

final selectedFloorIndexProvider = StateProvider<int>((ref) => 0);

final selectedFloorProvider = Provider<MapFloor?>((ref) {
  final floors = ref.watch(airportFloorsProvider);
  final index = ref.watch(selectedFloorIndexProvider);
  if (floors.isEmpty || index >= floors.length) return null;
  return floors[index];
});

final floorPoisProvider = Provider<List<PointOfInterest>>((ref) {
  final floor = ref.watch(selectedFloorProvider);
  return floor?.pois ?? [];
});

final selectedPoiProvider = StateProvider<PointOfInterest?>((ref) => null);

final navigationFromPoiProvider = StateProvider<PointOfInterest?>((ref) => null);
final navigationToPoiProvider = StateProvider<PointOfInterest?>((ref) => null);

final activeNavPathProvider = Provider<NavPath?>((ref) {
  final from = ref.watch(navigationFromPoiProvider);
  final to = ref.watch(navigationToPoiProvider);
  if (from == null || to == null) return null;
  final repository = ref.watch(mapRepositoryProvider);
  return repository.findPath(from.id, to.id);
});

final mapSearchQueryProvider = StateProvider<String>((ref) => '');

final mapSearchResultsProvider = Provider<List<PointOfInterest>>((ref) {
  final query = ref.watch(mapSearchQueryProvider);
  final airportCode = ref.watch(selectedMapAirportProvider);
  final repository = ref.watch(mapRepositoryProvider);
  return repository.searchPois(airportCode, query);
});

// ─────────────────────────────────────────────────────────────────────────────
// Guided Route Navigation
// ─────────────────────────────────────────────────────────────────────────────

/// The RoutePlan currently being navigated. Null when no navigation is active.
final activeRoutePlanProvider = StateProvider<RoutePlan?>((ref) => null);

/// State for the guided-nav controller.
class RouteNavState {
  final int currentStopIndex;
  final bool playing;
  final bool arrived;

  const RouteNavState({
    this.currentStopIndex = 0,
    this.playing = false,
    this.arrived = false,
  });

  RouteNavState copyWith({
    int? currentStopIndex,
    bool? playing,
    bool? arrived,
  }) {
    return RouteNavState(
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
      playing: playing ?? this.playing,
      arrived: arrived ?? this.arrived,
    );
  }
}

class RouteNavController extends StateNotifier<RouteNavState> {
  final Ref _ref;

  RouteNavController(this._ref) : super(const RouteNavState());

  void start(RoutePlan plan) {
    _ref.read(activeRoutePlanProvider.notifier).state = plan;
    state = const RouteNavState(currentStopIndex: 0, playing: false, arrived: false);
  }

  void next() {
    final plan = _ref.read(activeRoutePlanProvider);
    if (plan == null) return;
    final nextIndex = state.currentStopIndex + 1;
    if (nextIndex >= plan.stops.length) {
      state = state.copyWith(arrived: true, playing: false);
    } else {
      state = state.copyWith(currentStopIndex: nextIndex);
    }
  }

  void previous() {
    if (state.currentStopIndex > 0) {
      state = state.copyWith(
        currentStopIndex: state.currentStopIndex - 1,
        arrived: false,
      );
    }
  }

  void togglePlay() {
    state = state.copyWith(playing: !state.playing);
  }

  void end() {
    _ref.read(activeRoutePlanProvider.notifier).state = null;
    state = const RouteNavState();
  }
}

final routeNavProvider =
    StateNotifierProvider<RouteNavController, RouteNavState>((ref) {
  return RouteNavController(ref);
});
