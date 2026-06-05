import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// I got this from AI

class ThemeStorage {
  static const _key = 'theme_mode_v1';

  Future<void> save(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.toString().split('.').last);
  }

  Future<ThemeMode> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return ThemeMode.system;

    return ThemeMode.values.firstWhere(
      (mode) => mode.toString().split('.').last == raw,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}