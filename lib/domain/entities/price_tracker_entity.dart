import 'package:equatable/equatable.dart';

class PriceTrackerEntity extends Equatable {
  const PriceTrackerEntity({
    required this.productId,
    required this.title,
    required this.previousPrice,
    required this.currentPrice,
    required this.discountPercent,
    required this.updatedAt,
    required this.region,
  });

  final String productId;
  final String title;
  final double previousPrice;
  final double currentPrice;
  final double discountPercent;
  final DateTime updatedAt;
  final String region;

  bool get hasPriceDrop => currentPrice < previousPrice;
  bool get hasNewDiscount => discountPercent > 0;

  @override
  List<Object?> get props => [
        productId,
        title,
        previousPrice,
        currentPrice,
        discountPercent,
        updatedAt,
        region,
      ];
}

class PriceHistoryEntity extends Equatable {
  const PriceHistoryEntity({
    required this.productId,
    required this.price,
    required this.discount,
    required this.timestamp,
  });

  final String productId;
  final double price;
  final double discount;
  final DateTime timestamp;

  @override
  List<Object?> get props => [productId, price, discount, timestamp];
}

class RegionPriceEntity extends Equatable {
  const RegionPriceEntity({
    required this.region,
    required this.regionName,
    required this.price,
    required this.currency,
    required this.discountPercent,
  });

  final String region;
  final String regionName;
  final double price;
  final String currency;
  final double discountPercent;

  @override
  List<Object?> get props =>
      [region, regionName, price, currency, discountPercent];
}
