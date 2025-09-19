import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/env.dart';
import '../utils/logger.dart';
import 'endpoint_service.dart';

class PaystackService {
  final EndpointService _endpointService;
  final String _baseUrl = Env.firebaseCloudFunctionsUrl;

  PaystackService(this._endpointService);

  /// Initialize Paystack payment transaction
  Future<Map<String, dynamic>> initializePayment({
    required String orderId,
    required double amount,
    required String email,
    required String userId,
    Map<String, dynamic>? metadata,
  }) async {
    return await _endpointService.runWithConfig(
      'Initialize Paystack Payment',
      () async {
        // Get Firebase Auth token
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('User not authenticated');
        }

        final idToken = await user.getIdToken();

        final response = await http.post(
          Uri.parse('$_baseUrl/createPaystackTransaction'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: json.encode({
            'orderId': orderId,
            'amount': (amount * 100).toInt(), // Convert to kobo
            'email': email,
            'userId': userId,
            'metadata': metadata ?? {},
          }),
        );

        Logger.logBasic('Response status: ${response.statusCode}');
        Logger.logBasic('Response body: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          Logger.logSuccess('Payment initialization successful: ${data['reference']}');
          return data;
        } else {
          final errorBody = response.body;
          Logger.logError('Payment initialization failed with status ${response.statusCode}: $errorBody');

          try {
            final error = json.decode(errorBody);
            throw Exception('Payment initialization failed: ${error['message'] ?? error['error'] ?? errorBody}');
          } catch (e) {
            throw Exception('Payment initialization failed: $errorBody');
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
      'Verify Paystack Payment',
      () async {
        // Get Firebase Auth token
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('User not authenticated');
        }

        final idToken = await user.getIdToken();

        final response = await http.post(
          Uri.parse('$_baseUrl/verifyPaystackPayment'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: json.encode({
            'reference': reference,
            'orderId': orderId,
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          Logger.logSuccess('Payment verification successful: ${data['status']}');
          return data;
        } else {
          final error = json.decode(response.body);
          throw Exception('Payment verification failed: ${error['error']}');
        }
      },
    );
  }

  /// Get transaction status
  Future<Map<String, dynamic>> getTransactionStatus({
    required String reference,
  }) async {
    return await _endpointService.runWithConfig(
      'Get Transaction Status',
      () async {
        final response = await http.get(
          Uri.parse('$_baseUrl/getTransactionStatus?reference=$reference'),
          headers: {
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          Logger.logSuccess('Transaction status retrieved: ${data['status']}');
          return data;
        } else {
          final error = json.decode(response.body);
          throw Exception('Failed to get transaction status: ${error['error']}');
        }
      },
    );
  }

  /// Launch Paystack payment in web browser
  String getPaymentUrl({
    required String authorizationUrl,
    required String reference,
  }) {
    Logger.logBasic('Generating Paystack payment URL for reference: $reference');
    return authorizationUrl;
  }

  /// Handle payment callback from web browser
  Map<String, dynamic> parsePaymentCallback(String callbackUrl) {
    final uri = Uri.parse(callbackUrl);
    final params = uri.queryParameters;

    Logger.logBasic('Parsing payment callback: ${params['reference']}');

    return {
      'reference': params['reference'],
      'status': params['trxref'] != null ? 'success' : 'failed',
      'trxref': params['trxref'],
    };
  }
}