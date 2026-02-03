import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../../../core/constants/env.dart';
import '../../../../../core/utils/logger.dart';

abstract class FlutterwavePaymentDataSource {
  Future<Map<String, dynamic>> initializePayment({
    required String orderId,
    required double amount,
    required String email,
    required Map<String, dynamic>? metadata,
  });

  Future<Map<String, dynamic>> verifyPayment({
    required String reference,
    required String orderId,
  });

  Future<Map<String, dynamic>> getTransactionStatus({
    required String reference,
  });
}

class FirebaseFlutterwavePaymentDataSource
    implements FlutterwavePaymentDataSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  FirebaseFlutterwavePaymentDataSource();

  @override
  Future<Map<String, dynamic>> initializePayment({
    required String orderId,
    required double amount,
    required String email,
    required Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      Logger.logBasic('Initializing Flutterwave v3 payment for order: $orderId');

      // Generate unique transaction reference
      final txRef =
          'FLW${DateTime.now().millisecondsSinceEpoch}${_uuid.v4().substring(0, 8).toUpperCase()}';

      // Extract card details from metadata
      final cardDetails = metadata?['cardDetails'] as Map<String, dynamic>?;
      final cardNumber = cardDetails?['cardNumber']?.toString() ?? '';
      final expiryMonth = cardDetails?['expiryMonth']?.toString() ?? '12';
      final expiryYear = cardDetails?['expiryYear']?.toString() ?? '2025';
      final cvv = cardDetails?['cvv']?.toString() ?? '123';

      // Validate required card details
      if (cardNumber.isEmpty || cardNumber.length < 13) {
        throw Exception('Invalid card number provided');
      }
      if (cvv.isEmpty || cvv.length < 3) {
        throw Exception('Invalid CVV provided');
      }

      // Prepare v3 payload for Firebase Functions
      final payload = {
        'card_number': cardNumber,
        'cvv': cvv,
        'expiry_month': expiryMonth,
        'expiry_year': expiryYear,
        'currency': 'NGN',
        'amount': amount,
        'email': email,
        'fullname': metadata?['userName'] ?? 'Customer User',
        'phone_number': metadata?['phoneNumber'] ?? '08012345678',
        'tx_ref': txRef,
        'redirect_url': metadata?['redirectUrl'] ?? 'https://example.com/success',
        'order_id': orderId,
        'user_id': user.uid,
        'meta': {
          'order_id': orderId,
          'user_id': user.uid,
          'source': 'food_app',
          if (metadata != null) ...metadata,
        },
      };

      Logger.logBasic('Calling Firebase Function for Flutterwave v3 charge');

      // Call Firebase Function (which calls Flutterwave v3 API)
      final response = await http.post(
        Uri.parse('${Env.firebaseCloudFunctionsUrl}/initializeFlutterwavePayment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Logger.logSuccess(
          'Flutterwave v3 payment initialization successful: $txRef',
        );

        return {
          'success': true,
          'reference': txRef,
          'authorizationUrl': data['authorization_url'] ?? data['data']?['authorization_url'],
          'accessCode': data['access_code'],
          'amount': amount,
          'paymentData': data,
        };
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
        Logger.logError('Flutterwave API Error: $errorMessage');
        throw Exception('Flutterwave v3 API error: $errorMessage');
      }
    } catch (e) {
      Logger.logError('Payment initialization failed: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> verifyPayment({
    required String reference,
    required String orderId,
  }) async {
    try {
      Logger.logBasic('Verifying Flutterwave v3 payment: $reference');

      // Call Firebase Function to verify payment
      final response = await http.post(
        Uri.parse('${Env.firebaseCloudFunctionsUrl}/verifyFlutterwavePayment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'reference': reference,
          'order_id': orderId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Logger.logSuccess(
          'Flutterwave v3 payment verification completed: ${data['status']}',
        );

        return {
          'success': true,
          'status': data['status'],
          'amount': data['amount'],
          'currency': data['currency'],
          'reference': data['tx_ref'] ?? data['reference'],
          'flutterwaveReference': data['flw_ref'] ?? data['id'],
          'paidAt': data['paid_at'] ?? data['created_at'],
          'channel': data['payment_type'],
          'customer': {
            'email': data['customer']?['email'],
            'name': data['customer']?['name'],
          },
          'meta': data['meta'] ?? {},
        };
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? errorData['error'] ?? 'Unknown error';
        throw Exception(
          'Flutterwave v3 payment verification failed: $errorMessage',
        );
      }
    } catch (e) {
      Logger.logError('Payment verification failed: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getTransactionStatus({
    required String reference,
  }) async {
    try {
      Logger.logBasic('Getting Flutterwave v3 transaction status: $reference');

      // Call Firebase Function to get transaction status
      final response = await http.get(
        Uri.parse('${Env.firebaseCloudFunctionsUrl}/getFlutterwaveTransactionStatus?reference=$reference'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Logger.logSuccess('Flutterwave v3 transaction status retrieved: ${data['status']}');

        return {
          'success': true,
          'status': data['status'],
          'amount': data['amount'],
          'reference': data['tx_ref'] ?? data['reference'],
          'paidAt': data['paid_at'] ?? data['created_at'],
          'details': {
            'currency': data['currency'],
            'channel': data['payment_type'],
            'customer': {
              'email': data['customer']?['email'],
              'name': data['customer']?['name'],
            },
            'meta': data['meta'] ?? {},
          },
        };
      } else {
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? errorData['error'] ?? 'Unknown error';
        throw Exception('Failed to get transaction status: $errorMessage');
      }
    } catch (e) {
      Logger.logError('Failed to get transaction status: $e');
      rethrow;
    }
  }
}
