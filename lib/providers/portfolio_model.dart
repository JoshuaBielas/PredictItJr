import 'package:flutter/foundation.dart';
import 'package:predictit_jr/data/portfolio_storage.dart';
import '../models/bet.dart';

// I got help from AI for this file

class PortfolioModel extends ChangeNotifier {
  static const int _startingBalanceCents = 100000; // $1,000 starting balance

  PortfolioModel({PortfolioStorage? storage})
      : _storage = storage ?? PortfolioStorage();

  final PortfolioStorage _storage;

  int _cashCents = _startingBalanceCents;
  final List<Bet> _bets = [];

  int get cashCents => _cashCents;
  List<Bet> get bets => List.unmodifiable(_bets);

  /// Load saved state, if any. Safe to call on every launch.
  Future<void> load() async {
    final saved = await _storage.load();
    if (saved == null) return; // first launch — keep defaults
    _cashCents = saved.cashCents;
    _bets
      ..clear()
      ..addAll(saved.bets);
    notifyListeners();
  }

  Future<void> resetAccount() async {
    _cashCents = _startingBalanceCents;
    _bets.clear();
    await _storage.clear();
    notifyListeners();
  }

  /// Returns true on success, false if the user can't afford it.
  bool placeBet(Bet bet) {
    if (bet.totalCostCents > _cashCents) return false;
    _bets.add(bet);
    _cashCents -= bet.totalCostCents;
    _storage.save(_cashCents, _bets);
    notifyListeners();
    return true;
  }

  // I got help from ChatGPT for this extra credit
  void sellPosition(Bet bet) {
    if (!_bets.contains(bet)) {
      return;
    }
    _bets.remove(bet);
    _cashCents += bet.totalCostCents;
    _storage.save(_cashCents, _bets);
    notifyListeners();
  }
}