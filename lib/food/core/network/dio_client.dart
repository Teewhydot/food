import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:food/food/core/utils/logger.dart';

import '../constants/env.dart';

class DioClient {
  DioClient() {
    _dio = Dio();
    _setupInterceptors();
    _setupSecurity();
  }
  // API versioning constants
  static const String currentApiVersion = 'v1';
  static const String legacyApiVersion = 'v1';
  static const String betaApiVersion = 'v2-beta';

  late final Dio _dio;
  void _setupSecurity() {
    // Firebase Auth will handle authentication tokens automatically
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
      baseUrl: Env.golangBaseUrl!,
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
          // Track successful request performance
          final requestId =
              response.requestOptions.extra['request_id'] as String?;
          final startTime =
              response.requestOptions.extra['start_time'] as DateTime?;

          if (requestId != null && startTime != null) {
            final duration = DateTime.now().difference(startTime);
            final endpoint =
                '${response.requestOptions.method} ${response.requestOptions.path}';
          }

          // Check for API version deprecation warnings
          final apiVersion = response.requestOptions.headers['API-Version'];
          if (apiVersion != null) {
            _handleVersionDeprecation(apiVersion.toString(), response);
          }

          handler.next(response);
        },
        onError: (error, handler) {
          // Track failed request performance
          final requestId = error.requestOptions.extra['request_id'] as String?;
          final startTime =
              error.requestOptions.extra['start_time'] as DateTime?;

          if (requestId != null && startTime != null) {
            final duration = DateTime.now().difference(startTime);
            final endpoint =
                '${error.requestOptions.method} ${error.requestOptions.path}';
          }
        },
      ),
    );
  }

  // AppException _handleHttpError(Response<dynamic> response) {
  //   final statusCode = response.statusCode ?? 0;
  //   final message = _extractErrorMessage(response.data);
  //
  //   switch (statusCode) {
  //     case 400:
  //       return ValidationException(message, statusCode);
  //     case 401:
  //       return AuthException(message, statusCode);
  //     case 403:
  //       return PermissionException(message, statusCode);
  //     case 404:
  //       return NotFoundException(message, statusCode);
  //     case 409:
  //       return ConflictException(message, statusCode);
  //     case 422:
  //       return ValidationException(message, statusCode);
  //     case 429:
  //       return ServerException(
  //         'Too many requests. Please try again later.',
  //         statusCode,
  //       );
  //     case 500:
  //     case 502:
  //     case 503:
  //     case 504:
  //       return ServerException(
  //         'Server error. Please try again later.',
  //         statusCode,
  //       );
  //     default:
  //       return ServerException(message, statusCode);
  //   }
  // }

  String _extractErrorMessage(data) {
    if (data is Map<String, dynamic>) {
      // Try common error message fields
      if (data.containsKey('message')) {
        return data['message'].toString();
      }
      if (data.containsKey('error')) {
        final error = data['error'];
        if (error is String) return error;
        if (error is Map && error.containsKey('message')) {
          return error['message'].toString();
        }
      }
      if (data.containsKey('errors')) {
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
        if (errors is Map) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            return firstError.first.toString();
          }
          return firstError.toString();
        }
      }
    }
    return 'An error occurred while processing your request.';
  }

  // HTTP Methods
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
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
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

  // Add authorization header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove authorization header
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
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
      data: data,
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
