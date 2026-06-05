import 'package:flutter/material.dart';
import '../data/theme_storage.dart';

// I got this from AI

class ThemeModel extends ChangeNotifier {
  ThemeModel({ThemeStorage? storage}) : _storage = storage ?? ThemeStorage();

  final ThemeStorage _storage;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    _themeMode = await _storage.load();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _storage.save(mode);
  }
}