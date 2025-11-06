import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:food/food/core/utils/logger.dart';

import '../constants/env.dart';
import 'jwt_auth_interceptor.dart';

class DioClient {
  late final JwtAuthInterceptor _jwtInterceptor;

  DioClient() {
    _dio = Dio();
    _jwtInterceptor = JwtAuthInterceptor();
    _setupInterceptors();
    _setupSecurity();
    _loadTokenOnInit();
  }

  /// Load token from cache on initialization
  Future<void> _loadTokenOnInit() async {
    await _jwtInterceptor.loadToken();
  }
  // API versioning constants
  static const String currentApiVersion = 'v1';
  static const String legacyApiVersion = 'v1';
  static const String betaApiVersion = 'v2-beta';

  late final Dio _dio;
  void _setupSecurity() {
    // Add JWT authentication interceptor
    _dio.interceptors.add(_jwtInterceptor);

    // Add basic security headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add basic security headers
          options.headers['Content-Type'] = 'application/json';
          options.headers['Accept'] = 'application/json';
          handler.next(options);
        },
      ),
    );
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.options = BaseOptions(
      baseUrl: Env.golangBaseUrl,
      connectTimeout: 30 * 1000, // 30 seconds
      receiveTimeout: 30 * 1000, // 30 seconds
      sendTimeout: 30 * 1000, // 30 seconds
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'API-Version': currentApiVersion,
        'Accept-Version': currentApiVersion,
      },
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          logPrint: (object) => Logger.logBasic(object.toString()),
        ),
      );
    }

    // Add performance monitoring interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Start tracking request performance
          final requestId =
              '${options.method}_${options.path}_${DateTime.now().millisecondsSinceEpoch}';
          options.extra['request_id'] = requestId;
          options.extra['start_time'] = DateTime.now();
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? requestBody,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post<T>(
      path,
      data: requestBody,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // Add authorization header (deprecated - handled by interceptor)
  @Deprecated('Token management is now handled by JwtAuthInterceptor')
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove authorization header and clear stored tokens
  Future<void> clearAuthToken() async {
    _dio.options.headers.remove('Authorization');
    await _jwtInterceptor.clearTokens();
  }

  // Update base URL
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  // Version-specific HTTP methods
  Future<Response<T>> getWithVersion<T>(
    String path, {
    String? apiVersion,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final versionedOptions = _createVersionedOptions(options, apiVersion);
    return get<T>(
      path,
      queryParameters: queryParameters,
      options: versionedOptions,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> postWithVersion<T>(
    String path, {
    String? apiVersion,
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final versionedOptions = _createVersionedOptions(options, apiVersion);
    return post<T>(
      path,
      requestBody: data,
      queryParameters: queryParameters,
      options: versionedOptions,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> putWithVersion<T>(
    String path, {
    String? apiVersion,
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final versionedOptions = _createVersionedOptions(options, apiVersion);
    return put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: versionedOptions,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patchWithVersion<T>(
    String path, {
    String? apiVersion,
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final versionedOptions = _createVersionedOptions(options, apiVersion);
    return patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: versionedOptions,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> deleteWithVersion<T>(
    String path, {
    String? apiVersion,
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final versionedOptions = _createVersionedOptions(options, apiVersion);
    return delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: versionedOptions,
      cancelToken: cancelToken,
    );
  }

  /// Create options with specific API version headers
  Options _createVersionedOptions(Options? baseOptions, String? apiVersion) {
    final version = apiVersion ?? currentApiVersion;
    final headers = Map<String, dynamic>.from(baseOptions?.headers ?? {});

    headers['API-Version'] = version;
    headers['Accept-Version'] = version;

    return Options(
      method: baseOptions?.method,
      headers: headers,
      extra: baseOptions?.extra,
      responseType: baseOptions?.responseType,
      contentType: baseOptions?.contentType,
      validateStatus: baseOptions?.validateStatus,
      receiveDataWhenStatusError: baseOptions?.receiveDataWhenStatusError,
      followRedirects: baseOptions?.followRedirects,
      maxRedirects: baseOptions?.maxRedirects,
      requestEncoder: baseOptions?.requestEncoder,
      responseDecoder: baseOptions?.responseDecoder,
      listFormat: baseOptions?.listFormat,
    );
  }

  /// Check if API version is supported
  bool isVersionSupported(String version) {
    const supportedVersions = [
      currentApiVersion,
      legacyApiVersion,
      betaApiVersion,
    ];
    return supportedVersions.contains(version);
  }

  /// Get the latest stable API version
  String getLatestVersion() => currentApiVersion;

  /// Get the beta API version
  String getBetaVersion() => betaApiVersion;

  /// Handle version deprecation warnings
  void _handleVersionDeprecation(String version, Response<dynamic> response) {
    final deprecationHeader = response.headers.value('X-API-Deprecation');
    final sunsetHeader = response.headers.value('Sunset');

    if (deprecationHeader != null) {
      Logger.logWarning(
        'API version $version is deprecated: $deprecationHeader',
      );

      if (sunsetHeader != null) {
        Logger.logWarning(
          'API version $version will be sunset on: $sunsetHeader',
        );
      }
    }
  }
}
