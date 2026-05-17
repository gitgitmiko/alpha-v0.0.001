import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/regions.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('Override in main()');
});

class LocalStorageService {
  static const _regionKey = 'selected_region_market';
  static const _localeKey = 'selected_region_locale';
  static const _themeKey = 'theme_mode';
  static const _removeAdsKey = 'remove_ads_purchased';
  static const _searchCountKey = 'ad_search_count';
  static const _filterCountKey = 'ad_filter_count';
  static const _targetCurrencyKey = 'target_currency';
  static const _recentSearchesKey = 'recent_searches';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    final p = _prefs;
    if (p == null) throw StateError('LocalStorageService not initialized');
    return p;
  }

  String get regionMarket =>
      prefs.getString(_regionKey) ?? AppRegions.defaultRegion.market;

  String get regionLocale =>
      prefs.getString(_localeKey) ?? AppRegions.defaultRegion.locale;

  Future<void> saveRegion(String market, String locale) async {
    await prefs.setString(_regionKey, market);
    await prefs.setString(_localeKey, locale);
  }

  String get themeMode => prefs.getString(_themeKey) ?? 'system';

  Future<void> saveThemeMode(String mode) async {
    await prefs.setString(_themeKey, mode);
  }

  bool get removeAdsPurchased => prefs.getBool(_removeAdsKey) ?? false;

  Future<void> setRemoveAdsPurchased(bool value) async {
    await prefs.setBool(_removeAdsKey, value);
  }

  int get searchAdCount => prefs.getInt(_searchCountKey) ?? 0;

  Future<void> setSearchAdCount(int count) async {
    await prefs.setInt(_searchCountKey, count);
  }

  int get filterAdCount => prefs.getInt(_filterCountKey) ?? 0;

  Future<void> setFilterAdCount(int count) async {
    await prefs.setInt(_filterCountKey, count);
  }

  String get targetCurrency => prefs.getString(_targetCurrencyKey) ?? 'IDR';

  Future<void> setTargetCurrency(String code) async {
    await prefs.setString(_targetCurrencyKey, code);
  }

  List<String> get recentSearches =>
      prefs.getStringList(_recentSearchesKey) ?? [];

  Future<void> addRecentSearch(String query) async {
    final list = recentSearches.where((s) => s != query).toList();
    list.insert(0, query);
    await prefs.setStringList(
      _recentSearchesKey,
      list.take(10).toList(),
    );
  }
}
