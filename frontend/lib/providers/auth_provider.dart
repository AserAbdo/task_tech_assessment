import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  /// Initialize the auth state
  Future<void> init() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.init();

      if (_apiService.isAuthenticated) {
        final result = await _authService.getCurrentUser();
        if (result.success && result.user != null) {
          _user = result.user;
        } else {
          // Token is invalid, clear it
          await _apiService.clearToken();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      if (result.success && result.user != null) {
        _user = result.user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = result.getFirstError() ?? 'Registration failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.login(email: email, password: password);

      if (result.success && result.user != null) {
        _user = result.user;
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = result.getFirstError() ?? 'Login failed';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();

    _user = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Clear any errors
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
