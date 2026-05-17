import 'package:dio/dio.dart';

import '../../../domain/entities/wishlist_item_entity.dart';

class BackendApi {
  BackendApi(this._dio);

  final Dio _dio;

  Future<void> syncWishlist(WishlistItemEntity item) async {
    await _dio.post('/wishlist', data: {
      'productId': item.productId,
      'title': item.title,
      'image': item.image,
      'region': item.region,
      'price': item.price,
      'discountPrice': item.discountPrice,
    });
  }

  Future<void> syncFavorite(Map<String, dynamic> data) async {
    await _dio.post('/favorites', data: data);
  }

  Future<Map<String, dynamic>> getPriceHistory(String productId) async {
    final r = await _dio.get<Map<String, dynamic>>('/history/$productId');
    return r.data ?? {};
  }

  Future<List<Map<String, dynamic>>> comparePrice(String productId) async {
    final r = await _dio.get<Map<String, dynamic>>('/compare/$productId');
    final list = r.data?['regions'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }
}
