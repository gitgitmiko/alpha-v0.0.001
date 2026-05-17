class AutosuggestHint {
  const AutosuggestHint({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.productType,
  });

  final String productId;
  final String title;
  final String imageUrl;
  final String productType;

  bool get isGame =>
      productType.toLowerCase() == 'game' ||
      productType.toLowerCase() == 'application';
}
