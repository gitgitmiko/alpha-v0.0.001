import '../../domain/entities/region_entity.dart';

abstract final class AppRegions {
  static const RegionEntity defaultRegion = RegionEntity(
    market: 'ID',
    locale: 'id-ID',
    language: 'id-ID',
    name: 'Indonesia',
    currencyCode: 'IDR',
    flagEmoji: '🇮🇩',
  );

  static const List<RegionEntity> supported = [
    defaultRegion,
    RegionEntity(
      market: 'TR',
      locale: 'tr-TR',
      language: 'tr-TR',
      name: 'Turkey',
      currencyCode: 'TRY',
      flagEmoji: '🇹🇷',
    ),
    RegionEntity(
      market: 'AR',
      locale: 'es-AR',
      language: 'es-AR',
      name: 'Argentina',
      currencyCode: 'ARS',
      flagEmoji: '🇦🇷',
    ),
    RegionEntity(
      market: 'US',
      locale: 'en-US',
      language: 'en-US',
      name: 'United States',
      currencyCode: 'USD',
      flagEmoji: '🇺🇸',
    ),
    RegionEntity(
      market: 'BR',
      locale: 'pt-BR',
      language: 'pt-BR',
      name: 'Brazil',
      currencyCode: 'BRL',
      flagEmoji: '🇧🇷',
    ),
  ];

  static const List<String> compareMarkets = ['ID', 'TR', 'AR', 'US', 'BR'];

  static RegionEntity byMarket(String market) {
    return supported.firstWhere(
      (r) => r.market.toUpperCase() == market.toUpperCase(),
      orElse: () => defaultRegion,
    );
  }
}
