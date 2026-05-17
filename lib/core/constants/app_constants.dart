abstract final class AppConstants {
  static const String appName = 'Xbox Region Store Browser';
  static const String disclaimer =
      'This application is not affiliated with Microsoft or Xbox.';
  static const String removeAdsProductId = 'remove_ads';
  static const String removeAdsPriceLabel = 'Rp20.000';

  static const int freeSearchLimit = 3;
  static const int freeFilterLimit = 1;

  static const int defaultPageSize = 25;
  static const Duration searchDebounce = Duration(milliseconds: 400);
  static const Duration cacheTtl = Duration(hours: 1);
  static const Duration exchangeRateCacheTtl = Duration(hours: 12);

  static const String privacyPolicyPlaceholder =
      'https://example.com/privacy-policy';
}
