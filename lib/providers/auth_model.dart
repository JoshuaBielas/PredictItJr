import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../data/auth_storage.dart';
import '../models/user.dart';

// I got help from AI on this

class AuthModel extends ChangeNotifier {
  AuthModel({AuthStorage? storage})
      : _storage = storage ?? AuthStorage();

  final AuthStorage _storage;

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  // This session expiry code is different from normal session expiry because it is 
  // stored locally rather than being stored in a server.
  /// Load any persisted session.
  Future<void> load() async {
    final currentTime = DateTime.now();
    final token = await _storage.load();
    if (token == null) return;
    final decodedToken = jsonDecode(token) as Map<String, dynamic>;
    final username = decodedToken['username'] as String;
    final signInTime = DateTime.parse(decodedToken['signedInAt'] as String);
    final user = await _userByUsername(username); // token == username here
    final timeDifference = currentTime.difference(signInTime);
    final minutesDifference = timeDifference.inMinutes;
    if(minutesDifference > 5){
      await _storage.clear();
      return;
    }
    if (user == null) return; // token doesn't match any user
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> signIn(String username, String password) async {
    final user = await _userByUsername(username);
    if (user == null || user.password != password) return false;
    _currentUser = user;
    // await _storage.save(user.username); // store username as "token"
    final token = {
      'username': user.username,
      'signedInAt': DateTime.now().toIso8601String(),
    };
    await _storage.save(jsonEncode(token));
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _storage.clear();
    notifyListeners();
  }

  Future<User?> _userByUsername(String username) async {
    final raw = await rootBundle.loadString('assets/data/users.json');
    final list = (jsonDecode(raw) as Map<String, dynamic>)['users']
        as List<dynamic>;
    for (final j in list) {
      final u = User.fromJson(j as Map<String, dynamic>);
      if (u.username == username) return u;
    }
    return null;
  }
}