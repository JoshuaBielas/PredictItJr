import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/market_repository.dart';
import '../models/market.dart';
import '../providers/portfolio_model.dart';
import '../utils/formatters.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio')),
      body: Consumer<PortfolioModel>(
        builder: (context, portfolio, _) {
          final bets = portfolio.bets;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Cash: ${Formatters.balance(portfolio.cashCents)}',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 24),
              if (bets.isEmpty)
                const Text('No positions yet')
              else
                for (final bet in bets)
                  FutureBuilder<Market?>(
                    future: MarketRepository().findById(bet.marketId),
                    builder: (context, snapshot) {
                      final marketTitle = snapshot.data?.title ?? 'Unknown market';
                      return ListTile(
                        title: Text(marketTitle),
                        subtitle: Text(
                          '${bet.side.name.toUpperCase()} - '
                          '${bet.shares} shares - '
                          'Cost: ${Formatters.balance(bet.totalCostCents)}',
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => context.read<PortfolioModel>().sellPosition(bet),
                          child: const Text('Sell Position'),
                        ),
                      );
                    },
                  ),
            ],
          );
        },
      ),
    );
  }
}
