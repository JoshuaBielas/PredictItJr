import 'package:predictit_jr/data/portfolio_storage.dart';
import 'package:predictit_jr/models/bet.dart';

// This fake is so short because it just needs to implement the interface of PortfolioStorage.
// It doesn't need to create its own full methods. Its a fake.
class FakePortfolioStorage implements PortfolioStorage {
  ({int cashCents, List<Bet> bets})? _stored;
  int saveCount = 0;
  int clearCount = 0;

  @override
  Future<void> save(int cashCents, List<Bet> bets) async {
    saveCount++;
    _stored = (cashCents: cashCents, bets: List.of(bets));
  }

  @override
  Future<({int cashCents, List<Bet> bets})?> load() async => _stored;

  @override
  Future<void> clear() async {
    clearCount++;
    _stored = null;
  }
}