import 'package:equatable/equatable.dart';

class WishlistItemEntity extends Equatable {
  const WishlistItemEntity({
    required this.productId,
    required this.title,
    required this.image,
    required this.region,
    required this.price,
    required this.discountPrice,
    this.synced = false,
  });

  final String productId;
  final String title;
  final String image;
  final String region;
  final double price;
  final double discountPrice;
  final bool synced;

  @override
  List<Object?> get props =>
      [productId, title, image, region, price, discountPrice, synced];
}
