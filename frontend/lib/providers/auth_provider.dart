import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  bool _isAuthenticated = false;
  String? _userToken;
  String? _userId;

  bool get isAuthenticated => _isAuthenticated;
  String? get userToken => _userToken;
  String? get userId => _userId;

  Future<void> login(String email, String password) async {
    try {
      // TODO: Implement actual API call
      // For now, we'll simulate a successful login
      _userToken = 'dummy_token';
      _userId = 'dummy_user_id';
      _isAuthenticated = true;

      await _storage.write(key: 'user_token', value: _userToken);
      await _storage.write(key: 'user_id', value: _userId);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _userToken = null;
    _userId = null;
    _isAuthenticated = false;

    await _storage.delete(key: 'user_token');
    await _storage.delete(key: 'user_id');

    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _userToken = await _storage.read(key: 'user_token');
    _userId = await _storage.read(key: 'user_id');
    _isAuthenticated = _userToken != null;
    notifyListeners();
  }
}
