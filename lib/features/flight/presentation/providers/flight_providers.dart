import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/datasources/flight_mock_datasource.dart';
import '../../data/repositories/flight_repository_impl.dart';
import '../../domain/entities/flight.dart';
import '../../domain/repositories/flight_repository.dart';

final flightRepositoryProvider = Provider<FlightRepository>(
  (ref) => FlightRepositoryImpl(FlightMockDatasource()),
);

final allFlightsProvider = Provider<List<Flight>>(
  (ref) => ref.watch(flightRepositoryProvider).getAllFlights(),
);

final flightSearchProvider = StateProvider<String>((ref) => '');

final filteredFlightsProvider = Provider<List<Flight>>((ref) {
  final query = ref.watch(flightSearchProvider);
  final repository = ref.watch(flightRepositoryProvider);
  if (query.isEmpty) {
    return repository.getAllFlights();
  }
  return repository.searchFlights(query);
});

final savedFlightIdsProvider =
    StateNotifierProvider<SavedFlightIdsNotifier, List<String>>(
  (ref) => SavedFlightIdsNotifier(),
);

class SavedFlightIdsNotifier extends StateNotifier<List<String>> {
  final Box _box = Hive.box('saved_flights');

  SavedFlightIdsNotifier() : super([]) {
    state = _box.values.cast<String>().toList();
  }

  void toggle(String flightId) {
    if (state.contains(flightId)) {
      remove(flightId);
    } else {
      add(flightId);
    }
  }

  void add(String flightId) {
    if (!state.contains(flightId)) {
      _box.add(flightId);
      state = [...state, flightId];
    }
  }

  void remove(String flightId) {
    final values = _box.values.cast<String>().toList();
    final index = values.indexOf(flightId);
    if (index != -1) {
      _box.deleteAt(index);
    }
    state = state.where((id) => id != flightId).toList();
  }

  bool isSaved(String flightId) => state.contains(flightId);
}

// --- GPS-detected airport (mock: defaults to JFK) ---
final detectedAirportProvider = StateProvider<String>((ref) => 'JFK');

// --- User's selected flight ---
final selectedFlightProvider = StateProvider<Flight?>((ref) => null);

// --- Upcoming flights at the detected airport within 3.5 hours ---
final upcomingFlightsProvider = Provider<List<Flight>>((ref) {
  final airportCode = ref.watch(detectedAirportProvider);
  final allFlights = ref.watch(allFlightsProvider);
  final now = DateTime.now();
  final cutoff = now.add(const Duration(hours: 3, minutes: 30));

  return allFlights.where((f) {
    return f.departureAirport == airportCode &&
        f.departureTime.isAfter(now) &&
        f.departureTime.isBefore(cutoff);
  }).toList()
    ..sort((a, b) => a.departureTime.compareTo(b.departureTime));
});

// Boarding and gate-close derivations live in the journey domain
// (kBoardingLead / kGateCloseLead) - the two providers that duplicated them
// here had no call sites and carried different offsets.
