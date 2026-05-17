import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/regions.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/failure.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/region_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/local/games_cache_datasource.dart';
import '../datasources/remote/microsoft_store_api.dart';
import '../mappers/game_mapper.dart';

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(
    MicrosoftStoreApi(ref.watch(dioProvider)),
    GamesCacheDataSource(),
  );
});

class GameRepositoryImpl implements GameRepository {
  GameRepositoryImpl(this._api, this._cache);

  final MicrosoftStoreApi _api;
  final GamesCacheDataSource _cache;

  @override
  Future<Result<List<GameEntity>>> getDeals({
    required RegionEntity region,
    int skip = 0,
    int count = 25,
  }) async {
    try {
      final cached = await _cache.get(region.market, 'deal', skip);
      if (cached != null) {
        return Success(
          cached
              .map((m) => GameEntity(
                    productId: m['productId'] as String,
                    title: m['title'] as String,
                    imageUrl: m['imageUrl'] as String,
                    originalPrice: (m['originalPrice'] as num).toDouble(),
                    discountedPrice: (m['discountedPrice'] as num).toDouble(),
                    currency: m['currency'] as String,
                    discountPercent: (m['discountPercent'] as num).toDouble(),
                    region: m['region'] as String,
                  ))
              .toList(),
        );
      }

      final games = await _api.fetchStoreGames(
        region: region,
        skip: skip,
        count: count,
      );

      if (games.isEmpty) {
        return ErrorResult(
          Failure(
            message:
                'Tidak dapat memuat katalog untuk ${region.name}. Periksa koneksi internet emulator.',
          ),
        );
      }

      await _cache.put(
        region.market,
        'deal',
        skip,
        games
            .map((g) => {
                  'productId': g.productId,
                  'title': g.title,
                  'imageUrl': g.imageUrl,
                  'originalPrice': g.originalPrice,
                  'discountedPrice': g.discountedPrice,
                  'currency': g.currency,
                  'discountPercent': g.discountPercent,
                  'region': g.region,
                })
            .toList(),
      );

      return Success(games);
    } on DioException catch (e) {
      return ErrorResult(
        Failure.fromException(
          NetworkException(
            e.message ?? 'Kesalahan jaringan (${e.type})',
            code: '${e.response?.statusCode}',
          ),
        ),
      );
    } catch (e) {
      return ErrorResult(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<GameEntity>>> searchGames({
    required RegionEntity region,
    required String query,
    int skip = 0,
    int count = 25,
  }) async {
    try {
      final games = await _api.fetchStoreGames(
        region: region,
        skip: skip,
        count: count,
        searchQuery: query,
      );
      return Success(games);
    } on DioException catch (e) {
      return ErrorResult(
        Failure.fromException(
          NetworkException(e.message ?? 'Pencarian gagal'),
        ),
      );
    } catch (e) {
      return ErrorResult(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<GameEntity>> getGameById({
    required RegionEntity region,
    required String productId,
  }) async {
    try {
      final products = await _api.fetchProducts(
        region: region,
        productIds: [productId],
      );
      final games = GameMapper.fromProductList(products, region);
      if (games.isEmpty) {
        return ErrorResult(
          Failure.fromException(const NotFoundException('Game not found')),
        );
      }
      return Success(games.first);
    } catch (e) {
      return ErrorResult(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<GameEntity>>> compareRegions({
    required String productId,
    required List<String> markets,
  }) async {
    try {
      final results = <GameEntity>[];
      for (final market in markets) {
        final region = AppRegions.byMarket(market);
        final r = await getGameById(region: region, productId: productId);
        if (r is Success<GameEntity>) results.add(r.data);
      }
      return Success(results);
    } catch (e) {
      return ErrorResult(Failure(message: e.toString()));
    }
  }
}
