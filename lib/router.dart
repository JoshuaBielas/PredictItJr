// import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/market_list_screen.dart';
import 'screens/market_detail_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/adaptive_shell.dart';

// I got help from AI on this

final GoRouter router = GoRouter(
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AdaptiveShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const MarketListScreen(),
              routes: [
                GoRoute(
                  path: 'market/:id',
                  builder: (context, state) =>
                      MarketDetailScreen(id: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(routes: [
          GoRoute(path: '/portfolio', builder: (_, __) => const PortfolioScreen()),
          ],
        ),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ],
        ),
      ],
    ),
  ],
);
