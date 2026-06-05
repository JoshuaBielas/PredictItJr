import 'package:flutter/material.dart';
import 'package:predictit_jr/providers/auth_model.dart';
import 'package:predictit_jr/providers/theme_model.dart';
import 'package:predictit_jr/services/permission_service.dart';
import 'package:provider/provider.dart';
import 'providers/portfolio_model.dart';
import 'router.dart';
import 'theme/app_theme.dart';

// I got help from AI on this

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final portfolio = PortfolioModel();
  final auth = AuthModel();
  final theme = ThemeModel();

  await Future.wait([portfolio.load(), auth.load(), theme.load()]);

  runApp(PredictItApp(
    portfolio: portfolio,
    auth: auth,
    theme: theme,
  ),
  );
}

class PredictItApp extends StatelessWidget {
  const PredictItApp({
    super.key,
    required this.portfolio,
    required this.auth,
    required this.theme,
  });

  final PortfolioModel portfolio;
  final AuthModel auth;
  final ThemeModel theme;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PortfolioModel>.value(value: portfolio),
        ChangeNotifierProvider<AuthModel>.value(value: auth),
        ChangeNotifierProvider<ThemeModel>.value(value: theme),
        Provider<PermissionService>(create: (_) => PermissionService()),
      ],
      child: Builder(
        builder: (context) => MaterialApp.router(
          title: 'PredictIt Jr.',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: context.watch<ThemeModel>().themeMode,
          routerConfig: buildRouter(auth),
        ),
      ),
    );
  }
}