import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/currency_rate_model.dart';
import '../../data/models/favorite_item_model.dart';
import '../../data/models/price_history_model.dart';
import '../../data/models/price_tracker_model.dart';
import '../../data/models/wishlist_item_model.dart';
import '../../services/notifications/notification_service.dart';
import '../../services/price_tracker/price_sync_worker.dart';
import '../storage/hive_boxes.dart';
import '../storage/local_storage_service.dart';

/// Platform-aware startup (Android vs Web/desktop).
abstract final class AppBootstrap {
  static bool get supportsMobileAds =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get supportsBackgroundSync =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> loadEnvironment() async {
    try {
      await dotenv.load(fileName: '.env.example');
    } catch (_) {
      dotenv.testLoad(
        fileInput: 'USE_BACKEND=false\n'
            'BACKEND_BASE_URL=http://10.0.2.2:3000\n'
            'EXCHANGE_RATE_API=https://api.exchangerate.host/latest\n',
      );
    }
    // Optional local overrides (add `.env` to pubspec assets if you use it)
    try {
      await dotenv.load(fileName: '.env', mergeWith: dotenv.env);
    } catch (_) {
      // .env not bundled — .env.example is enough for dev
    }
  }

  static Future<void> initStorage() async {
    await Hive.initFlutter();
    Hive.registerAdapter(WishlistItemModelAdapter());
    Hive.registerAdapter(FavoriteItemModelAdapter());
    Hive.registerAdapter(PriceTrackerModelAdapter());
    Hive.registerAdapter(PriceHistoryModelAdapter());
    Hive.registerAdapter(CurrencyRateModelAdapter());
    await HiveBoxes.openAll();
  }

  static Future<LocalStorageService> initLocalStorage() async {
    final storage = LocalStorageService();
    await storage.init();
    return storage;
  }

  static Future<void> initFirebaseAndNotifications() async {
    if (kIsWeb) return;
    try {
      await Firebase.initializeApp();
      await NotificationService.instance.init();
    } catch (_) {
      // Optional without google-services.json
    }
  }

  static Future<void> initMobileServices() async {
    if (supportsMobileAds) {
      try {
        await MobileAds.instance.initialize();
      } catch (_) {}
    }
    if (supportsBackgroundSync) {
      try {
        await PriceSyncWorker.register();
      } catch (_) {}
    }
  }
}
