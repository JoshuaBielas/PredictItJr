// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../data/market_repository.dart';
import '../models/market.dart';
import '../widgets/market_detail.dart';
// import '../widgets/bet_sheet.dart';

// I got help from AI for my chart

class MarketDetailScreen extends StatefulWidget {
  const MarketDetailScreen({super.key, required this.id});
  final String id;

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> {
  late final Future<Market?> _marketFuture;

  @override
  void initState() {
    super.initState();
    _marketFuture = MarketRepository().findById(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: FutureBuilder<Market?>(
        future: _marketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final market = snapshot.data;
          if (market == null) {
            // The "not found" path — bad id in the URL.
            // findById is Future<Market?>: async AND maybe-absent.
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Market not found.'),
              ),
            );
          }
          return MarketDetailBody(market: market);
        },
      ),
    );
  }
}
