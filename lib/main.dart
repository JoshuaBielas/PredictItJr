import 'package:flutter/material.dart';
import 'package:predictit_jr/providers/auth_model.dart';
import 'package:predictit_jr/services/permission_service.dart';
import 'package:provider/provider.dart';
import 'providers/portfolio_model.dart';
import 'router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final portfolio = PortfolioModel();
  final auth = AuthModel();
  await Future.wait([portfolio.load(), auth.load()]);
  runApp(PredictItApp(portfolio: portfolio, auth: auth));
}

class PredictItApp extends StatelessWidget {
  const PredictItApp({
    super.key,
    required this.portfolio,
    required this.auth,
  });
  final PortfolioModel portfolio;
  final AuthModel auth;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PortfolioModel>.value(value: portfolio),
        ChangeNotifierProvider<AuthModel>.value(value: auth),
        Provider<PermissionService>(create: (_) => PermissionService()),
      ],
      child: MaterialApp.router(
        title: 'PredictIt Jr.',
        theme: AppTheme.light,
        routerConfig: buildRouter(auth), // router needs auth — see Step 3
      ),
    );
  }
}
