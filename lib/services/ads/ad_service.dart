import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/bootstrap/app_bootstrap.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/local_storage_service.dart';
final adServiceProvider = Provider<AdService>((ref) {
  return AdService(ref.watch(localStorageProvider));
});

class AdService {
  AdService(this._storage);

  final LocalStorageService _storage;
  InterstitialAd? _interstitialAd;
  bool _loading = false;

  bool get adsDisabled =>
      !AppBootstrap.supportsMobileAds || _storage.removeAdsPurchased;

  String get interstitialUnitId =>
      dotenv.env['ADMOB_INTERSTITIAL_ID'] ??
      'ca-app-pub-3940256099942544/1033173712';

  Future<void> loadInterstitial() async {
    if (adsDisabled || _loading) return;
    _loading = true;
    await InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (_) => _loading = false,
      ),
    );
  }

  Future<bool> onSearch({required void Function() onAdShown}) async {
    if (adsDisabled) return false;
    var count = _storage.searchAdCount;
    count++;
    await _storage.setSearchAdCount(count);
    if (count >= AppConstants.freeSearchLimit) {
      await showInterstitial(onShown: () async {
        await _storage.setSearchAdCount(0);
        onAdShown();
      });
      return true;
    }
    return false;
  }

  Future<bool> onFilter({required void Function() onAdShown}) async {
    if (adsDisabled) return false;
    var count = _storage.filterAdCount;
    count++;
    await _storage.setFilterAdCount(count);
    if (count > AppConstants.freeFilterLimit) {
      await showInterstitial(onShown: () async {
        await _storage.setFilterAdCount(0);
        onAdShown();
      });
      return true;
    }
    return false;
  }

  Future<void> showInterstitial({VoidCallback? onShown}) async {
    if (adsDisabled) return;
    final ad = _interstitialAd;
    if (ad != null) {
      ad.show();
      onShown?.call();
    } else {
      await loadInterstitial();
    }
  }
}

typedef VoidCallback = void Function();
