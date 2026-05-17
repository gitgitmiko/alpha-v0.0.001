import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_boxes.dart';
import '../../data/models/price_history_model.dart';
import '../../data/models/price_tracker_model.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/price_tracker_entity.dart';
import '../notifications/notification_service.dart';

final priceTrackerServiceProvider = Provider<PriceTrackerService>((ref) {
  return PriceTrackerService();
});

class PriceTrackerService {
  Future<List<PriceTrackerEntity>> getAll() async {
    return HiveBoxes.priceTrackersBox.values
        .map((v) {
          if (v is PriceTrackerModel) return v.toEntity();
          if (v is Map) return PriceTrackerModel.fromMap(v).toEntity();
          return null;
        })
        .whereType<PriceTrackerEntity>()
        .toList();
  }

  Future<bool> isTracking(String productId) async {
    return HiveBoxes.priceTrackersBox.containsKey(productId);
  }

  Future<void> enableTracking(GameEntity game) async {
    final model = PriceTrackerModel(
      productId: game.productId,
      title: game.title,
      previousPrice: game.discountedPrice,
      currentPrice: game.discountedPrice,
      discountPercent: game.discountPercent,
      updatedAt: DateTime.now(),
      region: game.region,
    );
    await HiveBoxes.priceTrackersBox.put(game.productId, model);
    await _appendHistory(game);
  }

  Future<void> disableTracking(String productId) async {
    await HiveBoxes.priceTrackersBox.delete(productId);
  }

  Future<void> syncGame(GameEntity game) async {
    final key = game.productId;
    if (!HiveBoxes.priceTrackersBox.containsKey(key)) return;

    final existing = HiveBoxes.priceTrackersBox.get(key);
    PriceTrackerModel tracker;
    if (existing is PriceTrackerModel) {
      tracker = existing;
    } else if (existing is Map) {
      tracker = PriceTrackerModel.fromMap(existing);
    } else {
      return;
    }

    final prev = tracker.currentPrice;
    final curr = game.discountedPrice;
    final prevDiscount = tracker.discountPercent;
    final currDiscount = game.discountPercent;

    final priceDrop = curr < prev;
    final newDiscount = currDiscount > prevDiscount;
    final discountIncrease = currDiscount > prevDiscount && currDiscount > 0;

    tracker.previousPrice = prev;
    tracker.currentPrice = curr;
    tracker.discountPercent = currDiscount;
    tracker.updatedAt = DateTime.now();
    await HiveBoxes.priceTrackersBox.put(key, tracker);
    await _appendHistory(game);

    if (priceDrop || newDiscount || discountIncrease) {
      await NotificationService.instance.notifyPriceDrop(
        gameTitle: game.title,
        discountPercent: currDiscount > 0 ? currDiscount : ((prev - curr) / prev * 100),
      );
    }
  }

  Future<List<PriceHistoryEntity>> getHistory(String productId) async {
    final prefix = '${productId}_';
    return HiveBoxes.priceHistoryBox.keys
        .whereType<String>()
        .where((k) => k.startsWith(prefix))
        .map((k) => HiveBoxes.priceHistoryBox.get(k))
        .whereType<Map>()
        .map((m) => PriceHistoryModel.fromMap(m).toEntity())
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  PriceHistoryStats statsFor(List<PriceHistoryEntity> history) {
    if (history.isEmpty) {
      return const PriceHistoryStats(
        lowestPrice: 0,
        highestDiscount: 0,
        lastUpdated: null,
      );
    }
    final lowest = history.map((h) => h.price).reduce((a, b) => a < b ? a : b);
    final maxDiscount =
        history.map((h) => h.discount).reduce((a, b) => a > b ? a : b);
    return PriceHistoryStats(
      lowestPrice: lowest,
      highestDiscount: maxDiscount,
      lastUpdated: history.first.timestamp,
    );
  }

  Future<void> _appendHistory(GameEntity game) async {
    final key =
        '${game.productId}_${DateTime.now().millisecondsSinceEpoch}';
    final entry = PriceHistoryModel(
      productId: game.productId,
      price: game.discountedPrice,
      discount: game.discountPercent,
      timestamp: DateTime.now(),
    );
    await HiveBoxes.priceHistoryBox.put(key, entry.toMap());
  }
}

class PriceHistoryStats {
  const PriceHistoryStats({
    required this.lowestPrice,
    required this.highestDiscount,
    required this.lastUpdated,
  });

  final double lowestPrice;
  final double highestDiscount;
  final DateTime? lastUpdated;
}
