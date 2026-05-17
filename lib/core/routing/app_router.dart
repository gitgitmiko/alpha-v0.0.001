import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/game_pass/presentation/game_pass_screen.dart';
import '../../features/game_pass_price/presentation/game_pass_price_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../presentation/screens/main_shell_screen.dart';
import '../../presentation/screens/wishlist_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (c, s) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/gamepass',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: GamePassScreen()),
          ),
          GoRoute(
            path: '/gamepass-price',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: GamePassPriceScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (c, s) =>
                const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/wishlist',
        builder: (c, s) => const WishlistScreen(),
      ),
    ],
  );
});
