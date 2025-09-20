import 'dart:convert';
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

  /// Initialize Flutterwave direct charge transaction
  Future<Map<String, dynamic>> initializePayment({
    required String orderId,
    required double amount,
    required String email,
    required String userId,
    Map<String, dynamic>? metadata,
  }) async {
    return await _endpointService.runWithConfig(
      'Initialize Flutterwave Direct Charge',
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
          operationType: 'direct_charge_initialization',
        );

        final response = await http.post(
          Uri.parse('$_baseUrl/initializeFlutterwaveDirectCharge'),
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
          Logger.logSuccess('Flutterwave direct charge initialization successful: ${data['reference']}');
          return data;
        } else {
          final errorBody = response.body;
          Logger.logError('Flutterwave direct charge initialization failed with status ${response.statusCode}: $errorBody');

          try {
            final error = json.decode(errorBody);
            throw Exception('Flutterwave direct charge initialization failed: ${error['message'] ?? error['error'] ?? errorBody}');
          } catch (e) {
            throw Exception('Flutterwave direct charge initialization failed: $errorBody');
          }
        }
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
    );
  }


  /// Get transaction status
  Future<Map<String, dynamic>> getTransactionStatus({
    required String reference,
  }) async {
    return await _endpointService.runWithConfig(
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