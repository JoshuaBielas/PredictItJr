import 'package:go_router/go_router.dart';
import 'providers/auth_model.dart';
import 'screens/market_list_screen.dart';
import 'screens/market_detail_screen.dart';
import 'screens/portfolio_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/signin_screen.dart';
import 'widgets/adaptive_shell.dart';

GoRouter buildRouter(AuthModel auth) {
  return GoRouter(
    refreshListenable: auth,
    redirect: (context, state) {
      final signedIn = auth.isSignedIn;
      final atSignin = state.matchedLocation == '/signin';
      if (!signedIn && !atSignin) return '/signin';
      if (signedIn && atSignin) return '/';
      return null;
    },
    routes: [
      // Sign-in lives OUTSIDE the shell — no tabs visible until signed in.
      GoRoute(
        path: '/signin',
        builder: (_, __) => const SignInScreen(),
      ),
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
                    builder: (context, state) => MarketDetailScreen(
                      id: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/portfolio',
              builder: (_, __) => const PortfolioScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
}
