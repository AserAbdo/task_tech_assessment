import '../models/user.dart';
import 'api_service.dart';

/// Service for handling authentication operations
class AuthService {
  final ApiService _apiService = ApiService();

  /// Register a new user
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiService.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final user = User.fromJson(data['user'] as Map<String, dynamic>);
        final token = data['token'] as String;

        await _apiService.setToken(token);

        return AuthResult(success: true, user: user, token: token);
      }

      return AuthResult(
        success: false,
        message: response['message'] ?? 'Registration failed',
      );
    } on ApiException catch (e) {
      return AuthResult(success: false, message: e.message, errors: e.errors);
    }
  }

  /// Login with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final user = User.fromJson(data['user'] as Map<String, dynamic>);
        final token = data['token'] as String;

        await _apiService.setToken(token);

        return AuthResult(success: true, user: user, token: token);
      }

      return AuthResult(
        success: false,
        message: response['message'] ?? 'Login failed',
      );
    } on ApiException catch (e) {
      return AuthResult(success: false, message: e.message, errors: e.errors);
    }
  }

  /// Get current authenticated user
  Future<AuthResult> getCurrentUser() async {
    try {
      final response = await _apiService.get('/me');

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final user = User.fromJson(data['user'] as Map<String, dynamic>);

        return AuthResult(success: true, user: user);
      }

      return AuthResult(
        success: false,
        message: response['message'] ?? 'Failed to get user',
      );
    } on ApiException catch (e) {
      return AuthResult(success: false, message: e.message);
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      await _apiService.post('/logout');
    } catch (e) {
      // Ignore errors during logout
    } finally {
      await _apiService.clearToken();
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _apiService.isAuthenticated;
}

/// Result class for authentication operations
class AuthResult {
  final bool success;
  final User? user;
  final String? token;
  final String? message;
  final Map<String, dynamic>? errors;

  AuthResult({
    required this.success,
    this.user,
    this.token,
    this.message,
    this.errors,
  });

  /// Get first error message from validation errors
  String? getFirstError() {
    if (errors != null && errors!.isNotEmpty) {
      final firstErrors = errors!.values.first;
      if (firstErrors is List && firstErrors.isNotEmpty) {
        return firstErrors.first.toString();
      }
    }
    return message;
  }
}
