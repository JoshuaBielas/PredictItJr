import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:predictit_jr/utils/formatters.dart';
import '../models/market.dart';
// import 'bet_sheet.dart';
import 'package:go_router/go_router.dart';

// I got help from AI for this code.

class MarketCard extends StatelessWidget {
  final Market market;

  const MarketCard({super.key, required this.market});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        // MarketCard opens a Bottom Sheet because this causes
        // all of the processing related to the cards to happen within
        // MarketCard rather than MarketScreen
        onTap: () => context.push('/market/${market.id}'),
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
                    // Text(
                    //   market.title, // mkt_001 is long → RenderFlex overflow
                    //   style: Theme.of(context).textTheme.titleMedium,
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    Hero(
                      tag: 'market-title-${market.id}',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Text(
                          market.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
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
      ),
    );
  }
}