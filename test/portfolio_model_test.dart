import 'package:flutter_test/flutter_test.dart';
import 'package:predictit_jr/models/bet.dart';
import 'package:predictit_jr/providers/portfolio_model.dart';
import 'fakes.dart';

// I got some help from AI on this code

void main() {
  test('A fresh model starts at the documented cash with no bets', () {
    final storage = FakePortfolioStorage();
    final model = PortfolioModel(storage: storage);

    expect(model.cashCents, 100000);
    expect(model.bets.length, 0);
  });

  test('placeBet deducts cash and records the bet', () {
    final storage = FakePortfolioStorage();
    final model = PortfolioModel(storage: storage);
    int notifyCount = 0;
    model.addListener(() => notifyCount++);

    final bet = Bet(
      marketId: 'mkt_001',
      side: BetSide.yes,
      shares: 10,
      pricePaidCents: 50,
      placedAt: DateTime(2025, 1, 1),
    );

    expect(model.cashCents, 100000);
    expect(model.bets.length, 0);
    expect(storage.saveCount, 0);

    final ok = model.placeBet(bet);

    expect(ok, isTrue);
    expect(model.cashCents, 100000 - 500);
    expect(model.bets.length, 1);
    expect(storage.saveCount, 1);
    expect(notifyCount, 1);
  });

  test('placeBet rejects when cash is insufficient', () {
    final storage = FakePortfolioStorage();
    final model = PortfolioModel(storage: storage);

    final bet = Bet(
      marketId: 'mkt_001',
      side: BetSide.yes,
      shares: 100,
      pricePaidCents: 99000, // would cost 9,900,000¢ — way over $1000
      placedAt: DateTime(2025, 1, 1),
    );

    expect(model.cashCents, 100000);
    expect(model.bets, isEmpty);
    expect(storage.saveCount, 0); 

    final ok = model.placeBet(bet);

    expect(ok, isFalse);
    expect(model.cashCents, 100000);
    expect(model.bets, isEmpty);
    expect(storage.saveCount, 0); // and crucially: NO save on rejection
  });

  test('the model keeps defaults if no fake data', () async {
    final storage = FakePortfolioStorage();
    final model = PortfolioModel(storage: storage);
    
    await model.load();

    expect(model.cashCents, 100000);
    expect(model.bets, isEmpty);
  });

  test('the model accepts fake data from load()', () async {
    final bet = Bet(
      marketId: 'mkt_001',
      side: BetSide.yes,
      shares: 100,
      pricePaidCents: 10000,
      placedAt: DateTime(2025, 1, 1),
    );

    final storage = FakePortfolioStorage();
    await storage.save(90000, [bet]);
    final model = PortfolioModel(storage: storage);

    await model.load();

    expect(model.cashCents, 90000);
    expect(model.bets, [bet]);
  });

  test('placeBet actually saves', () async {
    final storage = FakePortfolioStorage();
    final model = PortfolioModel(storage: storage);

    final bet = Bet(
      marketId: 'mkt_001',
      side: BetSide.yes,
      shares: 100,
      pricePaidCents: 500,
      placedAt: DateTime(2025, 1, 1),
    );

    model.placeBet(bet);

    await Future.delayed(Duration.zero);

    expect(storage.saveCount, 1);
  });
}