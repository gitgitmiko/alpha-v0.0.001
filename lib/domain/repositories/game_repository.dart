import '../../core/utils/result.dart';
import '../entities/game_entity.dart';
import '../entities/region_entity.dart';

abstract class GameRepository {
  Future<Result<List<GameEntity>>> getDeals({
    required RegionEntity region,
    int skip = 0,
    int count = 25,
  });

  Future<Result<List<GameEntity>>> searchGames({
    required RegionEntity region,
    required String query,
    int skip = 0,
    int count = 25,
  });

  Future<Result<GameEntity>> getGameById({
    required RegionEntity region,
    required String productId,
  });

  Future<Result<List<GameEntity>>> compareRegions({
    required String productId,
    required List<String> markets,
  });
}
