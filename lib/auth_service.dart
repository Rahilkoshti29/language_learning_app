// lib/core/services/auth_service.dart
// Local auth only — no Firebase required.
// Stores user profile in SharedPreferences.
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const _keyName     = 'user_name';
  static const _keyEmail    = 'user_email';
  static const _keyLoggedIn = 'is_logged_in';

  String _displayName = 'Learner';
  String _email       = '';
  bool   _loggedIn    = false;

  bool   get isLoggedIn      => _loggedIn;
  String get userDisplayName => _displayName;
  String get userEmail       => _email;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _loggedIn    = prefs.getBool(_keyLoggedIn) ?? false;
    _displayName = prefs.getString(_keyName)   ?? 'Learner';
    _email       = prefs.getString(_keyEmail)  ?? '';
  }

  Future<bool> signIn({String name = 'Learner', String email = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    _displayName = name.isEmpty ? 'Learner' : name;
    _email       = email;
    _loggedIn    = true;
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyName, _displayName);
    await prefs.setString(_keyEmail, _email);
    return true;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    _loggedIn    = false;
    _displayName = 'Learner';
    _email       = '';
  }
}