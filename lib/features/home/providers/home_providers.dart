import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/utils/result.dart';
import '../../../data/datasources/local/games_cache_datasource.dart';
import '../../../data/repositories/favorites_repository_impl.dart';
import '../../../data/repositories/game_repository_impl.dart';
import '../../../data/repositories/wishlist_repository_impl.dart';
import '../../../domain/entities/game_entity.dart';
import '../../../services/ads/ad_service.dart';
import '../../settings/providers/settings_providers.dart';

final homeGamesProvider =
    AsyncNotifierProvider<HomeGamesNotifier, List<GameEntity>>(HomeGamesNotifier.new);

class HomeGamesNotifier extends AsyncNotifier<List<GameEntity>> {
  GameSortFilter _sort = GameSortFilter.highestDiscount;
  String _query = '';
  int _skip = 0;
  bool _hasMore = true;
  bool _favoriteOnly = false;
  Timer? _debounce;

  @override
  Future<List<GameEntity>> build() async {
    ref.listen(regionProvider, (_, __) {
      _skip = 0;
      ref.invalidateSelf();
    });
    return _load(refresh: true);
  }

  GameSortFilter get sort => _sort;

  Future<void> refresh() async {
    _skip = 0;
    _hasMore = true;
    await GamesCacheDataSource().clearAll();
    state = const AsyncLoading();
    try {
      state = AsyncData(await _load(refresh: true));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;
    _skip += AppConstants.defaultPageSize;
    try {
      final more = await _load(refresh: false);
      state = AsyncData([...?state.value, ...more]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> setSort(GameSortFilter sort) async {
    _sort = sort;
    await ref.read(adServiceProvider).onFilter(onAdShown: () {});
    await refresh();
  }

  void search(String query) {
    _debounce?.cancel();
    _debounce = Timer(AppConstants.searchDebounce, () async {
      _query = query.trim();
      if (_query.isNotEmpty) {
        await ref.read(adServiceProvider).onSearch(onAdShown: () {});
        await ref.read(localStorageProvider).addRecentSearch(_query);
      }
      _skip = 0;
      state = const AsyncLoading();
      try {
        state = AsyncData(await _load(refresh: true));
      } catch (e, st) {
        state = AsyncError(e, st);
      }
    });
  }

  Future<void> setFavoriteOnly(bool value) async {
    _favoriteOnly = value;
    await refresh();
  }

  Future<List<GameEntity>> _load({required bool refresh}) async {
    final region = ref.read(regionProvider);
    final repo = ref.read(gameRepositoryProvider);

    final Result<List<GameEntity>> result;
    if (_query.isNotEmpty) {
      result = await repo.searchGames(
        region: region,
        query: _query,
        skip: _skip,
      );
    } else {
      result = await repo.getDeals(region: region, skip: _skip);
    }

    return result.when(
      success: (games) {
        _hasMore = games.length >= AppConstants.defaultPageSize;
        var list = [...games];
        switch (_sort) {
          case GameSortFilter.lowestPrice:
            list.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
          case GameSortFilter.highestPrice:
            list.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
          case GameSortFilter.highestDiscount:
            list.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
          case GameSortFilter.lowestDiscount:
            list.sort((a, b) => a.discountPercent.compareTo(b.discountPercent));
        }
        if (_favoriteOnly) {
          final favs = ref.read(favoriteIdsProvider).value ?? {};
          list = list.where((g) => favs.contains(g.productId)).toList();
        }
        return list;
      },
      error: (f) => throw StateError(f.message),
    );
  }
}

final favoriteIdsProvider =
    AsyncNotifierProvider<FavoriteIdsNotifier, Set<String>>(FavoriteIdsNotifier.new);

class FavoriteIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    return ref.read(favoritesRepositoryProvider).getIds();
  }

  Future<void> toggle(GameEntity game) async {
    await ref.read(favoritesRepositoryProvider).toggle(game);
    state = AsyncData(await ref.read(favoritesRepositoryProvider).getIds());
  }

  bool contains(String id) => state.value?.contains(id) ?? false;
}

final wishlistIdsProvider =
    AsyncNotifierProvider<WishlistIdsNotifier, Set<String>>(WishlistIdsNotifier.new);

class WishlistIdsNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final items = await ref.read(wishlistRepositoryProvider).getAll();
    return items.map((e) => e.productId).toSet();
  }
}
