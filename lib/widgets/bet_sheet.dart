import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bet.dart';
import '../models/market.dart';
import '../utils/formatters.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_model.dart';

// I got help from AI for this

class BetSheet extends StatefulWidget {
  const BetSheet({super.key, required this.market});

  final Market market;

  @override
  State<BetSheet> createState() => _BetSheetState();
}

class _BetSheetState extends State<BetSheet> {
  BetSide? _side;
  int _shares = 10;

  @override
  Widget build(BuildContext context) {
    final market = widget.market;
    final int price =
        _side == BetSide.no ? market.noPriceCents : market.yesPriceCents;
    final int costCents = _shares * price;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16, 
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              market.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<BetSide>(
              segments: [
                ButtonSegment<BetSide>(
                  value: BetSide.yes,
                  label: Text('YES ${Formatters.price(market.yesPriceCents)}'),
                ),
                ButtonSegment<BetSide>(
                  value: BetSide.no,
                  label: Text('NO ${Formatters.price(market.noPriceCents)}'),
                ),
              ],
              selected: _side == null ? <BetSide>{} : <BetSide>{_side!},
              emptySelectionAllowed: true,
              onSelectionChanged: (selection) {
                setState(() {
                  _side = selection.isEmpty ? null : selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Shares:'),
                Expanded(
                  child: Slider(
                    value: _shares.toDouble(),
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '$_shares',
                    onChanged: (v) {
                      final shares = v.round();
                      if (shares % 10 == 0 && shares != _shares){
                        HapticFeedback.selectionClick();
                      }
                      setState(() => _shares = v.round());
                    },
                  ),
                ),
                SizedBox(width: 32, child: Text('$_shares')),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Total cost: ${Formatters.balance(costCents)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _side == null
                    ? null
                    : () {
                        final bet = Bet(
                          marketId: market.id,
                          side: _side!,
                          shares: _shares,
                          pricePaidCents: price,
                          placedAt: DateTime.now(),
                        );
                        final ok = context.read<PortfolioModel>().placeBet(bet);
                        if (!ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Not enough cash'),
                            ),
                          );
                          return;
                        }
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Bet placed: ${bet.shares} ${bet.side.name.toUpperCase()} @ ${bet.pricePaidCents}¢'),
                          ),
                        );
                      },
                child: const Text('Place bet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
