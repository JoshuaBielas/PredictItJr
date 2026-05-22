import 'package:go_router/go_router.dart';
import 'screens/market_list_screen.dart';
import 'screens/market_detail_screen.dart';

// Routes carry STRINGS, not Dart objects. The detail route takes an
// id (a path parameter) and the screen looks the market up itself.
// This is what makes deep links, refreshes, and A7's redirects possible.
// — passing the whole Market object "because it's handy" defeats it.
final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MarketListScreen(),
    ),
    GoRoute(
      path: '/market/:id',
      builder: (context, state) => MarketDetailScreen(
        id: state.pathParameters['id']!,
      ),
    ),
  ],
);
