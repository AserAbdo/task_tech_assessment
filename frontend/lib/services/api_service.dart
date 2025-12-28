import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, this.statusCode, this.errors});

  @override
  String toString() => message;
}

/// Service for handling all API communications
class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const String tokenKey = 'jwt_token';

  late final Dio _dio;
  String? _token;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and token handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          if (kDebugMode) {
            debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            );
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            debugPrint(
              'ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}',
            );
          }
          return handler.next(e);
        },
      ),
    );
  }

  /// Initialize the service and load stored token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(tokenKey);
  }

  /// Get current token
  String? get token => _token;

  /// Check if user is authenticated
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// Set and store the JWT token
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  /// Clear the stored token
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  /// Handle API errors and convert to ApiException
  ApiException _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return ApiException(
          message: data['message'] ?? 'An error occurred',
          statusCode: e.response?.statusCode,
          errors: data['errors'] as Map<String, dynamic>?,
        );
      }
    }

    // Network or other errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Connection timeout. Please try again.');
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
        );
      default:
        return ApiException(message: 'Something went wrong. Please try again.');
    }
  }

  /// Make a GET request
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a POST request
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a PUT request
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Make a DELETE request
  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
