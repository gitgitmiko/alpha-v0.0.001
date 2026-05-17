import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/result.dart';
import '../../../data/repositories/game_pass_repository_impl.dart';
import '../../../domain/entities/game_pass_entity.dart';
import '../../settings/providers/settings_providers.dart';

final gamePassCatalogProvider =
    FutureProvider<List<GamePassGameEntity>>((ref) async {
  ref.watch(regionProvider);
  final region = ref.read(regionProvider);
  final result = await ref.read(gamePassRepositoryProvider).getCatalog(region: region);
  return result.when(
    success: (data) => data,
    error: (f) => throw Exception(f.message),
  );
});

final gamePassPricesProvider =
    FutureProvider<List<GamePassPriceEntity>>((ref) async {
  ref.watch(regionProvider);
  final region = ref.read(regionProvider);
  final result =
      await ref.read(gamePassRepositoryProvider).getSubscriptionPrices(
            region: region,
          );
  return result.when(
    success: (data) => data,
    error: (f) => throw Exception(f.message),
  );
});
