import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bet.dart';

// I got help from AI on this file

class PortfolioStorage {
  // Versioned key: if the saved shape ever changes, old devices have
  // old data. A version suffix lets us detect and migrate cleanly
  // instead of crashing on a shape mismatch.
  static const _key = 'portfolio_v1';
  static const _v0Key = 'portfolio_v0';

  Future<void> save(int cashCents, List<Bet> bets) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'cashCents': cashCents,
      'bets': bets.map((b) => b.toJson()).toList(),
    };
    await prefs.setString(_key, jsonEncode(data));
  }

  /// Returns null on first launch (no saved data — NOT an error).
  Future<({int cashCents, List<Bet> bets})?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      return _decodePortfolio(raw);
    }

    final oldRaw = prefs.getString(_v0Key);
    if (oldRaw == null) {
      return null;
    }
    final migrated = _decodePortfolio(oldRaw);
    await save(migrated.cashCents, migrated.bets);
    await prefs.remove(_v0Key);
    return migrated;
  }

  ({int cashCents, List<Bet> bets}) _decodePortfolio(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (
      cashCents: data['cashCents'] as int,
      bets: (data['bets'] as List)
          .map((j) => Bet.fromJson(j as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}