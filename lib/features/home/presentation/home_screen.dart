import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../../domain/entities/game_entity.dart';
import '../../../presentation/widgets/error_retry_widget.dart';
import '../../../presentation/widgets/game_card.dart';
import '../../../presentation/widgets/loading_widget.dart';
import '../../settings/providers/settings_providers.dart';
import '../providers/home_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(homeGamesProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(homeGamesProvider);
    final region = ref.watch(regionProvider);
    final recent = ref.watch(localStorageProvider).recentSearches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xbox Store'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => context.push('/wishlist'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Text(region.flagEmoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  region.name,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Cari game...',
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterSheet(context),
                ),
              ],
              onChanged: (v) =>
                  ref.read(homeGamesProvider.notifier).search(v),
              onSubmitted: (v) =>
                  ref.read(homeGamesProvider.notifier).search(v),
            ),
          ),
          if (recent.isNotEmpty && _searchController.text.isEmpty)
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: recent
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(s),
                          onPressed: () {
                            _searchController.text = s;
                            ref.read(homeGamesProvider.notifier).search(s);
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          Expanded(
            child: gamesAsync.when(
              data: (games) {
                if (games.isEmpty) {
                  return const Center(child: Text('Tidak ada game ditemukan'));
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(homeGamesProvider.notifier).refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: games.length,
                    itemBuilder: (_, i) => GameCard(game: games[i]),
                  ),
                );
              },
              loading: () => const LoadingWidget(),
              error: (e, _) => ErrorRetryWidget(
                message: e.toString(),
                onRetry: () =>
                    ref.read(homeGamesProvider.notifier).refresh(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Hanya favorit'),
              value: false,
              onChanged: (v) {
                ref.read(homeGamesProvider.notifier).setFavoriteOnly(v);
                Navigator.pop(ctx);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Harga terendah'),
              onTap: () {
                ref
                    .read(homeGamesProvider.notifier)
                    .setSort(GameSortFilter.lowestPrice);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Harga tertinggi'),
              onTap: () {
                ref
                    .read(homeGamesProvider.notifier)
                    .setSort(GameSortFilter.highestPrice);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Diskon tertinggi'),
              onTap: () {
                ref
                    .read(homeGamesProvider.notifier)
                    .setSort(GameSortFilter.highestDiscount);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('Diskon terendah'),
              onTap: () {
                ref
                    .read(homeGamesProvider.notifier)
                    .setSort(GameSortFilter.lowestDiscount);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
