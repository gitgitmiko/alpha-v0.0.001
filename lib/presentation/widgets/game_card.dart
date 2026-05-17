import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_utils.dart';
import '../../domain/entities/game_entity.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../features/home/providers/home_providers.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../services/price_tracker/price_tracker_service.dart';
import '../../features/price_compare/presentation/region_compare_modal.dart';

class GameCard extends ConsumerWidget {
  const GameCard({super.key, required this.game});

  final GameEntity game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoriteIdsProvider).value ?? {};
    final wishIds = ref.watch(wishlistIdsProvider).value ?? {};
    final isFav = favIds.contains(game.productId);
    final isWish = wishIds.contains(game.productId);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showRegionCompareModal(context, ref, game.productId),
        onLongPress: () => _showActions(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: game.imageUrl,
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 80,
                    height: 100,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.videogame_asset),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (game.hasDiscount) ...[
                      Text(
                        PriceUtils.formatPrice(
                          game.originalPrice,
                          game.currency,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${game.discountPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            PriceUtils.formatPrice(
                              game.discountedPrice,
                              game.currency,
                            ),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ] else if (game.discountedPrice > 0)
                      Text(
                        PriceUtils.formatPrice(
                          game.discountedPrice,
                          game.currency,
                        ),
                        style: theme.textTheme.titleSmall,
                      )
                    else
                      Text(
                        'Harga tidak tersedia',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : null,
                    ),
                    onPressed: () =>
                        ref.read(favoriteIdsProvider.notifier).toggle(game),
                  ),
                  IconButton(
                    icon: Icon(
                      isWish ? Icons.bookmark : Icons.bookmark_border,
                      color: isWish ? theme.colorScheme.primary : null,
                    ),
                    onPressed: () => _toggleWishlist(ref, isWish),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleWishlist(WidgetRef ref, bool isWish) async {
    final repo = ref.read(wishlistRepositoryProvider);
    if (isWish) {
      await repo.remove(game.productId);
    } else {
      await repo.add(
        WishlistItemEntity(
          productId: game.productId,
          title: game.title,
          image: game.imageUrl,
          region: game.region,
          price: game.originalPrice,
          discountPrice: game.discountedPrice,
        ),
      );
    }
    ref.invalidate(wishlistIdsProvider);
  }

  Future<void> _showActions(BuildContext context, WidgetRef ref) async {
    final tracker = ref.read(priceTrackerServiceProvider);
    final tracking = await tracker.isTracking(game.productId);

    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(tracking ? Icons.notifications_off : Icons.notifications),
              title: Text(tracking ? 'Stop lacak harga' : 'Lacak harga'),
              onTap: () async {
                if (tracking) {
                  await tracker.disableTracking(game.productId);
                } else {
                  await tracker.enableTracking(game);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text('Bandingkan region'),
              onTap: () {
                Navigator.pop(ctx);
                showRegionCompareModal(context, ref, game.productId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
