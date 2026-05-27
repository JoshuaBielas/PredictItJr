import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/portfolio_model.dart';
import 'router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const PredictItApp());
}

class PredictItApp extends StatelessWidget {
  const PredictItApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PortfolioModel(),
      child: MaterialApp.router(
        title: 'PredictIt Jr.',
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );
  }
}
