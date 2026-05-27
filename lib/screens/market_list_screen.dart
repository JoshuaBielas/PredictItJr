import 'package:flutter/material.dart';
import 'package:predictit_jr/widgets/adaptive_shell.dart';
import '../data/market_repository.dart';
import '../models/market.dart';
import '../widgets/market_card.dart';
import '../widgets/market_detail.dart';


class MarketListScreen extends StatefulWidget {
  const MarketListScreen({super.key});

  @override
  State<MarketListScreen> createState() => _MarketListScreenState();
}

class _WideMarketLayout extends StatefulWidget {
  const _WideMarketLayout({required this.markets});

  final List<Market> markets;

  @override
  State<_WideMarketLayout> createState() => _WideMarketLayoutState();
}

class _WideMarketLayoutState extends State<_WideMarketLayout> {
  Market? _selectedMarket;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: widget.markets.length,
            itemBuilder: (context, i) {
              final market = widget.markets[i];

              return MarketCard(
                market: market,
                onTap: () {
                  setState(() {
                    _selectedMarket = market;
                  });
                },
              );
            },
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: _selectedMarket == null
              ? const Center(child: Text('Select a market'))
              : MarketDetailBody(market: _selectedMarket!),
        ),
      ],
    );
  }
}

class _MarketListScreenState extends State<MarketListScreen> {
  late Future<List<Market>> _marketsFuture;

  @override
  void initState() {
    super.initState();
    _marketsFuture = MarketRepository().loadAll();
  }

  // I got help from AI for this code.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Markets'),
      ),
      body: FutureBuilder<List<Market>>(
        future: _marketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          }
          final markets = snapshot.data!;
          final wide = MediaQuery.sizeOf(context).width >= kWideBreakpoint;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                 _marketsFuture = MarketRepository().loadAll();
              });
              await _marketsFuture;
            },
            child: wide
              ? _WideMarketLayout(markets: markets)
              : ListView.builder(
                itemCount: markets.length,
                itemBuilder: (context, i) {
                  final market = markets[i];
                  return MarketCard(market: market);
                },
            ),
          );
        },
      ),
    );
  }
}