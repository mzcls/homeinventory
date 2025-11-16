import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart'; // Import DioError for error handling
import '../services/auth_service.dart';
import '../models/user.dart'; // Import the new User model

enum AuthStatus { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class AuthProvider with ChangeNotifier {
  static const String _TOKEN_KEY = 'token';
  static const String _USERNAME_KEY = 'username'; // New constant
  static const String _PASSWORD_KEY = 'password'; // New constant

  User? _user; // Store User object
  String? _token; // Reintroduce token storage
  AuthStatus _status = AuthStatus.Uninitialized;
  final AuthService _authService = AuthService();

  User? get user => _user;
  String? get token => _token; // Now directly returns _token
  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.Authenticated;
  bool get isAdmin => _user?.isAdmin ?? false; // New getter for admin status

  // Helper to save username and password
  Future<void> _saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_USERNAME_KEY, username);
    await prefs.setString(_PASSWORD_KEY, password);
    print('AuthProvider: Credentials saved - Username: $username');
  }

  // Helper to clear username and password
  Future<void> _clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_USERNAME_KEY);
    await prefs.remove(_PASSWORD_KEY);
    print('AuthProvider: Credentials cleared.');
  }

  // Get saved username
  Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_USERNAME_KEY);
  }

  // Get saved password
  Future<String?> getSavedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_PASSWORD_KEY);
  }

  Future<bool> login(String username, String password, {bool rememberMe = true}) async {
    _status = AuthStatus.Authenticating;
    notifyListeners();

    try {
      final response = await _authService.login(username, password);
      if (response.statusCode == 200) {
        final token = response.data['data']['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_TOKEN_KEY, token);
        _token = token;

        if (rememberMe) {
          await _saveCredentials(username, password);
        } else {
          await _clearCredentials();
        }

        // Fetch user info after login to get isAdmin status
        final userResponse = await _authService.getUserInfo(token);
        if (userResponse.statusCode == 200) {
          _user = User.fromJson(userResponse.data['data']);
          _status = AuthStatus.Authenticated;
          print('AuthProvider: Login successful. User: ${_user?.username}, isAdmin: ${_user?.isAdmin}');
          notifyListeners();
          return true;
        } else {
          // Failed to fetch user info, treat as unauthenticated
          await prefs.remove(_TOKEN_KEY);
          _token = null;
          _user = null;
          _status = AuthStatus.Unauthenticated;
          print('AuthProvider: Login failed: Could not fetch user info. Status: ${userResponse.statusCode}');
          notifyListeners();
          return false;
        }
      } else {
        // Login failed (e.g., wrong credentials)
        _status = AuthStatus.Unauthenticated;
        print('AuthProvider: Login failed. Status: ${response.statusCode}, Message: ${response.data}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _status = AuthStatus.Unauthenticated;
      print('AuthProvider: Exception during login: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _status = AuthStatus.Unauthenticated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_TOKEN_KEY);
    await _clearCredentials(); // Clear saved credentials on logout
    print('AuthProvider: User logged out, token and credentials removed.');
    notifyListeners();
  }

  Future<Map<String, dynamic>> changePassword(String token, String newPassword) async {
    try {
      final response = await _authService.changePassword(token, newPassword);
      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return {'success': true, 'message': response.data['message'] ?? '密码修改成功'};
      }
      return {'success': false, 'message': response.data['message'] ?? '密码修改失败'};
    } on DioError catch (e) {
      debugPrint('DioError changing password: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.data != null && e.response?.data['detail'] != null) {
        return {'success': false, 'message': e.response?.data['detail']};
      }
      return {'success': false, 'message': '网络错误或服务器无响应'};
    } catch (e) {
      debugPrint('Unknown error changing password: $e');
      return {'success': false, 'message': '发生未知错误'};
    }
  }

  Future<void> tryAutoLogin() async {
    debugPrint('AuthProvider: tryAutoLogin started.');
    _status = AuthStatus.Authenticating;
    notifyListeners(); // Notify listeners that authentication is in progress

    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(_TOKEN_KEY);

    if (storedToken == null) {
      debugPrint('AuthProvider: No token found in SharedPreferences for auto-login. Setting status to Unauthenticated.');
      _status = AuthStatus.Unauthenticated;
      notifyListeners(); // Notify listeners of status change
      return;
    }
    _token = storedToken;
    debugPrint('AuthProvider: Token found: $_token. Attempting to get user info.');

    try {
      final response = await _authService.getUserInfo(storedToken);
      debugPrint('AuthProvider: getUserInfo response status: ${response.statusCode}');
      debugPrint('AuthProvider: getUserInfo response data: ${response.data}');

      if (response.statusCode == 200) {
        _user = User.fromJson(response.data['data']);
        _status = AuthStatus.Authenticated;
        debugPrint('AuthProvider: Auto-login successful. User: ${_user?.username}, isAdmin: ${_user?.isAdmin}. Setting status to Authenticated.');
      } else {
        await prefs.remove(_TOKEN_KEY);
        _token = null;
        _user = null;
        _status = AuthStatus.Unauthenticated;
        debugPrint('AuthProvider: Auto-login failed. Failed to fetch user info. Status: ${response.statusCode}. Setting status to Unauthenticated.');
      }
    } on DioError catch (e) {
      await prefs.remove(_TOKEN_KEY);
      _token = null;
      _user = null;
      _status = AuthStatus.Unauthenticated;
      debugPrint('AuthProvider: DioError during auto-login: ${e.message}. Setting status to Unauthenticated.');
      if (e.response != null) {
        debugPrint('AuthProvider: DioError Response Status: ${e.response!.statusCode}');
        debugPrint('AuthProvider: DioError Response Data: ${e.response!.data}');
      }
    } catch (e) {
      await prefs.remove(_TOKEN_KEY);
      _token = null;
      _user = null;
      _status = AuthStatus.Unauthenticated;
      debugPrint('AuthProvider: Unknown exception during auto-login: $e. Setting status to Unauthenticated.');
    }
    notifyListeners(); // Notify listeners of final status change
    debugPrint('AuthProvider: tryAutoLogin finished. Final status: $_status.');
  }
}