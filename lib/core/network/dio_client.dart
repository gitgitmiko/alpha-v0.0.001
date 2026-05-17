import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'XboxRegionStoreBrowser/1.0',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final useBackend = dotenv.env['USE_BACKEND'] == 'true';
        if (useBackend && options.path.startsWith('/')) {
          final base = dotenv.env['BACKEND_BASE_URL'];
          if (base != null && base.isNotEmpty) {
            options.baseUrl = base;
            final key = dotenv.env['BACKEND_API_KEY'];
            if (key != null && key.isNotEmpty) {
              options.headers['X-API-Key'] = key;
            }
          }
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ),
  );

  return dio;
});

final backendDioProvider = Provider<Dio>((ref) {
  final baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://10.0.2.2:3000';
  return Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );
});
