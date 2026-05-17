import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_boxes.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../models/wishlist_item_model.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepositoryImpl();
});

class WishlistRepositoryImpl implements WishlistRepository {
  @override
  Future<List<WishlistItemEntity>> getAll() async {
    final box = HiveBoxes.wishlistBox;
    return box.values
        .map((v) {
          if (v is WishlistItemModel) return v.toEntity();
          if (v is Map) return WishlistItemModel.fromMap(v).toEntity();
          return null;
        })
        .whereType<WishlistItemEntity>()
        .toList();
  }

  @override
  Future<bool> isInWishlist(String productId) async {
    return HiveBoxes.wishlistBox.containsKey(productId);
  }

  @override
  Future<void> add(WishlistItemEntity item) async {
    await HiveBoxes.wishlistBox.put(
      item.productId,
      WishlistItemModel.fromEntity(item),
    );
  }

  @override
  Future<void> remove(String productId) async {
    await HiveBoxes.wishlistBox.delete(productId);
  }

  @override
  Future<void> clear() async {
    await HiveBoxes.wishlistBox.clear();
  }
}
