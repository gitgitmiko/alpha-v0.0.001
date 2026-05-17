import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/regions.dart';
import '../../../core/utils/price_utils.dart';
import '../../../core/utils/result.dart';
import '../../../data/repositories/game_repository_impl.dart';
import '../../../domain/entities/game_entity.dart';

Future<void> showRegionCompareModal(
  BuildContext context,
  WidgetRef ref,
  String productId,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _RegionCompareSheet(productId: productId),
  );
}

class _RegionCompareSheet extends ConsumerStatefulWidget {
  const _RegionCompareSheet({required this.productId});

  final String productId;

  @override
  ConsumerState<_RegionCompareSheet> createState() =>
      _RegionCompareSheetState();
}

class _RegionCompareSheetState extends ConsumerState<_RegionCompareSheet> {
  late Future<List<GameEntity>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<GameEntity>> _load() async {
    final repo = ref.read(gameRepositoryProvider);
    final result = await repo.compareRegions(
      productId: widget.productId,
      markets: AppRegions.compareMarkets,
    );
    return result.when(
      success: (list) {
        list.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
        return list;
      },
      error: (f) => throw Exception(f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Perbandingan Harga Region',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<GameEntity>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(child: Text(snap.error.toString()));
                  }
                  final games = snap.data ?? [];
                  if (games.isEmpty) {
                    return const Center(child: Text('Data tidak tersedia'));
                  }
                  final cheapest = games.first.discountedPrice;

                  return ListView(
                    controller: controller,
                    children: games.map((g) {
                      final region = AppRegions.byMarket(g.region);
                      final isCheapest = g.discountedPrice == cheapest;
                      return Card(
                        color: isCheapest
                            ? Theme.of(context)
                                .colorScheme
                                .primaryContainer
                            : null,
                        child: ListTile(
                          leading: Text(
                            region.flagEmoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(region.name),
                          subtitle: g.hasDiscount
                              ? Text(
                                  'Diskon ${g.discountPercent.toStringAsFixed(0)}%',
                                )
                              : null,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                PriceUtils.formatPrice(
                                  g.discountedPrice,
                                  g.currency,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isCheapest)
                                Text(
                                  'Termurah',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
