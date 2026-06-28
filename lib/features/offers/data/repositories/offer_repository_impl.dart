import 'package:airport_nav/features/offers/data/datasources/offer_mock_datasource.dart';
import 'package:airport_nav/features/offers/domain/entities/offer.dart';
import 'package:airport_nav/features/offers/domain/repositories/offer_repository.dart';

class OfferRepositoryImpl implements OfferRepository {
  final OfferMockDatasource _datasource;

  OfferRepositoryImpl({OfferMockDatasource? datasource})
      : _datasource = datasource ?? OfferMockDatasource();

  @override
  List<Offer> getAllOffers() {
    return _datasource.getAllOffers();
  }

  @override
  List<Offer> getOffersByAirport(String airportCode) {
    final code = airportCode.toUpperCase();
    return _datasource
        .getAllOffers()
        .where((offer) => offer.airportCode.toUpperCase() == code)
        .toList();
  }

  @override
  List<Offer> getOffersByCategory(String category) {
    final cat = category.toLowerCase();
    return _datasource
        .getAllOffers()
        .where((offer) => offer.category.toLowerCase() == cat)
        .toList();
  }

  @override
  Offer? getOfferById(String id) {
    try {
      return _datasource.getAllOffers().firstWhere((offer) => offer.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Offer> getPersonalizedOffers(List<String> airportCodes) {
    if (airportCodes.isEmpty) return [];
    final codes = airportCodes.map((c) => c.toUpperCase()).toSet();
    return _datasource
        .getAllOffers()
        .where((offer) => codes.contains(offer.airportCode.toUpperCase()))
        .toList();
  }
}
