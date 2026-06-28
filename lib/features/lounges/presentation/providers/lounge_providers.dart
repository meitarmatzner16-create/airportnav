import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/lounges/data/repositories/lounge_repository_impl.dart';
import 'package:airport_nav/features/lounges/domain/entities/lounge.dart';
import 'package:airport_nav/features/lounges/domain/repositories/lounge_repository.dart';

final loungeRepositoryProvider = Provider<LoungeRepository>((ref) {
  return LoungeRepositoryImpl();
});

final loungesByAirportProvider =
    Provider.family<List<Lounge>, String>((ref, airportCode) {
  final repository = ref.watch(loungeRepositoryProvider);
  return repository.getLoungesByAirport(airportCode);
});

final loungeByIdProvider = Provider.family<Lounge?, String>((ref, loungeId) {
  final repository = ref.watch(loungeRepositoryProvider);
  return repository.getLoungeById(loungeId);
});
