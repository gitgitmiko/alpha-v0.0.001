import 'package:hive/hive.dart';

class FavoriteItemModel extends HiveObject {
  FavoriteItemModel({
    required this.productId,
    required this.title,
    required this.image,
    required this.region,
  });

  String productId;
  String title;
  String image;
  String region;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'title': title,
        'image': image,
        'region': region,
      };

  factory FavoriteItemModel.fromMap(Map<dynamic, dynamic> map) =>
      FavoriteItemModel(
        productId: map['productId'] as String,
        title: map['title'] as String,
        image: map['image'] as String,
        region: map['region'] as String,
      );
}

class FavoriteItemModelAdapter extends TypeAdapter<FavoriteItemModel> {
  @override
  final int typeId = 2;

  @override
  FavoriteItemModel read(BinaryReader reader) =>
      FavoriteItemModel.fromMap(Map<dynamic, dynamic>.from(reader.readMap()));

  @override
  void write(BinaryWriter writer, FavoriteItemModel obj) {
    writer.writeMap(obj.toMap());
  }
}
