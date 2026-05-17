import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/errors/failure.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/game_pass_entity.dart';
import '../../domain/entities/region_entity.dart';
import '../../domain/repositories/game_pass_repository.dart';
import '../datasources/remote/microsoft_store_api.dart';
import '../mappers/game_mapper.dart';

final gamePassRepositoryProvider = Provider<GamePassRepository>((ref) {
  return GamePassRepositoryImpl(MicrosoftStoreApi(ref.watch(dioProvider)));
});

class GamePassRepositoryImpl implements GamePassRepository {
  GamePassRepositoryImpl(this._api);

  final MicrosoftStoreApi _api;

  static const _subscriptionNames = {
    GamePassSkuIds.pcGamePass: 'PC Game Pass',
    GamePassSkuIds.gamePassCore: 'Game Pass Core',
    GamePassSkuIds.gamePassStandard: 'Game Pass Standard',
    GamePassSkuIds.gamePassUltimate: 'Game Pass Ultimate',
  };

  @override
  Future<Result<List<GamePassGameEntity>>> getCatalog({
    required RegionEntity region,
  }) async {
    try {
      final games = await _api.fetchStoreGames(region: region, count: 40);
      if (games.isEmpty) {
        return ErrorResult(
          Failure(
            message:
                'Katalog Game Pass kosong untuk ${region.name}. Coba ganti region.',
          ),
        );
      }

      return Success(
        games
            .map(
              (g) => GamePassGameEntity(
                productId: g.productId,
                title: g.title,
                imageUrl: g.imageUrl,
                region: g.region,
              ),
            )
            .toList(),
      );
    } on DioException catch (e) {
      return ErrorResult(Failure(message: e.message ?? 'Game Pass error'));
    } catch (e) {
      return ErrorResult(Failure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<GamePassPriceEntity>>> getSubscriptionPrices({
    required RegionEntity region,
  }) async {
    try {
      final skuIds = _subscriptionNames.keys.toList();
      final products = await _api.fetchProducts(
        region: region,
        productIds: skuIds,
      );
      final games = GameMapper.fromProductList(products, region);
      final prices = <GamePassPriceEntity>[];

      for (final entry in _subscriptionNames.entries) {
        final match = games.where((g) => g.productId == entry.key).firstOrNull;
        prices.add(
          GamePassPriceEntity(
            skuId: entry.key,
            name: entry.value,
            price: match?.discountedPrice ?? match?.originalPrice ?? 0,
            currency: match?.currency ?? region.currencyCode,
            region: region.market,
          ),
        );
      }

      return Success(prices);
    } catch (e) {
      return ErrorResult(Failure(message: e.toString()));
    }
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
