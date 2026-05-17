import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/widgets/error_retry_widget.dart';
import '../../../presentation/widgets/loading_widget.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/game_pass_providers.dart';

class GamePassScreen extends ConsumerWidget {
  const GamePassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(gamePassCatalogProvider);
    final region = ref.watch(regionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Xbox Game Pass'),
            Text(
              '${region.flagEmoji} ${region.name}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
      body: catalog.when(
        data: (games) {
          if (games.isEmpty) {
            return const Center(
              child: Text('Katalog Game Pass kosong untuk region ini'),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(gamePassCatalogProvider),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: games.length,
              itemBuilder: (_, i) {
                final g = games[i];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: g.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.sports_esports,
                              size: 48,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          g.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorRetryWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(gamePassCatalogProvider),
        ),
      ),
    );
  }
}
