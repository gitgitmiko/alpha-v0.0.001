import 'package:equatable/equatable.dart';

class GamePassGameEntity extends Equatable {
  const GamePassGameEntity({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.region,
  });

  final String productId;
  final String title;
  final String imageUrl;
  final String region;

  @override
  List<Object?> get props => [productId, title, imageUrl, region];
}

class GamePassPriceEntity extends Equatable {
  const GamePassPriceEntity({
    required this.skuId,
    required this.name,
    required this.price,
    required this.currency,
    required this.region,
  });

  final String skuId;
  final String name;
  final double price;
  final String currency;
  final String region;

  @override
  List<Object?> get props => [skuId, name, price, currency, region];
}
