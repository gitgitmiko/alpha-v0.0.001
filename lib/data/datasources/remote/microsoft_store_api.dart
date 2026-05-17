import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/seed_game_ids.dart';
import '../../mappers/game_mapper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../domain/entities/game_entity.dart';
import '../../../domain/entities/region_entity.dart';
import '../../models/autosuggest_hint.dart';

/// Dynamic Microsoft Store / Xbox API client.
class MicrosoftStoreApi {
  MicrosoftStoreApi(this._dio);

  final Dio _dio;

  bool get _useBackend => dotenv.env['USE_BACKEND'] == 'true';

  /// GET Reco list product IDs (Deal, New, TopPaid, etc.)
  Future<Map<String, dynamic>> fetchRecoList({
    required String listPath,
    required RegionEntity region,
    int skip = 0,
    int count = AppConstants.defaultPageSize,
    String itemType = 'Game',
  }) async {
    if (_useBackend) {
      return _backendGet('/games/deals', {
        'market': region.market,
        'locale': region.locale,
        'skip': skip,
        'count': count,
        'list': listPath.split('/').last,
      });
    }

    final url =
        '${ApiEndpoints.recoBase}${ApiEndpoints.recoListBase}/$listPath';
    final response = await _dio.get<Map<String, dynamic>>(
      url,
      queryParameters: {
        'market': region.market.toLowerCase(),
        'language': region.language,
        'itemTypes': itemType,
        'deviceFamily': 'Windows.Xbox',
        'count': count,
        'skipItems': skip,
      },
      options: Options(
        receiveTimeout: const Duration(seconds: 45),
      ),
    );
    final data = response.data ?? {};
    if (GameMapper.productIdsFromReco(data).isNotEmpty) {
      return data;
    }

    // Legacy path fallback (some docs use /api/list/)
    final legacyUrl =
        '${ApiEndpoints.recoBase}${ApiEndpoints.recoListBase}/api/list/$listPath';
    final legacy = await _dio.get<Map<String, dynamic>>(
      legacyUrl,
      queryParameters: {
        'market': region.market,
        'language': region.language,
        'itemType': itemType,
        'deviceFamily': 'Windows.Xbox',
        'count': count,
        'skipItems': skip,
      },
    );
    return legacy.data ?? data;
  }

