import 'package:dio/dio.dart';
import 'package:food/food/core/services/hive_cache_service.dart';
import 'package:food/food/core/utils/logger.dart';

/// JWT Authentication Interceptor
///
/// Handles token storage and injection for JWT-based authentication.
/// - Intercepts login/register responses to extract and store tokens
/// - Adds Authorization header to all outgoing requests
/// - Loads token from cache on initialization
class JwtAuthInterceptor extends Interceptor {
  final HiveCacheService _cacheService = HiveCacheService.instance;

  // Routes that return authentication tokens
  static const _authRoutes = ['/api/v1/auth/login', '/api/v1/auth/register'];

  /// Load token from cache on initialization
  Future<String?> loadToken() async {
    try {
      final token = await _cacheService.get('access_token');
      if (token != null) {
        Logger.logSuccess('JWT token loaded from cache');
        return token as String;
      }
    } catch (e) {
      Logger.logError('Failed to load token from cache: $e');
    }
    return null;
  }

  /// Store tokens from response
  Future<void> _storeTokens(Map<String, dynamic> data) async {
    try {
      final accessToken = data['access_token'] as String?;
      final refreshToken = data['refresh_token'] as String?;
      final userId = data['id'] as String?;

      if (accessToken != null) {
        await _cacheService.store('access_token', accessToken);
        Logger.logBasic('Access token stored');
      }

      if (refreshToken != null) {
        await _cacheService.store('refresh_token', refreshToken);
        Logger.logBasic('Refresh token stored');
      }

      if (userId != null) {
        await _cacheService.store('user_id', userId);
        Logger.logBasic('User ID stored');
      }

      if (accessToken != null) {
        Logger.logSuccess('Authentication tokens stored successfully');
      }
    } catch (e) {
      Logger.logError('Failed to store tokens: $e');
    }
  }

  /// Clear all stored tokens
  Future<void> clearTokens() async {
    try {
      await _cacheService.remove('access_token');
      await _cacheService.remove('refresh_token');
      await _cacheService.remove('user_id');
      Logger.logSuccess('Authentication tokens cleared');
    } catch (e) {
      Logger.logError('Failed to clear tokens: $e');
    }
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add Authorization header if token exists
    final token = await _cacheService.get('access_token');
    if (token != null && token is String) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Check if this is an auth endpoint response
    final isAuthRoute = _authRoutes.any(
      (route) => response.requestOptions.path.contains(route),
    );

    if (isAuthRoute && response.statusCode == 200) {
      try {
        final data = response.data;

        // Handle different response structures
        Map<String, dynamic>? userData;

        if (data is Map<String, dynamic>) {
          // Check for nested data structure (e.g., {data: {access_token, ...}})
          if (data.containsKey('data') &&
              data['data'] is Map<String, dynamic>) {
            userData = data['data'] as Map<String, dynamic>;
          } else {
            userData = data;
          }

          // Store tokens if present
          if (userData.containsKey('access_token')) {
            await _storeTokens(userData);
          }
        }
      } catch (e) {
        Logger.logError('Error processing auth response: $e');
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    // If we get a 401 Unauthorized, clear tokens
    if (err.response?.statusCode == 401) {
      Logger.logWarning('Received 401 Unauthorized - clearing tokens');
      await clearTokens();
    }

    handler.next(err);
  }
}
