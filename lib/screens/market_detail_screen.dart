import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../data/market_repository.dart';
import '../models/market.dart';
import '../widgets/bet_sheet.dart';

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
          return _DetailBody(market: market);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.market});
  final Market market;

  @override
  Widget build(BuildContext context) {
    final spots = market.priceHistory.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final point = entry.value;
      return FlSpot(index, point.yesPriceCents.toDouble());
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(market.title,
          //     style: Theme.of(context).textTheme.headlineSmall),
          Hero(
            tag: 'market-title-${market.id}',
            child: Material(
              type: MaterialType.transparency,
              child: Text(market.title,
                  style: Theme.of(context).textTheme.headlineSmall,),
            ),
          ),
          const SizedBox(height: 12),
          Text(market.description),
          const SizedBox(height: 24),
          Text('Closes: ${market.closesAt.toLocal().toString().split(' ')[0]}'), 
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (market.priceHistory.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => BetSheet(market: market),
                );
              },
              child: const Text('Place a bet'),
            ),
          ),
        ],
      ),
    );
  }
}