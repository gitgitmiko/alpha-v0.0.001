import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/regions.dart';
import '../../../domain/entities/region_entity.dart';
import '../../../services/ads/ad_service.dart';
import '../../../services/billing/billing_service.dart';
import '../../home/providers/home_providers.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(regionProvider);
    final themeMode = ref.watch(themeModeProvider);
    final removeAds = ref.watch(removeAdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Region'),
            subtitle: Text('Mengubah region memperbarui harga & katalog'),
          ),
          ...AppRegions.supported.map(
            (r) => RadioListTile<RegionEntity>(
              title: Text('${r.flagEmoji} ${r.name}'),
              subtitle: Text('${r.market} · ${r.currencyCode}'),
              value: r,
              groupValue: region,
              onChanged: (v) {
                if (v != null) {
                  ref.read(regionProvider.notifier).setRegion(v);
                  ref.invalidate(homeGamesProvider);
                }
              },
            ),
          ),
          const Divider(),
          const ListTile(title: Text('Tema')),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ],
            selected: {themeMode},
            onSelectionChanged: (s) =>
                ref.read(themeModeProvider.notifier).setMode(s.first),
          ),
          const Divider(),
          ListTile(
            title: const Text('Hapus Iklan'),
            subtitle: Text(AppConstants.removeAdsPriceLabel),
            trailing: removeAds
                ? const Chip(label: Text('Aktif'))
                : FilledButton(
                    onPressed: () async {
                      await ref.read(billingServiceProvider).buyRemoveAds();
                      ref.invalidate(removeAdsProvider);
                      ref.read(adServiceProvider).loadInterstitial();
                    },
                    child: const Text('Beli'),
                  ),
          ),
          if (!removeAds)
            ListTile(
              title: const Text('Pulihkan pembelian'),
              onTap: () => ref.read(billingServiceProvider).restorePurchases(),
            ),
          const Divider(),
          ListTile(
            title: const Text('Kebijakan Privasi'),
            subtitle: const Text('Placeholder — ganti URL sebelum rilis'),
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              AppConstants.disclaimer,
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
          const ListTile(
            title: Text('Tentang'),
            subtitle: Text(
              '${AppConstants.appName}\n'
              'Bukan aplikasi resmi Microsoft/Xbox.\n'
              'Menggunakan API publik Microsoft Store.\n'
              'Iklan mendukung pengembangan aplikasi.',
            ),
          ),
        ],
      ),
    );
  }
}
