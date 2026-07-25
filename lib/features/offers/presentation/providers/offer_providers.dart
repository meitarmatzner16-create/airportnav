import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/offers/data/repositories/offer_repository_impl.dart';
import 'package:airport_nav/features/offers/domain/entities/offer.dart';
import 'package:airport_nav/features/offers/domain/repositories/offer_repository.dart';
import 'package:airport_nav/features/flight/presentation/providers/flight_providers.dart';

final offerRepositoryProvider = Provider<OfferRepository>((ref) {
  return OfferRepositoryImpl();
});

final allOffersProvider = Provider<List<Offer>>((ref) {
  return ref.watch(offerRepositoryProvider).getAllOffers();
});

final offerCategoryFilterProvider = StateProvider<String>((ref) => 'all');

/// Offers filtered by selected flight's airport + airline
final filteredOffersProvider = Provider<List<Offer>>((ref) {
  final category = ref.watch(offerCategoryFilterProvider);
  final selectedFlight = ref.watch(selectedFlightProvider);
  final allOffers = ref.watch(allOffersProvider);
  final detectedAirport = ref.watch(detectedAirportProvider);

  final airportCode = selectedFlight?.departureAirport ?? detectedAirport;
  final airline = selectedFlight?.airline;

  // Filter by airport first
  var offers = allOffers.where((o) => o.airportCode == airportCode).toList();

  // Filter out airline-specific offers that don't match the user's airline
  if (airline != null) {
    offers = offers.where((o) => o.airline == null || o.airline == airline).toList();
  } else {
    // No flight selected - only show generic offers (no airline filter)
    offers = offers.where((o) => o.airline == null).toList();
  }

  // Filter by category
  if (category != 'all') {
    offers = offers.where((o) => o.category == category).toList();
  }

  return offers;
});

/// Airline-exclusive offers for the selected flight
final airlineOffersProvider = Provider<List<Offer>>((ref) {
  final selectedFlight = ref.watch(selectedFlightProvider);
  if (selectedFlight == null) return [];

  final allOffers = ref.watch(allOffersProvider);
  return allOffers
      .where((o) =>
          o.airline == selectedFlight.airline &&
          o.airportCode == selectedFlight.departureAirport)
      .toList();
});

final offerByIdProvider = Provider.family<Offer?, String>((ref, id) {
  return ref.watch(offerRepositoryProvider).getOfferById(id);
});

final personalizedOffersProvider = Provider<List<Offer>>((ref) {
  final savedFlightIds = ref.watch(savedFlightIdsProvider);
  final allFlights = ref.watch(allFlightsProvider);
  final repository = ref.watch(offerRepositoryProvider);

  final airportCodes = <String>{};
  for (final flightId in savedFlightIds) {
    final flight = allFlights.where((f) => f.id == flightId).firstOrNull;
    if (flight != null) {
      airportCodes.add(flight.departureAirport);
      airportCodes.add(flight.arrivalAirport);
    }
  }

  return repository.getPersonalizedOffers(airportCodes.toList());
});
