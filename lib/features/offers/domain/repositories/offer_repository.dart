import 'package:airport_nav/features/offers/domain/entities/offer.dart';

abstract class OfferRepository {
  List<Offer> getAllOffers();
  List<Offer> getOffersByAirport(String airportCode);
  List<Offer> getOffersByCategory(String category);
  Offer? getOfferById(String id);
  List<Offer> getPersonalizedOffers(List<String> airportCodes);
}
