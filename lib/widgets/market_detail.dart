import 'package:fl_chart/fl_chart.dart';
import '../widgets/bet_sheet.dart';
import 'package:flutter/material.dart';
import '../models/market.dart';
import 'adaptive_shell.dart';

// I got help from AI on the extra credit here

class MarketDetailBody extends StatelessWidget {
  const MarketDetailBody({super.key, required this.market});
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
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (market.priceHistory.length - 1).toDouble(),
                minY: 0,
                maxY: 100,
                titlesData: const FlTitlesData(
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
                gridData: const FlGridData(show: false),
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
                final wide = MediaQuery.sizeOf(context).width >= kWideBreakpoint;

                if (wide) {
                  showGeneralDialog<void>(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: 'Dismiss',
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          child: SizedBox(
                            width: 300,
                            height: double.infinity,
                            child: BetSheet(market: market),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => BetSheet(market: market),
                  );
                }
              },
              child: const Text('Place a bet'),
            ),
          ),
        ],
      ),
    );
  }
}