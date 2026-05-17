import 'dart:convert';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/hive_boxes.dart';

class GamesCacheDataSource {
  static const _cacheVersion = 'v2';

  String _key(String market, String type, int skip) =>
      '${_cacheVersion}_${market}_${type}_$skip';

  Future<List<Map<String, dynamic>>?> get(
    String market,
    String type,
    int skip,
  ) async {
    final raw = HiveBoxes.gamesCacheBox.get(_key(market, type, skip));
    if (raw == null) return null;
    final entry = raw as Map;
    final cachedAt = DateTime.tryParse(entry['cachedAt'] as String? ?? '');
    if (cachedAt == null ||
        DateTime.now().difference(cachedAt) > AppConstants.cacheTtl) {
      return null;
    }
    final list = jsonDecode(entry['data'] as String) as List<dynamic>;
    final games = list.cast<Map<String, dynamic>>();
    if (games.isEmpty) return null;
    return games;
  }

  Future<void> put(
    String market,
    String type,
    int skip,
    List<Map<String, dynamic>> games,
  ) async {
    if (games.isEmpty) return;
    await HiveBoxes.gamesCacheBox.put(
      _key(market, type, skip),
      {
        'cachedAt': DateTime.now().toIso8601String(),
        'data': jsonEncode(games),
      },
    );
  }

  Future<void> clearAll() async {
    await HiveBoxes.gamesCacheBox.clear();
  }
}
