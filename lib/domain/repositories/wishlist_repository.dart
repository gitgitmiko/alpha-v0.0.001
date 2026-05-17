import '../entities/wishlist_item_entity.dart';

abstract class WishlistRepository {
  Future<List<WishlistItemEntity>> getAll();
  Future<bool> isInWishlist(String productId);
  Future<void> add(WishlistItemEntity item);
  Future<void> remove(String productId);
  Future<void> clear();
}
