import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_utils.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../features/home/providers/home_providers.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(wishlistRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: FutureBuilder(
        future: repo.getAll(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Wishlist kosong'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final item = items[i];
              return Dismissible(
                key: Key(item.productId),
                direction: DismissDirection.endToStart,
                onDismissed: (_) async {
                  await repo.remove(item.productId);
                  ref.invalidate(wishlistIdsProvider);
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.image,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: Text(
                    '${PriceUtils.formatPrice(item.discountPrice, '')} · ${item.region}',
                  ),
                  trailing: const Icon(Icons.shopping_bag_outlined),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
