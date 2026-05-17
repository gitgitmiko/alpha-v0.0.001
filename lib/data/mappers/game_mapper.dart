import '../../core/utils/price_utils.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/region_entity.dart';

abstract final class GameMapper {
  static List<GameEntity> fromProductList(
    Map<String, dynamic> json,
    RegionEntity region,
  ) {
    final products = json['Products'] as List<dynamic>? ?? [];
    return products
        .map((p) => fromProduct(p as Map<String, dynamic>, region))
        .whereType<GameEntity>()
        .toList();
  }

  static GameEntity? fromProduct(
    Map<String, dynamic> product,
    RegionEntity region,
  ) {
    final productId = product['ProductId'] as String?;
    if (productId == null) return null;

    final localized = (product['LocalizedProperties'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    if (localized.isEmpty) return null;

    final props = localized.first;
    final title = (props['ProductTitle'] as String?) ??
        (props['ShortTitle'] as String?) ??
        productId;

    final images = (props['Images'] as List<dynamic>?)?.cast<Map>() ?? [];
    String? imageUri;
    for (final purpose in ['Poster', 'BoxArt', 'BrandedKeyArt', 'tile']) {
      for (final img in images) {
        if (img['ImagePurpose'] == purpose) {
          imageUri = img['Uri'] as String?;
          if (imageUri != null) break;
        }
      }
      if (imageUri != null) break;
    }
    imageUri ??= images.isNotEmpty ? images.first['Uri'] as String? : null;

    final priceData = _extractPrice(product, region.market);
    if (priceData == null) return null;

    final original = priceData.msrp > priceData.listPrice
        ? priceData.msrp
        : priceData.listPrice;
    final discounted = priceData.listPrice;
    final discount =
        PriceUtils.discountPercent(original, discounted) ?? 0;

    return GameEntity(
      productId: productId,
      title: title,
      imageUrl: PriceUtils.imageUrl(imageUri),
      originalPrice: original,
      discountedPrice: discounted,
      currency: priceData.currency,
      discountPercent: discount,
      region: region.market,
    );
  }

  static List<String> productIdsFromReco(Map<String, dynamic> json) {
    final items = json['Items'] as List<dynamic>? ?? [];
    return items
        .map((i) {
          if (i is String) return i;
          if (i is Map) {
            return i['Id'] as String? ??
                i['ProductId'] as String? ??
                (i['Item'] as Map?)?['Id'] as String?;
          }
          return null;
        })
        .whereType<String>()
        .where((id) => id.length >= 10)
        .toList();
  }

  static _PriceData? _extractPrice(Map<String, dynamic> product, String market) {
    final skuAvail =
        (product['DisplaySkuAvailabilities'] as List<dynamic>?) ?? [];

    _PriceData? best;

    for (final skuEntry in skuAvail) {
      final availabilities =
          (skuEntry['Availabilities'] as List<dynamic>?) ?? [];
      for (final av in availabilities) {
        final avMap = av as Map<String, dynamic>;
        if (!_availabilityForMarket(avMap, market)) continue;

        final omd = avMap['OrderManagementData'] as Map<String, dynamic>?;
        final price = omd?['Price'] as Map<String, dynamic>?;
        if (price == null) continue;

        final listPrice = (price['ListPrice'] as num?)?.toDouble();
        if (listPrice == null) continue;

        final msrp = (price['MSRP'] as num?)?.toDouble() ?? listPrice;
        final currency = price['CurrencyCode'] as String? ?? 'USD';

        final candidate = _PriceData(
          listPrice: listPrice,
          msrp: msrp,
          currency: currency,
        );

        // Prefer purchasable Xbox offers, then any priced offer
        final actions = (avMap['Actions'] as List<dynamic>?) ?? [];
        final platforms = _allowedPlatforms(avMap);
        final isXboxPurchase = actions.contains('Purchase') &&
            platforms.any((p) => p.contains('Xbox'));
        if (isXboxPurchase) return candidate;

        best ??= candidate;
      }
    }

    return best;
  }

  static bool _availabilityForMarket(Map<String, dynamic> av, String market) {
    final markets = (av['Markets'] as List<dynamic>?)?.cast<String>() ?? [];
    if (markets.isEmpty) return true;
    return markets.contains(market) ||
        markets.contains(market.toUpperCase()) ||
        markets.contains('NEUTRAL');
  }

  static List<String> _allowedPlatforms(Map<String, dynamic> av) {
    final conditions = av['Conditions'] as Map<String, dynamic>?;
    final client = conditions?['ClientConditions'] as Map<String, dynamic>?;
    final platforms =
        (client?['AllowedPlatforms'] as List<dynamic>?) ?? [];
    return platforms
        .map((p) => (p as Map)['PlatformName'] as String? ?? '')
        .toList();
  }
}

class _PriceData {
  const _PriceData({
    required this.listPrice,
    required this.msrp,
    required this.currency,
  });

  final double listPrice;
  final double msrp;
  final String currency;
}
