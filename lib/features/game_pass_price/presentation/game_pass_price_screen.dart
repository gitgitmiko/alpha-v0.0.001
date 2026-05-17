import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/price_utils.dart';
import '../../../presentation/widgets/error_retry_widget.dart';
import '../../../presentation/widgets/loading_widget.dart';
import '../../game_pass/providers/game_pass_providers.dart';
import '../../settings/providers/settings_providers.dart';

class GamePassPriceScreen extends ConsumerWidget {
  const GamePassPriceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prices = ref.watch(gamePassPricesProvider);
    final region = ref.watch(regionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Harga Game Pass'),
            Text(
              '${region.flagEmoji} ${region.name}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
      body: prices.when(
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final p = items[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(Icons.subscriptions),
                ),
                title: Text(p.name),
                subtitle: Text('Region: ${p.region}'),
                trailing: Text(
                  p.price > 0
                      ? PriceUtils.formatPrice(p.price, p.currency)
                      : '—',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            );
          },
        ),
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorRetryWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(gamePassPricesProvider),
        ),
      ),
    );
  }
}
