import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../../../core/constants/env.dart';
import '../../../../../core/services/api_service/api_constants.dart';
import '../../../../../core/services/card_encryption_service.dart';
import '../../../../../core/services/hive_cache_service.dart';
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
  final CardEncryptionService _encryptionService = CardEncryptionService.instance;
  final HiveCacheService _cacheService = HiveCacheService.instance;
  final Uuid _uuid = const Uuid();

  // In-memory fallback cache
  static String? _memoryToken;
  static DateTime? _memoryTokenExpiry;

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

      Logger.logBasic('Initializing Flutterwave payment for order: $orderId');

      // Get OAuth token
      final token = await _getOAuthToken();

      // Generate unique transaction reference
      final txRef =
          'FLW${DateTime.now().millisecondsSinceEpoch}${_uuid.v4().substring(0, 8).toUpperCase()}';
      final idempotencyKey = _uuid.v4();
      final traceId =
          'flw_direct_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 8)}';

      // Prepare customer name fields from metadata
      final userName = metadata?['userName']?.toString() ?? 'Customer User';
      final nameParts = userName.split(' ');
      final validFirstName =
          nameParts.isNotEmpty && nameParts[0].length >= 2
              ? nameParts[0].substring(
                0,
                nameParts[0].length > 50 ? 50 : nameParts[0].length,
              )
              : 'Customer';
      final validLastName =
          nameParts.length > 1 && nameParts[1].length >= 2
              ? nameParts[1].substring(
                0,
                nameParts[1].length > 50 ? 50 : nameParts[1].length,
              )
              : 'User';
      final validMiddleName =
          nameParts.length > 2 && nameParts[2].length >= 2
              ? nameParts[2].substring(
                0,
                nameParts[2].length > 50 ? 50 : nameParts[2].length,
              )
              : 'Middle';

      // Clean phone number to digits only (7-10 chars)
      final rawPhone = (metadata?['phoneNumber']?.toString() ?? '08012345678')
          .replaceAll(RegExp(r'[^\d]'), '');
      final cleanPhone = rawPhone.replaceAll(
        RegExp(r'^234'),
        '',
      ); // Remove country code if present
      String validPhone = cleanPhone;
      if (validPhone.length < 7) {
        validPhone = '08012345678'; // Default fallback
      } else if (validPhone.length > 10) {
        validPhone = validPhone.substring(0, 10); // Truncate to 10 digits
      }

      // Extract card details from metadata
      final cardDetails = metadata?['cardDetails'] as Map<String, dynamic>?;
      final cardHolderName = cardDetails?['cardHolderName']?.toString() ?? '$validFirstName $validLastName';
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

      // Encrypt card details using CardEncryptionService
      Logger.logBasic('Encrypting card details for secure transmission');
      final encryptedCardData = await _encryptionService.encryptAllCardDetails(
        cardNumber: cardNumber,
        cvv: cvv,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
      );

      // Prepare direct charges payload - exact match to Firebase service
      final payload = {
        'currency': 'NGN',
        'customer': {
          'address': {
            'city': metadata?['address']?['city'] ?? 'Lagos',
            'country': metadata?['address']?['country'] ?? 'NG',
            'line1': metadata?['address']?['line1'] ??
                     metadata?['address']?['street'] ??
                     '123 Main Street',
            'line2': metadata?['address']?['line2'] ??
                     metadata?['address']?['apartment'] ??
                     'Apt 1A',
            'postal_code': metadata?['address']?['postal_code'] ?? '100001',
            'state': metadata?['address']?['state'] ?? 'Lagos',
          },
          'meta': {'user_id': user.uid, 'source': 'food_app'},
          'name': {
            'first': validFirstName,
            'middle': validMiddleName,
            'last': validLastName,
          },
          'phone': {'country_code': '234', 'number': validPhone},
          'email': email,
        },
        'meta': {
          'order_id': orderId,
          'user_id': user.uid,
          'source': 'food_app',
        },
        'payment_method': {
          'card': {
            'billing_address': {
              'city': metadata?['address']?['city'] ?? 'Lagos',
              'country': metadata?['address']?['country'] ?? 'NG',
              'line1': metadata?['address']?['line1'] ??
                       metadata?['address']?['street'] ??
                       '123 Main Street',
              'line2': metadata?['address']?['line2'] ??
                       metadata?['address']?['apartment'] ??
                       'Apt 1A',
              'postal_code': metadata?['address']?['postal_code'] ?? '100001',
              'state': metadata?['address']?['state'] ?? 'Lagos',
            },
            'cof': {
              'enabled': true,
              'agreement_id':
                  'Agreement${DateTime.now().millisecondsSinceEpoch}',
              'trace_id': 'trace_${DateTime.now().millisecondsSinceEpoch}',
            },
            'nonce': _encryptionService.generateSecureNonce(12), // 12 character alphanumeric
            'encrypted_expiry_month': encryptedCardData['encrypted_expiry_month'],
            'encrypted_expiry_year': encryptedCardData['encrypted_expiry_year'],
            'encrypted_card_number': encryptedCardData['encrypted_card_number'],
            'encrypted_cvv': encryptedCardData['encrypted_cvv'],
            'card_holder_name': cardHolderName,
          },
          'type': 'card',
        },
        'amount': amount,
        'reference': txRef,
        'redirect_url':
            metadata?['redirectUrl'] ?? 'https://example.com/success',
      };

      final response = await http.post(
        Uri.parse('${Env.flutterwaveBaseUrl}${ApiConstants.flutterwaveDirectCharges}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Idempotency-Key': idempotencyKey,
          'X-Trace-Id': traceId,
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        Logger.logSuccess(
          'Flutterwave payment initialization successful: $txRef',
        );

        return {
          'success': true,
          'reference': txRef,
          'authorizationUrl':
              data['data']?['next_action']?['redirect_url']?['url'] ??
              data['link'],
          'accessCode': data['access_code'],
          'amount': amount,
          'paymentData': data,
        };
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
        Logger.logError('Flutterwave API Error: $errorMessage');
        throw Exception('Flutterwave Direct Charges API error: $errorMessage');
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
      Logger.logBasic('Verifying Flutterwave payment: $reference');

      // Get OAuth token
      final token = await _getOAuthToken();

      final response = await http.get(
        Uri.parse(
          '${Env.flutterwaveBaseUrl}${ApiConstants.flutterwaveTransactions}/$reference${ApiConstants.flutterwaveTransactionVerify}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Logger.logSuccess(
          'Flutterwave payment verification completed: ${data['status']}',
        );

        return {
          'success': true,
          'status': data['status'],
          'amount': data['amount'],
          'currency': data['currency'],
          'reference': data['tx_ref'] ?? reference,
          'flutterwaveReference': data['flw_ref'] ?? data['id'],
          'paidAt': data['created_at'],
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
          'Flutterwave payment verification failed: $errorMessage',
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
      Logger.logBasic('Getting transaction status: $reference');

      // Get OAuth token
      final token = await _getOAuthToken();

      final response = await http.get(
        Uri.parse(
          '${Env.flutterwaveBaseUrl}${ApiConstants.flutterwaveTransactions}/$reference',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        Logger.logSuccess('Transaction status retrieved: ${data['status']}');

        return {
          'success': true,
          'status': data['status'],
          'amount': data['amount'],
          'reference': data['tx_ref'] ?? reference,
          'paidAt': data['created_at'],
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

  // Private helper methods for OAuth token management
  Future<String> _getOAuthToken() async {
    // Check in-memory cache first
    if (_memoryToken != null && _memoryTokenExpiry != null) {
      if (DateTime.now().isBefore(_memoryTokenExpiry!)) {
        return _memoryToken!;
      }
      _memoryToken = null;
      _memoryTokenExpiry = null;
    }

    // Check Hive cache
    try {
      final cachedToken = await _cacheService.get<String>(
        ApiConstants.flutterwaveOAuthTokenCacheKey,
      );
      if (cachedToken != null &&
          !(await _cacheService.isExpired(
            ApiConstants.flutterwaveOAuthTokenCacheKey,
          ))) {
        return cachedToken;
      }
    } catch (e) {
      // Cache failed, continue to refresh
    }

    // Get new token
    return await _refreshOAuthToken();
  }

  Future<String> _refreshOAuthToken() async {
    try {
      Logger.logBasic('Refreshing Flutterwave OAuth token');

      // Ensure dotenv is loaded before accessing environment variables
      await _ensureDotenvLoaded();

      final clientId = Env.flutterwaveClientId;
      final clientSecret = Env.flutterwaveClientSecret;

      if (!Env.hasFlutterwaveCredentials) {
        throw Exception('Flutterwave OAuth credentials not configured');
      }

      final response = await http.post(
        Uri.parse(Env.flutterwaveOAuthUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'client_credentials',
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data['access_token'];
        final expiresIn = data['expires_in'] ?? 3600;

        // Store in memory cache
        final expiryTime = DateTime.now().add(Duration(seconds: expiresIn - 300));
        _memoryToken = accessToken;
        _memoryTokenExpiry = expiryTime;

        // Try to store in Hive cache as well
        try {
          final expiryDuration = Duration(seconds: expiresIn - 300);
          await _cacheService.store(
            ApiConstants.flutterwaveOAuthTokenCacheKey,
            accessToken,
            expiry: expiryDuration,
          );
        } catch (e) {
          // Hive cache failure is not critical
        }

        Logger.logSuccess('Flutterwave OAuth token refreshed and cached');
        return accessToken;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? errorData['error'] ?? 'OAuth token request failed';
        throw Exception('Failed to get OAuth token: $errorMessage');
      }
    } catch (e) {
      Logger.logError('Failed to refresh OAuth token: $e');
      rethrow;
    }
  }


  // Helper method to ensure dotenv is loaded
  Future<void> _ensureDotenvLoaded() async {
    if (kIsWeb) return; // For web builds, environment variables are already available

    try {
      dotenv.env['FLUTTERWAVE_CLIENT_ID']; // Test access
    } catch (e) {
      await dotenv.load(fileName: ".env");
    }
  }
}
