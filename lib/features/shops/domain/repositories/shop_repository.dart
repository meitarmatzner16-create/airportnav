import 'package:airport_nav/features/shops/domain/entities/shop.dart';

abstract class ShopRepository {
  List<Shop> getAllShops();
  List<Shop> getShopsByAirport(String airportCode);
  List<Shop> getShopsByCategory(String airportCode, String category);
  Shop? getShopById(String id);
}
