import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_boxes.dart';
import '../../domain/entities/game_entity.dart';
import '../models/favorite_item_model.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository();
});

class FavoritesRepository {
  Future<Set<String>> getIds() async {
    return HiveBoxes.favoritesBox.keys.cast<String>().toSet();
  }

  Future<bool> isFavorite(String productId) async {
    return HiveBoxes.favoritesBox.containsKey(productId);
  }

  Future<void> toggle(GameEntity game) async {
    if (await isFavorite(game.productId)) {
      await HiveBoxes.favoritesBox.delete(game.productId);
    } else {
      await HiveBoxes.favoritesBox.put(
        game.productId,
        FavoriteItemModel(
          productId: game.productId,
          title: game.title,
          image: game.imageUrl,
          region: game.region,
        ),
      );
    }
  }
}
