import 'package:hive/hive.dart';

import '../../domain/entities/price_tracker_entity.dart';

class PriceTrackerModel extends HiveObject {
  PriceTrackerModel({
    required this.productId,
    required this.title,
    required this.previousPrice,
    required this.currentPrice,
    required this.discountPercent,
    required this.updatedAt,
    required this.region,
  });

  String productId;
  String title;
  double previousPrice;
  double currentPrice;
  double discountPercent;
  DateTime updatedAt;
  String region;

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'title': title,
        'previousPrice': previousPrice,
        'currentPrice': currentPrice,
        'discountPercent': discountPercent,
        'updatedAt': updatedAt.toIso8601String(),
        'region': region,
      };

  factory PriceTrackerModel.fromMap(Map<dynamic, dynamic> map) =>
      PriceTrackerModel(
        productId: map['productId'] as String,
        title: map['title'] as String,
        previousPrice: (map['previousPrice'] as num).toDouble(),
        currentPrice: (map['currentPrice'] as num).toDouble(),
        discountPercent: (map['discountPercent'] as num).toDouble(),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
        region: map['region'] as String,
      );

  PriceTrackerEntity toEntity() => PriceTrackerEntity(
        productId: productId,
        title: title,
        previousPrice: previousPrice,
        currentPrice: currentPrice,
        discountPercent: discountPercent,
        updatedAt: updatedAt,
        region: region,
      );
}

class PriceTrackerModelAdapter extends TypeAdapter<PriceTrackerModel> {
  @override
  final int typeId = 3;

  @override
  PriceTrackerModel read(BinaryReader reader) =>
      PriceTrackerModel.fromMap(Map<dynamic, dynamic>.from(reader.readMap()));

  @override
  void write(BinaryWriter writer, PriceTrackerModel obj) {
    writer.writeMap(obj.toMap());
  }
}
