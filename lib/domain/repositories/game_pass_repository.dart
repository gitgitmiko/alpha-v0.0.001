import '../../core/utils/result.dart';
import '../entities/game_pass_entity.dart';
import '../entities/region_entity.dart';

abstract class GamePassRepository {
  Future<Result<List<GamePassGameEntity>>> getCatalog({
    required RegionEntity region,
  });

  Future<Result<List<GamePassPriceEntity>>> getSubscriptionPrices({
    required RegionEntity region,
  });
}
