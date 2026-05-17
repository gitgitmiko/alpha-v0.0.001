import 'package:hive/hive.dart';

import '../../domain/entities/wishlist_item_entity.dart';

class WishlistItemModel extends HiveObject {
  WishlistItemModel({
    required this.productId,
    required this.title,
    required this.image,
    required this.region,
    required this.price,
    required this.discountPrice,
    this.synced = false,
  });

  String productId;
  String title;
  String image;
  String region;
  double price;
  double discountPrice;
  bool synced;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'title': title,
        'image': image,
        'region': region,
        'price': price,
        'discountPrice': discountPrice,
        'synced': synced,
      };

  factory WishlistItemModel.fromMap(Map<dynamic, dynamic> map) =>
      WishlistItemModel(
        productId: map['productId'] as String,
        title: map['title'] as String,
        image: map['image'] as String,
        region: map['region'] as String,
        price: (map['price'] as num).toDouble(),
        discountPrice: (map['discountPrice'] as num).toDouble(),
        synced: map['synced'] as bool? ?? false,
      );

  WishlistItemEntity toEntity() => WishlistItemEntity(
        productId: productId,
        title: title,
        image: image,
        region: region,
        price: price,
        discountPrice: discountPrice,
        synced: synced,
      );

  static WishlistItemModel fromEntity(WishlistItemEntity e) =>
      WishlistItemModel(
        productId: e.productId,
        title: e.title,
        image: e.image,
        region: e.region,
        price: e.price,
        discountPrice: e.discountPrice,
        synced: e.synced,
      );
}

class WishlistItemModelAdapter extends TypeAdapter<WishlistItemModel> {
  @override
  final int typeId = 1;

  @override
  WishlistItemModel read(BinaryReader reader) {
    final map = Map<dynamic, dynamic>.from(reader.readMap());
    return WishlistItemModel.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, WishlistItemModel obj) {
    writer.writeMap(obj.toMap());
  }
}
