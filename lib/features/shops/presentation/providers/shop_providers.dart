import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:airport_nav/features/shops/data/repositories/shop_repository_impl.dart';
import 'package:airport_nav/features/shops/domain/entities/shop.dart';
import 'package:airport_nav/features/shops/domain/repositories/shop_repository.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepositoryImpl();
});

final shopsByAirportProvider =
    Provider.family<List<Shop>, String>((ref, airportCode) {
  final repository = ref.watch(shopRepositoryProvider);
  return repository.getShopsByAirport(airportCode);
});

final shopByIdProvider = Provider.family<Shop?, String>((ref, shopId) {
  final repository = ref.watch(shopRepositoryProvider);
  return repository.getShopById(shopId);
});

final shopCategoryFilterProvider = StateProvider<String>((ref) => 'all');

final filteredShopsProvider =
    Provider.family<List<Shop>, String>((ref, airportCode) {
  final shops = ref.watch(shopsByAirportProvider(airportCode));
  final category = ref.watch(shopCategoryFilterProvider);

  if (category == 'all') {
    return shops;
  }
  return shops.where((shop) => shop.category == category).toList();
});
