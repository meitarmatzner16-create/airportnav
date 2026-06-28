import 'package:airport_nav/features/shops/data/datasources/shop_mock_datasource.dart';
import 'package:airport_nav/features/shops/domain/entities/shop.dart';
import 'package:airport_nav/features/shops/domain/repositories/shop_repository.dart';

class ShopRepositoryImpl implements ShopRepository {
  final List<Shop> _shops = ShopMockDatasource.shops;

  @override
  List<Shop> getAllShops() {
    return List.unmodifiable(_shops);
  }

  @override
  List<Shop> getShopsByAirport(String airportCode) {
    return _shops
        .where((shop) => shop.airportCode == airportCode)
        .toList();
  }

  @override
  List<Shop> getShopsByCategory(String airportCode, String category) {
    return _shops
        .where((shop) =>
            shop.airportCode == airportCode && shop.category == category)
        .toList();
  }

  @override
  Shop? getShopById(String id) {
    try {
      return _shops.firstWhere((shop) => shop.id == id);
    } catch (_) {
      return null;
    }
  }
}
