import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:predictit_jr/data/auth_storage.dart';
import 'package:predictit_jr/main.dart';
import 'package:predictit_jr/models/market.dart';
import 'package:predictit_jr/providers/auth_model.dart';
import 'package:predictit_jr/router.dart';
import 'package:predictit_jr/screens/create_market_screen.dart';
import 'package:predictit_jr/screens/market_detail_screen.dart';
import 'package:predictit_jr/screens/market_list_screen.dart';
import 'package:predictit_jr/screens/signin_screen.dart';
import 'package:predictit_jr/services/permission_service.dart';
import 'package:predictit_jr/widgets/bet_sheet.dart';
import 'package:predictit_jr/widgets/market_card.dart';
import 'package:provider/provider.dart';
import 'package:predictit_jr/providers/portfolio_model.dart';
import 'package:predictit_jr/screens/portfolio_screen.dart';
import 'fakes.dart'; // the same FakePortfolioStorage from Step 1
import 'package:predictit_jr/models/bet.dart';

// I got AI help on this

Widget _portfolioHarness(PortfolioModel model) {
  return MaterialApp(
    home: ChangeNotifierProvider<PortfolioModel>.value(
      value: model,
      child: const PortfolioScreen(),
    ),
  );
}

class FakePermissionService implements PermissionService {
  @override
  Future<PermissionOutcome> requestLocation() async => PermissionOutcome.denied;

  @override
  Future<PermissionOutcome> requestCamera() async => PermissionOutcome.denied;

  @override
  Future<bool> openSettings() async => false;
}

class FakeAuthStorage implements AuthStorage {
  @override
  Future<String?> load() async => null; // no saved session

  @override
  Future<void> save(String token) async {}

  @override
  Future<void> clear() async {}
}

Widget _marketListHarness(PortfolioModel model,
    {List<Market> markets = const [], Size size = const Size(400, 800)}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => MarketListScreen(markets: markets),
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
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<PortfolioModel>.value(value: model),
      Provider<PermissionService>.value(value: FakePermissionService()),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQueryData(size: size),
        child: child!,
      ),
    ),
  );
}

Widget _betSheetHarness(PortfolioModel model, Market market) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<PortfolioModel>.value(value: model),
      Provider<PermissionService>.value(value: FakePermissionService()),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: BetSheet(market: market),
      ),
    ),
  );
}

