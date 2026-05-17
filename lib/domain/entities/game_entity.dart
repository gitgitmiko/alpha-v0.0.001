import 'package:equatable/equatable.dart';

enum GameSortFilter {
  lowestPrice,
  highestPrice,
  highestDiscount,
  lowestDiscount,
}

class GameEntity extends Equatable {
  const GameEntity({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.originalPrice,
    required this.discountedPrice,
    required this.currency,
    required this.discountPercent,
    required this.region,
    this.isOnGamePass = false,
  });

  final String productId;
  final String title;
  final String imageUrl;
  final double originalPrice;
  final double discountedPrice;
  final String currency;
  final double discountPercent;
  final String region;
  final bool isOnGamePass;

  bool get hasDiscount => discountPercent > 0;

  @override
  List<Object?> get props => [
        productId,
        title,
        imageUrl,
        originalPrice,
        discountedPrice,
        currency,
        discountPercent,
        region,
        isOnGamePass,
      ];
}
