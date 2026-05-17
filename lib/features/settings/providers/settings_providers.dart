import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/regions.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../domain/entities/region_entity.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.watch(localStorageProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._storage) : super(_loadMode(_storage));

  final LocalStorageService _storage;

  static ThemeMode _loadMode(LocalStorageService s) {
    return switch (s.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final key = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _storage.saveThemeMode(key);
  }
}

final regionProvider =
    StateNotifierProvider<RegionNotifier, RegionEntity>((ref) {
  return RegionNotifier(ref.watch(localStorageProvider));
});

class RegionNotifier extends StateNotifier<RegionEntity> {
  RegionNotifier(this._storage)
      : super(AppRegions.byMarket(_storage.regionMarket));

  final LocalStorageService _storage;

  Future<void> setRegion(RegionEntity region) async {
    state = region;
    await _storage.saveRegion(region.market, region.locale);
  }
}

final removeAdsProvider = Provider<bool>((ref) {
  return ref.watch(localStorageProvider).removeAdsPurchased;
});
