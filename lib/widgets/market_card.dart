import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:predictit_jr/utils/formatters.dart';
import '../models/market.dart';

class MarketCard extends StatelessWidget {
  final Market market;

  const MarketCard({super.key, required this.market});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SvgPicture.asset(
              market.imageAsset,
              width: 64,
              height: 64,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    market.title, // mkt_001 is long → RenderFlex overflow
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text('YES ${Formatters.price(market.yesPriceCents)}'),
                  Text('Volume ${market.volumeShares} shares'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}