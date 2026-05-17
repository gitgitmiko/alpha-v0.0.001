import 'package:hive/hive.dart';

import '../../domain/entities/price_tracker_entity.dart';

class PriceHistoryModel extends HiveObject {
  PriceHistoryModel({
    required this.productId,
    required this.price,
    required this.discount,
    required this.timestamp,
  });

  String productId;
  double price;
  double discount;
  DateTime timestamp;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'price': price,
        'discount': discount,
        'timestamp': timestamp.toIso8601String(),
      };

  factory PriceHistoryModel.fromMap(Map<dynamic, dynamic> map) =>
      PriceHistoryModel(
        productId: map['productId'] as String,
        price: (map['price'] as num).toDouble(),
        discount: (map['discount'] as num).toDouble(),
        timestamp: DateTime.parse(map['timestamp'] as String),
      );

  PriceHistoryEntity toEntity() => PriceHistoryEntity(
        productId: productId,
        price: price,
        discount: discount,
        timestamp: timestamp,
      );
}

class PriceHistoryModelAdapter extends TypeAdapter<PriceHistoryModel> {
  @override
  final int typeId = 4;

  @override
  PriceHistoryModel read(BinaryReader reader) =>
      PriceHistoryModel.fromMap(Map<dynamic, dynamic>.from(reader.readMap()));

  @override
  void write(BinaryWriter writer, PriceHistoryModel obj) {
    writer.writeMap(obj.toMap());
  }
}
