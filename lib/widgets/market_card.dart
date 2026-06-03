import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:predictit_jr/utils/formatters.dart';
import '../models/market.dart';
// import 'bet_sheet.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';

// I got help from AI for this code.

class MarketCard extends StatelessWidget {
  final Market market;
  final VoidCallback? onTap;
  final double? userLat;
  final double? userLng;

  const MarketCard({
    super.key,
    required this.market,
    this.onTap,
    this.userLat,
    this.userLng,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      child: InkWell(
        // MarketCard opens a Bottom Sheet because this causes
        // all of the processing related to the cards to happen within
        // MarketCard rather than MarketScreen
        onTap: onTap ?? () => context.push('/market/${market.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: market.imagePath != null
                    ? Image.file(
                        File(market.imagePath!),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      )
                    : SvgPicture.asset(
                        market.imageAsset,
                        width: 64,
                        height: 64,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  if (market.hasLocation && userLat != null && userLng != null)
                    Chip(
                      label: Text(
                        Formatters.distance(
                          userLat!,
                          userLng!,
                          market.latitude!,
                          market.longitude!,
                        ),
                      ),
                    ),
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