  /// GET products by bigIds from Display Catalog (batched).
  Future<Map<String, dynamic>> fetchProducts({
    required RegionEntity region,
    required List<String> productIds,
  }) async {
    if (productIds.isEmpty) return {'Products': []};

    if (_useBackend) {
      return _backendGet('/games', {
        'market': region.market,
        'locale': region.locale,
        'ids': productIds.join(','),
      });
    }

    final allProducts = <dynamic>[];
    const batchSize = 25;
    for (var i = 0; i < productIds.length; i += batchSize) {
      final batch = productIds.skip(i).take(batchSize).toList();
      final url = '${ApiEndpoints.displayCatalogBase}${ApiEndpoints.products}';
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {
          'bigIds': batch.join(','),
          'market': region.market,
          'languages': '${region.language},neutral',
        },
      );
      final chunk = response.data?['Products'] as List<dynamic>? ?? [];
      allProducts.addAll(chunk);
    }
    return {'Products': allProducts};
  }

  /// Primary: Microsoft Store autosuggest (works on emulator). Fallback: Reco + seeds.
  Future<List<String>> fetchGameProductIds({
    required RegionEntity region,
    int count = AppConstants.defaultPageSize,
    int skip = 0,
  }) async {
    final fromAutosuggest = await fetchAutosuggestProductIds(
      region: region,
      count: count + skip,
    );
    if (fromAutosuggest.length > skip) {
      return fromAutosuggest.skip(skip).take(count).toList();
    }

    const lists = [
      RecoListPaths.deal,
      RecoListPaths.topPaid,
      RecoListPaths.newGames,
      RecoListPaths.topFree,
    ];
    for (final listPath in lists) {
      try {
        final reco = await fetchRecoList(
          listPath: listPath,
          region: region,
          skip: skip,
          count: count,
        );
        final ids = GameMapper.productIdsFromReco(reco);
        if (ids.isNotEmpty) return ids;
      } catch (_) {
        continue;
      }
    }

    return SeedGameIds.popular.take(count).toList();
  }

  /// Autosuggest → Display Catalog enrichment.
  Future<List<GameEntity>> fetchStoreGames({
    required RegionEntity region,
    int count = AppConstants.defaultPageSize,
    int skip = 0,
    String? searchQuery,
  }) async {
    final hints = searchQuery != null && searchQuery.isNotEmpty
        ? await fetchAutosuggestHints(
            region: region,
            queries: [searchQuery],
            maxResults: count + skip,
          )
        : await fetchAutosuggestHints(
            region: region,
            maxResults: count + skip + 10,
          );

    final slice = hints.skip(skip).take(count).toList();
    if (slice.isEmpty) return [];

    final ids = slice.map((h) => h.productId).toList();
    final products = await fetchProducts(region: region, productIds: ids);
    final fromCatalog = GameMapper.fromProductList(products, region);
    final byId = {for (final g in fromCatalog) g.productId: g};

    return slice.map((hint) {
      return byId[hint.productId] ??
          GameEntity(
            productId: hint.productId,
            title: hint.title,
            imageUrl: _normalizeImage(hint.imageUrl),
            originalPrice: 0,
            discountedPrice: 0,
            currency: region.currencyCode,
            discountPercent: 0,
            region: region.market,
          );
    }).toList();
  }

  Future<List<AutosuggestHint>> fetchAutosuggestHints({
    required RegionEntity region,
    List<String>? queries,
    int maxResults = 40,
  }) async {
    final seeds = queries ??
        const [
          'game',
          'xbox',
          'a',
          'forza',
          'halo',
          'ea',
          'rpg',
          'action',
          'pass',
        ];

    final results = <AutosuggestHint>[];
    final seen = <String>{};

    for (final q in seeds) {
      if (results.length >= maxResults) break;
      try {
        final batch = await _fetchAutosuggestBatch(region, q);
        for (final hint in batch) {
          if (!hint.isGame) continue;
          if (seen.add(hint.productId)) results.add(hint);
        }
      } catch (_) {
        continue;
      }
    }
    return results;
  }

  Future<List<String>> fetchAutosuggestProductIds({
    required RegionEntity region,
    int count = 25,
    List<String>? queries,
  }) async {
    final hints = await fetchAutosuggestHints(
      region: region,
      queries: queries,
      maxResults: count,
    );
    return hints.map((h) => h.productId).toList();
  }

  Future<List<AutosuggestHint>> _fetchAutosuggestBatch(
    RegionEntity region,
    String query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.msStoreAutosuggest,
      queryParameters: {
        'market': region.locale,
        'sources': 'Iris-Products,xSearch-Products',
        'filter': '+ClientType:StoreWeb',
        'counts': '25',
        'query': query,
      },
      options: Options(
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Accept': 'application/json',
          'User-Agent': 'XboxRegionStoreBrowser/1.0',
        },
      ),
    );

    final data = response.data ?? {};
    final sets = data['ResultSets'] as List<dynamic>? ?? [];
    final hints = <AutosuggestHint>[];

    for (final set in sets) {
      final suggests = (set as Map)['Suggests'] as List<dynamic>? ?? [];
      for (final raw in suggests) {
        final s = raw as Map<String, dynamic>;
        final hint = _parseSuggest(s);
        if (hint != null) hints.add(hint);
      }
    }
    return hints;
  }

  AutosuggestHint? _parseSuggest(Map<String, dynamic> suggest) {
    final metas = suggest['Metas'] as List<dynamic>? ?? [];
    String? bigId;
    String? productType;
    for (final m in metas) {
      final map = m as Map<String, dynamic>;
      final key = map['Key'] as String?;
      final value = map['Value'] as String?;
      if (key == 'BigCatalogId' && value != null) bigId = value;
      if (key == 'ProductType' && value != null) productType = value;
    }

    bigId ??= _idFromStoreUrl(suggest['Url'] as String?);
    if (bigId == null) return null;

    return AutosuggestHint(
      productId: bigId.toUpperCase(),
      title: suggest['Title'] as String? ?? bigId,
      imageUrl: _normalizeImage(suggest['ImageUrl'] as String?),
      productType: productType ?? 'Game',
    );
  }

  String? _idFromStoreUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    final match = RegExp(r'/([9][A-Z0-9]{11})/?$', caseSensitive: false)
        .firstMatch(url);
    return match?.group(1);
  }

  String _normalizeImage(String? uri) {
    if (uri == null || uri.isEmpty) return '';
    if (uri.startsWith('http')) return uri;
    return 'https:$uri';
  }

  /// Search via Microsoft autosuggest + Display Catalog.
  Future<Map<String, dynamic>> searchProducts({
    required RegionEntity region,
    required String query,
    int skip = 0,
    int count = AppConstants.defaultPageSize,
  }) async {
    if (_useBackend) {
      return _backendGet('/games/search', {
        'market': region.market,
        'locale': region.locale,
        'q': query,
        'skip': skip,
        'count': count,
      });
    }

    final games = await fetchStoreGames(
      region: region,
      count: count,
      skip: skip,
      searchQuery: query,
    );
    return {
      'Products': games
          .map(
            (g) => {
              'ProductId': g.productId,
              'LocalizedProperties': [
                {
                  'ProductTitle': g.title,
                  'Images': [
                    {'Uri': g.imageUrl, 'ImagePurpose': 'Poster'},
                  ],
                },
              ],
              'DisplaySkuAvailabilities': [
                {
                  'Availabilities': [
                    {
                      'Markets': [region.market],
                      'Actions': ['Purchase'],
                      'OrderManagementData': {
                        'Price': {
                          'ListPrice': g.discountedPrice,
                          'MSRP': g.originalPrice,
                          'CurrencyCode': g.currency,
                        },
                      },
                    },
                  ],
                },
              ],
            },
          )
          .toList(),
    };
  }

  /// Game Pass SIGL binary list -> product IDs
  Future<List<String>> fetchGamePassProductIds({
    required RegionEntity region,
  }) async {
    if (_useBackend) {
      final data = await _backendGet('/gamepass', {
        'market': region.market,
        'locale': region.locale,
      });
      return (data['ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
    }

    try {
      final url =
          '${ApiEndpoints.gamePassCatalogBase}${ApiEndpoints.gamePassAllSigl}';
      final response = await _dio.get<List<int>>(
        url,
        queryParameters: {
          'language': region.language.toLowerCase(),
          'market': region.market.toLowerCase(),
        },
        options: Options(responseType: ResponseType.bytes),
      );
      final parsed = _parseSiglIds(response.data ?? []);
      if (parsed.isNotEmpty) return parsed;
    } catch (_) {}

    return fetchGameProductIds(region: region, count: 50);
  }

  List<String> _parseSiglIds(List<int> bytes) {
    if (bytes.length < 4) return [];
    final ids = <String>[];
    // SIGL v2: skip header, read null-terminated strings
    var i = 0;
    while (i < bytes.length - 12) {
      if (bytes[i] == 0x09 && bytes[i + 1] == 0x4E) {
        i += 12;
        break;
      }
      i++;
    }
    final buffer = StringBuffer();
    for (; i < bytes.length; i++) {
      final b = bytes[i];
      if (b == 0) {
        final s = buffer.toString().trim();
        buffer.clear();
        if (s.length >= 10 && s.startsWith('9')) ids.add(s);
      } else if (b >= 32 && b < 127) {
        buffer.writeCharCode(b);
      }
    }
    return ids.toSet().toList();
  }

  Future<Map<String, dynamic>> _backendGet(
    String path,
    Map<String, dynamic> query,
  ) async {
    final backendUrl = dotenv.env['BACKEND_BASE_URL'] ?? '';
    final response = await _dio.get<Map<String, dynamic>>(
      '$backendUrl$path',
      queryParameters: query,
      options: Options(
        headers: {
          if (dotenv.env['BACKEND_API_KEY'] != null)
            'X-API-Key': dotenv.env['BACKEND_API_KEY'],
        },
      ),
    );
    final data = response.data;
    if (data == null) {
      throw const ServerException('Empty backend response');
    }
    return data;
  }
}
