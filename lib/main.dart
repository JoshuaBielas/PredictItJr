import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/portfolio_model.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final portfolio = PortfolioModel();
  // I chose to load the portfolio in main before running the app because this causes the information to be there immediately
  await portfolio.load();
  runApp(PredictItApp(portfolio: portfolio));
}

class PredictItApp extends StatelessWidget {
  const PredictItApp({super.key, required this.portfolio});
  final PortfolioModel portfolio;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: portfolio,
      child: MaterialApp.router(
        title: 'PredictIt Jr.',
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }
}