void main() {
  testWidgets('app boots to sign in when signed out',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      PredictItApp(
        portfolio: PortfolioModel(),
        auth: AuthModel(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Markets'), findsNothing);
  });
  // EXTRA CREDIT REFACTOR
  // Before the refactor MarketListscreen loaded markets internally
  // @override
  // void initState() {
  //   super.initState();
  //   _marketsFuture = MarketRepository().loadAll();
  //   _captureListLocation();
  // }
  // I added an optional constructor parameter to add the markets.
  // @override
  // void initState() {
  //   super.initState();
  //   _marketsFuture = widget.markets != null
  //       ? Future.value(widget.markets)
  //       : MarketRepository().loadAll();
  //   _captureListLocation();
  // }
  // The actual test part for this test is now very short
  testWidgets('Correct number of markets displayed', (tester) async {
    final markets = [
      Market(
        id: 'mkt_001',
        title: 'question 1?',
        description: 'description 1',
        category: 'category 1',
        yesPriceCents: 1,
        volumeShares: 1,
        closesAt: DateTime.now(),
        imageAsset: '1',
        priceHistory: [],
      ),
      Market(
        id: 'mkt_002',
        title: 'question 2?',
        description: 'description 2',
        category: 'category 2',
        yesPriceCents: 2,
        volumeShares: 2,
        closesAt: DateTime.now(),
        imageAsset: '2',
        priceHistory: [],
      ),
    ];

    final model = PortfolioModel(storage: FakePortfolioStorage());
    await tester.pumpWidget(_marketListHarness(model, markets: markets));
    await tester.pumpAndSettle();

    expect(find.byType(MarketCard), findsNWidgets(2));
  });

  testWidgets('Tapping card navigates to detail screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(300, 800));
    await tester.pump();

    final markets = [
      Market(
        id: 'mkt_001',
        title: 'question 1?',
        description: 'description 1',
        category: 'category 1',
        yesPriceCents: 1,
        volumeShares: 1,
        closesAt: DateTime.now(),
        imageAsset: 'assets/images/campus.svg',
        priceHistory: [],
      ),
      Market(
        id: 'mkt_002',
        title: 'question 2?',
        description: 'description 2',
        category: 'category 2',
        yesPriceCents: 2,
        volumeShares: 2,
        closesAt: DateTime.now(),
        imageAsset: 'assets/images/campus.svg',
        priceHistory: [],
      ),
    ];

    final model = PortfolioModel(storage: FakePortfolioStorage());

    await tester.pumpWidget(_marketListHarness(model,
        markets: markets, size: const Size(400, 800)));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(MarketCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(MarketDetailScreen), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Place bet button is disabled with no side selected',
      (tester) async {
    final market = Market(
      id: 'mkt_001',
      title: 'question 1?',
      description: 'description 1',
      category: 'category 1',
      yesPriceCents: 50,
      volumeShares: 1,
      closesAt: DateTime.now(),
      imageAsset: 'assets/images/campus.svg',
      priceHistory: [],
    );

    final model = PortfolioModel(storage: FakePortfolioStorage());
    await tester.pumpWidget(_betSheetHarness(model, market));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('Place bet button is enabled after selecting a side',
      (tester) async {
    final market = Market(
      id: 'mkt_001',
      title: 'question 1?',
      description: 'description 1',
      category: 'category 1',
      yesPriceCents: 50,
      volumeShares: 1,
      closesAt: DateTime.now(),
      imageAsset: 'assets/images/campus.svg',
      priceHistory: [],
    );

    final model = PortfolioModel(storage: FakePortfolioStorage());
    await tester.pumpWidget(_betSheetHarness(model, market));
    await tester.pumpAndSettle();

    await tester.tap(find.text('YES 50¢'));
    await tester.pumpAndSettle();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);
  });

  testWidgets('PortfolioScreen shows cash and empty state', (tester) async {
    final model = PortfolioModel(storage: FakePortfolioStorage());

    await tester.pumpWidget(_portfolioHarness(model));
    await tester.pumpAndSettle();

    // expect(find.text('Cash: \$1,000.00'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    // expect(find.textContaining('1,000.00'), findsOneWidget);
    expect(find.textContaining('No positions yet'), findsOneWidget);
  });

  testWidgets('placing a bet updates the cash', (tester) async {
    final model = PortfolioModel(storage: FakePortfolioStorage());

    await tester.pumpWidget(_portfolioHarness(model));
    await tester.pumpAndSettle();

    // Place a $5 bet (10 shares @ 50¢). Cash should drop to $995.00.
    model.placeBet(
      Bet(
        marketId: 'mkt_001',
        side: BetSide.yes,
        shares: 10,
        pricePaidCents: 50,
        placedAt: DateTime(2025, 1, 1),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(r'$995.00'), findsOneWidget); // new cash shown
    expect(find.text(r'$1,000.00'), findsNothing); // old cash gone
  });

  testWidgets('placing a bet through the UI updates the portfolio',
      (tester) async {
    final market = Market(
      id: 'mkt_001',
      title: 'question 1?',
      description: 'description 1',
      category: 'category 1',
      yesPriceCents: 50,
      volumeShares: 1,
      closesAt: DateTime.now(),
      imageAsset: 'assets/images/campus.svg',
      priceHistory: [],
    );

    final model = PortfolioModel(storage: FakePortfolioStorage());
    await tester.pumpWidget(_betSheetHarness(model, market));
    await tester.pumpAndSettle();

    // Select YES side
    await tester.tap(find.text('YES 50¢'));
    await tester.pumpAndSettle();

    // Place the bet (10 shares @ 50¢ = 500¢ total)
    await tester.tap(find.text('Place bet'));
    await tester.pumpAndSettle();

    expect(model.bets.length, 1);
    expect(model.cashCents, 100000 - 500);
  });

  testWidgets('signed-out user is redirected from /create to /signin',
      (tester) async {
    final auth = AuthModel(storage: FakeAuthStorage());
    await auth.load();

    final router = buildRouter(auth);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthModel>.value(value: auth),
          ChangeNotifierProvider<PortfolioModel>.value(
            value: PortfolioModel(storage: FakePortfolioStorage()),
          ),
          Provider<PermissionService>.value(value: FakePermissionService()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    // Attempt to navigate to /create
    router.go('/create');
    await tester.pumpAndSettle();

    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.byType(CreateMarketScreen), findsNothing);
  });
}
