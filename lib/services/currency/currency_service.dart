import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/hive_boxes.dart';
import '../../data/models/currency_rate_model.dart';

final currencyServiceProvider = Provider<CurrencyService>((ref) {
  return CurrencyService(ref.watch(dioProvider));
});

class CurrencyService {
  CurrencyService(this._dio);

  final Dio _dio;

  Future<double> convert({
    required double amount,
    required String from,
    required String to,
  }) async {
    if (from == to) return amount;
    final rate = await getRate(from: from, to: to);
    return amount * rate;
  }

  Future<double> getRate({required String from, required String to}) async {
    final cacheKey = '${from}_$to';
    final cached = HiveBoxes.currencyRatesBox.get(cacheKey);
    if (cached is Map) {
      final model = CurrencyRateModel.fromMap(cached);
      if (DateTime.now().difference(model.updatedAt) <
          AppConstants.exchangeRateCacheTtl) {
        return model.rate;
      }
    }

    try {
      final url = '${ApiEndpoints.exchangeRateBase}/convert';
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {
          'from': from,
          'to': to,
          'amount': 1,
        },
      );
      final rate = (response.data?['result'] as num?)?.toDouble();
      if (rate != null) {
        await _saveRate(cacheKey, from, to, rate);
        return rate;
      }
    } catch (_) {}

    // Fallback: latest rates endpoint
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${ApiEndpoints.exchangeRateBase}/latest',
        queryParameters: {'base': from, 'symbols': to},
      );
      final rates = response.data?['rates'] as Map<String, dynamic>?;
      final rate = (rates?[to] as num?)?.toDouble();
      if (rate != null) {
        await _saveRate(cacheKey, from, to, rate);
        return rate;
      }
    } catch (_) {}

    // Offline fallback
    if (cached is Map) {
      return CurrencyRateModel.fromMap(cached).rate;
    }
    return 1;
  }

  Future<void> _saveRate(
    String key,
    String from,
    String to,
    double rate,
  ) async {
    final model = CurrencyRateModel(
      from: from,
      to: to,
      rate: rate,
      updatedAt: DateTime.now(),
    );
    await HiveBoxes.currencyRatesBox.put(key, model.toMap());
  }
}
