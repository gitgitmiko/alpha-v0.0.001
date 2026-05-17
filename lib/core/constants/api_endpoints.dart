/// Microsoft Xbox / Store API endpoints (configurable, not hardcoded in services).
abstract final class ApiEndpoints {
  static const String displayCatalogBase =
      'https://displaycatalog.mp.microsoft.com';
  static const String recoBase = 'https://reco-public.rec.mp.microsoft.com';
  static const String gamePassCatalogBase = 'https://catalog.gamepass.com';
  static const String exchangeRateBase = 'https://api.exchangerate.host';
  static const String msStoreAutosuggest =
      'https://www.microsoft.com/msstoreapiprod/api/autosuggest';

  // Display Catalog v7
  static const String products = '/v7.0/products';
  static const String productFamilies = '/v7.0/productFamilies';

  // Reco lists v8 (see xbox-store-api: .../Lists/Computed/Deal)
  static const String recoListBase = '/channels/Reco/V8.0/Lists';

  // Game Pass SIGL lists (IDs from catalog.gamepass.com)
  static const String gamePassAllSigl =
      '/sigls/v2?id=9ea872a6-2f94-4ea6-b2e3-ff9530b8f35f';
}

/// Reco list channel paths
abstract final class RecoListPaths {
  static const String deal = 'Computed/Deal';
  static const String newGames = 'Computed/New';
  static const String topPaid = 'Computed/TopPaid';
  static const String topFree = 'Computed/TopFree';
  static const String bestRated = 'Computed/BestRated';
  static const String mostPlayed = 'Computed/MostPlayed';
  static const String comingSoon = 'Computed/ComingSoon';
  static const String gold = 'collection/FreePlayDays';
}

/// Game Pass subscription product IDs (Display Catalog bigIds)
abstract final class GamePassSkuIds {
  static const String pcGamePass = 'CFQ7TTC0KGQ8';
  static const String gamePassCore = 'CFQ7TTC0K5DJ';
  static const String gamePassStandard = 'CFQ7TTC0P85B';
  static const String gamePassUltimate = 'CFQ7TTC0KHS0';
}
