import 'package:flutter/material.dart';
import '../data/market_repository.dart';
import '../models/market.dart';
import '../widgets/market_card.dart';

class MarketListScreen extends StatefulWidget {
  const MarketListScreen({super.key});

  @override
  State<MarketListScreen> createState() => _MarketListScreenState();
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
      appBar: AppBar(title: const Text('Markets')),
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
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                 _marketsFuture = MarketRepository().loadAll();
              });
              await _marketsFuture;
            },
            child: ListView.builder(
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