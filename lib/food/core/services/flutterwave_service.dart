import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../constants/env.dart';
import '../utils/logger.dart';
import 'endpoint_service.dart';

class FlutterwaveService {
  final EndpointService _endpointService;
  final String _baseUrl = Env.firebaseCloudFunctionsUrl;
  final Uuid _uuid = const Uuid();

  // Retry configuration
  static const int _maxRetries = 3;
  static const int _baseDelayMs = 1000; // 1 second

  FlutterwaveService(this._endpointService);

  /// Generate headers with idempotency key and trace ID for requests
  Map<String, String> _generateHeaders({
    required String idToken,
    String? operationType,
  }) {
    final idempotencyKey = _uuid.v4();
    final traceId = 'flw_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 8)}';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
      'X-Idempotency-Key': idempotencyKey,
      'X-Trace-Id': traceId,
    };

    Logger.logBasic('Generated headers for ${operationType ?? "request"}: idempotency=$idempotencyKey, trace=$traceId');
    return headers;
  }

  /// Retry mechanism with exponential backoff
  Future<T> _retryRequest<T>(
    String operationName,
    Future<T> Function() operation, {
    bool Function(Exception)? shouldRetry,
  }) async {
    Exception? lastException;

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());

        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(lastException)) {
          Logger.logError('$operationName failed on attempt ${attempt + 1} - not retrying: ${lastException.toString()}');
          throw lastException;
        }

        if (attempt < _maxRetries - 1) {
          // Calculate exponential backoff delay
          final delay = _baseDelayMs * pow(2, attempt);
          final jitter = Random().nextInt(500); // Add jitter up to 500ms
          final totalDelay = delay + jitter;

          Logger.logWarning('$operationName failed on attempt ${attempt + 1} - retrying in ${totalDelay}ms: ${lastException.toString()}');
          await Future.delayed(Duration(milliseconds: totalDelay.toInt()));
        } else {
          Logger.logError('$operationName failed after $_maxRetries attempts: ${lastException.toString()}');
        }
      }
    }

    throw lastException ?? Exception('Unknown error occurred');
  }

  /// Check if an exception is retryable
  bool _isRetryableException(Exception exception) {
    final message = exception.toString().toLowerCase();

    // Network-related errors that should be retried
    if (message.contains('timeout') ||
        message.contains('connection') ||
        message.contains('network') ||
        message.contains('socket')) {
      return true;
    }

    // HTTP status codes that should be retried (5xx server errors)
    if (message.contains('status 5')) {
      return true;
    }

    // 429 Too Many Requests should be retried
    if (message.contains('status 429')) {
      return true;
    }

    // Don't retry client errors (4xx except 429)
    if (message.contains('status 4')) {
      return false;
    }

    // Default to retry for other unknown errors
    return true;
  }

  /// Initialize Flutterwave payment transaction
  Future<Map<String, dynamic>> initializePayment({
    required String orderId,
    required double amount,
    required String email,
    required String userId,
    Map<String, dynamic>? metadata,
  }) async {
    return await _endpointService.runWithConfig(
      'Initialize Flutterwave Payment',
      () async {
        return await _retryRequest(
          'Initialize Flutterwave Payment',
          () async {
            // Get Firebase Auth token
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              throw Exception('User not authenticated');
            }

            final idToken = await user.getIdToken();
            if (idToken == null) {
              throw Exception('Failed to get authentication token');
            }

            // Generate headers with idempotency key and trace ID
            final headers = _generateHeaders(
              idToken: idToken,
              operationType: 'payment_initialization',
            );

            final response = await http.post(
              Uri.parse('$_baseUrl/initializeFlutterwavePayment'),
              headers: headers,
              body: json.encode({
                'orderId': orderId,
                'amount': amount, // Use actual amount, not in kobo for Flutterwave
                'email': email,
                'userId': userId,
                'userName': email.split('@')[0], // Extract username from email
                'metadata': metadata ?? {},
              }),
            );

            Logger.logBasic('Response status: ${response.statusCode}');
            Logger.logBasic('Response body: ${response.body}');

            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              Logger.logSuccess('Flutterwave payment initialization successful: ${data['reference']}');
              return data;
            } else {
              final errorBody = response.body;
              Logger.logError('Flutterwave payment initialization failed with status ${response.statusCode}: $errorBody');

              try {
                final error = json.decode(errorBody);
                throw Exception('Flutterwave payment initialization failed: ${error['message'] ?? error['error'] ?? errorBody}');
              } catch (e) {
                throw Exception('Flutterwave payment initialization failed: $errorBody');
              }
            }
          },
          shouldRetry: _isRetryableException,
        );
      },
    );
  }

  /// Verify payment transaction
  Future<Map<String, dynamic>> verifyPayment({
    required String reference,
    required String orderId,
  }) async {
    return await _endpointService.runWithConfig(
      'Verify Flutterwave Payment',
      () async {
        return await _retryRequest(
          'Verify Flutterwave Payment',
          () async {
            // Get Firebase Auth token
            final user = FirebaseAuth.instance.currentUser;
            if (user == null) {
              throw Exception('User not authenticated');
            }

            final idToken = await user.getIdToken();
            if (idToken == null) {
              throw Exception('Failed to get authentication token');
            }

            // Generate headers with idempotency key and trace ID
            final headers = _generateHeaders(
              idToken: idToken,
              operationType: 'payment_verification',
            );

            final response = await http.post(
              Uri.parse('$_baseUrl/verifyFlutterwavePayment'),
              headers: headers,
              body: json.encode({
                'reference': reference,
                'orderId': orderId,
              }),
            );

            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              Logger.logSuccess('Flutterwave payment verification successful: ${data['status']}');
              return data;
            } else {
              final error = json.decode(response.body);
              throw Exception('Flutterwave payment verification failed: ${error['error']}');
            }
          },
          shouldRetry: _isRetryableException,
        );
      },
    );
  }

  /// Get transaction status
  Future<Map<String, dynamic>> getTransactionStatus({
    required String reference,
  }) async {
    return await _endpointService.runWithConfig(
      'Get Flutterwave Transaction Status',
      () async {
        return await _retryRequest(
          'Get Flutterwave Transaction Status',
          () async {
            final response = await http.get(
              Uri.parse('$_baseUrl/getFlutterwaveTransactionStatus?reference=$reference'),
              headers: {
                'Content-Type': 'application/json',
                'X-Trace-Id': 'flw_status_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 8)}',
              },
            );

            if (response.statusCode == 200) {
              final data = json.decode(response.body);
              Logger.logSuccess('Flutterwave transaction status retrieved: ${data['status']}');
              return data;
            } else {
              final error = json.decode(response.body);
              throw Exception('Failed to get Flutterwave transaction status: ${error['error']}');
            }
          },
          shouldRetry: _isRetryableException,
        );
      },
    );
  }

  /// Launch Flutterwave payment in web browser
  String getPaymentUrl({
    required String authorizationUrl,
    required String reference,
  }) {
    Logger.logBasic('Generating Flutterwave payment URL for reference: $reference');
    return authorizationUrl;
  }

  /// Handle payment callback from web browser
  Map<String, dynamic> parsePaymentCallback(String callbackUrl) {
    final uri = Uri.parse(callbackUrl);
    final params = uri.queryParameters;

    Logger.logBasic('Parsing Flutterwave payment callback: ${params['tx_ref']}');

    return {
      'status': params['status'] ?? 'unknown',
      'tx_ref': params['tx_ref'],
      'transaction_id': params['transaction_id'],
      'flw_ref': params['flw_ref'],
    };
  }
}