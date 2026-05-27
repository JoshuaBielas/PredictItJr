import 'package:flutter/foundation.dart';
import '../models/bet.dart';

// I got help from AI for this file

class PortfolioModel extends ChangeNotifier {
  int _cashCents = 100000; // $1,000 starting balance
  final List<Bet> _bets = [];

  int get cashCents => _cashCents;

  // Unmodifiable view: all mutation MUST go through placeBet, so
  // there's exactly one place that changes state. A6 will exploit
  // this to add persistence in one line.
  List<Bet> get bets => List.unmodifiable(_bets);

  /// Returns true on success, false if the user can't afford it.
  bool placeBet(Bet bet) {
    if (bet.totalCostCents > _cashCents) return false;
    _bets.add(bet);
    _cashCents -= bet.totalCostCents;
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
    notifyListeners();
  }
}