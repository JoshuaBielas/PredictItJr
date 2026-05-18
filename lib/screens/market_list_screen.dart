import 'package:flutter/material.dart';
import '../data/market_repository.dart';
import '../models/market.dart';

class MarketListScreen extends StatefulWidget {
  const MarketListScreen({super.key});

  @override
  State<MarketListScreen> createState() => _MarketListScreenState();
}

class _MarketListScreenState extends State<MarketListScreen> {
  late final Future<List<Market>> _marketsFuture;

  @override
  void initState() {
    super.initState();
    _marketsFuture = MarketRepository().loadAll(); // created exactly once
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Markets')),
      body: FutureBuilder<List<Market>>(
        future: _marketsFuture, // same Future on every rebuild
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load: ${snapshot.error}'));
          }
          final markets = snapshot.data!;
          // Task 1 stops here; Task 2 replaces this with ListView.builder.
          return Text('Loaded ${markets.length} markets');
        },
      ),
    );
  }
}