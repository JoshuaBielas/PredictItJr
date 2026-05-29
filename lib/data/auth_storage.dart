import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  // We have a versioned key so if in the future we have a new data model we can 
  // track what we are currently using and update to the new one
  static const String _key = 'auth_v1';

  /// We store a token (here just the username). NEVER the password —
  /// that would compound the plaintext-credentials sin.
  Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}