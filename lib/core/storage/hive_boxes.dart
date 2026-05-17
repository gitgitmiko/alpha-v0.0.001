import 'package:hive_flutter/hive_flutter.dart';

abstract final class HiveBoxes {
  static const String wishlist = 'wishlist';
  static const String favorites = 'favorites';
  static const String priceTrackers = 'price_trackers';
  static const String priceHistory = 'price_history';
  static const String currencyRates = 'currency_rates';
  static const String gamesCache = 'games_cache';
  static const String searchCache = 'search_cache';

  static Future<void> openAll() async {
    await Future.wait([
      Hive.openBox(wishlist),
      Hive.openBox(favorites),
      Hive.openBox(priceTrackers),
      Hive.openBox(priceHistory),
      Hive.openBox(currencyRates),
      Hive.openBox(gamesCache),
      Hive.openBox(searchCache),
    ]);
  }

  static Box get wishlistBox => Hive.box(wishlist);
  static Box get favoritesBox => Hive.box(favorites);
  static Box get priceTrackersBox => Hive.box(priceTrackers);
  static Box get priceHistoryBox => Hive.box(priceHistory);
  static Box get currencyRatesBox => Hive.box(currencyRates);
  static Box get gamesCacheBox => Hive.box(gamesCache);
  static Box get searchCacheBox => Hive.box(searchCache);
}
