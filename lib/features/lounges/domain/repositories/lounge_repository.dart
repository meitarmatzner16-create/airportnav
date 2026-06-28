import 'package:airport_nav/features/lounges/domain/entities/lounge.dart';

abstract class LoungeRepository {
  List<Lounge> getAllLounges();
  List<Lounge> getLoungesByAirport(String airportCode);
  Lounge? getLoungeById(String id);
}
