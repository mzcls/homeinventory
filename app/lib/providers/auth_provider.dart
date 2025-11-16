import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user.dart'; // Import the new User model

enum AuthStatus { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthProvider with ChangeNotifier {
  User? _user; // Store User object
  String? _token; // Reintroduce token storage
  AuthStatus _status = AuthStatus.Uninitialized;
  final AuthService _authService = AuthService();

  User? get user => _user;
  String? get token => _token; // Now directly returns _token
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.Authenticated;
  bool get isAdmin => _user?.isAdmin ?? false; // New getter for admin status

  Future<void> login(String token) async {
    final prefs = await SharedPreferences.getInstance();
    print('AuthProvider: Attempting to store token: $token');
    await prefs.setString('token', token); // Store token
    _token = token; // Set _token
    print('AuthProvider: Token stored. Retrieved token: ${prefs.getString('token')}');

    // Fetch user info after login to get isAdmin status
    try {
      final response = await _authService.getUserInfo(token);
      if (response.statusCode == 200) {
        _user = User.fromJson(response.data['data']);
        _status = AuthStatus.Authenticated;
        print('AuthProvider: User info fetched successfully. User: ${_user?.username}, isAdmin: ${_user?.isAdmin}');
      } else {
        _user = null;
        _status = AuthStatus.Unauthenticated;
        _token = null; // Clear token
        await prefs.remove('token');
        print('AuthProvider: Failed to fetch user info after login. Status: ${response.statusCode}');
      }
    } catch (e) {
      _user = null;
      _status = AuthStatus.Unauthenticated;
      _token = null; // Clear token
      await prefs.remove('token');
      print('AuthProvider: Exception fetching user info after login: $e');
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _token = null; // Clear token
    _status = AuthStatus.Unauthenticated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('AuthProvider: User logged out, token removed.');
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    _status = AuthStatus.Authenticating;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      _status = AuthStatus.Unauthenticated;
      print('AuthProvider: No token found in SharedPreferences.');
      notifyListeners();
      return;
    }
    final storedToken = prefs.getString('token');
    if (storedToken == null) {
      _status = AuthStatus.Unauthenticated;
      print('AuthProvider: Stored token is null.');
      notifyListeners();
      return;
    }
    _token = storedToken; // Set _token
    print('AuthProvider: Token found in SharedPreferences: $_token');

    try {
      final response = await _authService.getUserInfo(storedToken);
      if (response.statusCode == 200) {
        _user = User.fromJson(response.data['data']);
        _status = AuthStatus.Authenticated;
        print('AuthProvider: Auto-login successful. User: ${_user?.username}, isAdmin: ${_user?.isAdmin}');
      } else {
        await prefs.remove('token');
        _user = null;
        _token = null; // Clear token
        _status = AuthStatus.Unauthenticated;
        print('AuthProvider: Auto-login failed. Failed to fetch user info. Status: ${response.statusCode}');
      }
    } catch (e) {
      await prefs.remove('token');
      _user = null;
      _token = null; // Clear token
      _status = AuthStatus.Unauthenticated;
      print('AuthProvider: Exception during auto-login: $e');
    }
    notifyListeners();
  }
}