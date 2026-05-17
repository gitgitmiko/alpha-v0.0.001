import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/bootstrap/app_bootstrap.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/local_storage_service.dart';

final billingServiceProvider = Provider<BillingService>((ref) {
  return BillingService(ref.watch(localStorageProvider));
});

class BillingService {
  BillingService(this._storage);

  final LocalStorageService _storage;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  static const String removeAdsId = AppConstants.removeAdsProductId;

  Future<void> init() async {
    _sub = _iap.purchaseStream.listen(_onPurchaseUpdate);
  }

  Future<bool> isAvailable() async {
    if (!AppBootstrap.supportsMobileAds) return false;
    return _iap.isAvailable();
  }

  Future<void> buyRemoveAds() async {
    if (!AppBootstrap.supportsMobileAds) return;
    final available = await isAvailable();
    if (!available) return;

    const ids = {removeAdsId};
    final response = await _iap.queryProductDetails(ids);
    if (response.productDetails.isEmpty) return;

    final product = response.productDetails.first;
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
    );
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID == removeAdsId &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        await _storage.setRemoveAdsPurchased(true);
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    }
  }

  void dispose() => _sub?.cancel();
}
