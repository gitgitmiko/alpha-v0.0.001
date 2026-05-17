abstract final class PriceUtils {
  static double? discountPercent(double original, double discounted) {
    if (original <= 0 || discounted >= original) return null;
    return ((original - discounted) / original * 100).clamp(0, 100);
  }

  static String formatPrice(double amount, String currency) {
    if (amount == amount.roundToDouble()) {
      return '$currency ${amount.toStringAsFixed(0)}';
    }
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  static String imageUrl(String? uri) {
    if (uri == null || uri.isEmpty) return '';
    if (uri.startsWith('http')) return uri;
    return 'https:$uri';
  }
}
