import 'package:airport_nav/features/lounges/data/datasources/lounge_mock_datasource.dart';
import 'package:airport_nav/features/lounges/domain/entities/lounge.dart';
import 'package:airport_nav/features/lounges/domain/repositories/lounge_repository.dart';

class LoungeRepositoryImpl implements LoungeRepository {
  final List<Lounge> _lounges = LoungeMockDatasource.lounges;

  @override
  List<Lounge> getAllLounges() {
    return List.unmodifiable(_lounges);
  }

  @override
  List<Lounge> getLoungesByAirport(String airportCode) {
    return _lounges
        .where((lounge) => lounge.airportCode == airportCode)
        .toList();
  }

  @override
  Lounge? getLoungeById(String id) {
    try {
      return _lounges.firstWhere((lounge) => lounge.id == id);
    } catch (_) {
      return null;
    }
  }
}
