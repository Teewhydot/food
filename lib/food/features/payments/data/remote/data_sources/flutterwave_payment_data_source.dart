import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../../../core/constants/env.dart';
import '../../../../../core/services/api_service/api_constants.dart';
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

      // Prepare customer name fields
      final nameParts = (metadata?['userName'] ?? 'Customer User')
          .toString()
          .split(' ');
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
      final rawPhone = (metadata?['phoneNumber'] ?? '08012345678')
          .toString()
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

      // Prepare direct charges payload - exact match to Firebase service
      final payload = {
        'currency': 'NGN',
        'customer': {
          'address': {
            'city': metadata?['address']?['city'] ?? 'Lagos',
            'country': metadata?['address']?['country'] ?? 'NG',
            'line1':
                metadata?['address']?['street'] ??
                metadata?['address']?['line1'] ??
                '123 Main Street',
            'line2': metadata?['address']?['line2'] ?? 'Apt 1A',
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
              'line1':
                  metadata?['address']?['street'] ??
                  metadata?['address']?['line1'] ??
                  '123 Main Street',
              'line2': metadata?['address']?['line2'] ?? 'Apt 1A',
              'postal_code': metadata?['address']?['postal_code'] ?? '100001',
              'state': metadata?['address']?['state'] ?? 'Lagos',
            },
            'cof': {
              'enabled': true,
              'agreement_id':
                  'Agreement${DateTime.now().millisecondsSinceEpoch}',
              'trace_id': 'trace_${DateTime.now().millisecondsSinceEpoch}',
            },
            'nonce': _uuid.v4().substring(0, 12), // 12 character alphanumeric
            'encrypted_expiry_month':
                'sQpvQEb7GrUCjPuEN/NmHiPl', // Demo encrypted value
            'encrypted_expiry_year':
                'sgHNEDkJ/RmwuWWq/RymToU5', // Demo encrypted value
            'encrypted_card_number':
                'sAE3hEDaDQ+yLzo4Py+Lx15OZjBGduHu/DcdILh3En0=', // Demo encrypted value
            'encrypted_cvv':
                'tAUzH7Qjma7diGdi7938F/ESNA==', // Demo encrypted value
            'card_holder_name': '$validFirstName $validLastName',
          },
          'type': 'card',
        },
        'authorization': {
          'otp': {'code': 'string'},
          'type': 'otp',
        },
        'amount': amount,
        'reference': txRef,
        'redirect_url':
            metadata?['redirectUrl'] ?? 'https://example.com/success',
      };

      // Log the complete payload for debugging (similar to Firebase service)
      Logger.logBasic(
        'Complete Flutterwave direct charges payload: ${json.encode(payload)}',
      );

      final directChargesUrl =
          '${Env.flutterwaveBaseUrl}${ApiConstants.flutterwaveDirectCharges}';
      Logger.logBasic('Making HTTP POST request to: $directChargesUrl');
      Logger.logBasic(
        'Request headers: Content-Type: application/json, Authorization: Bearer ${token.substring(0, 15)}..., X-Idempotency-Key: $idempotencyKey, X-Trace-Id: $traceId',
      );

      final response = await http.post(
        Uri.parse(directChargesUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Idempotency-Key': idempotencyKey,
          'X-Trace-Id': traceId,
        },
        body: json.encode(payload),
      );

      Logger.logBasic('Response status: ${response.statusCode}');
      Logger.logBasic('Response received from: $directChargesUrl');

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
        Logger.logError(
          'Flutterwave Direct Charges API Error Response: ${response.body}',
        );
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ?? errorData['error'] ?? 'Unknown error';
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
    try {
      Logger.logBasic('Attempting to get OAuth token...');

      // First try: Check Hive cache
      try {
        final cachedToken = await _cacheService.get<String>(
          ApiConstants.flutterwaveOAuthTokenCacheKey,
        );

        if (cachedToken != null &&
            !(await _cacheService.isExpired(
              ApiConstants.flutterwaveOAuthTokenCacheKey,
            ))) {
          Logger.logBasic('Using Hive cached Flutterwave OAuth token');
          return cachedToken;
        }
      } catch (e) {
        Logger.logWarning('Hive cache failed, trying memory cache: $e');
      }

      // Second try: Check in-memory cache
      if (_memoryToken != null && _memoryTokenExpiry != null) {
        if (DateTime.now().isBefore(_memoryTokenExpiry!)) {
          Logger.logBasic('Using in-memory cached Flutterwave OAuth token');
          return _memoryToken!;
        } else {
          Logger.logBasic('In-memory token expired, clearing...');
          _memoryToken = null;
          _memoryTokenExpiry = null;
        }
      }

      // Third try: Get new token
      Logger.logBasic('No valid cached token found, fetching new token...');
      return await _refreshOAuthToken();
    } catch (e) {
      Logger.logError('Failed to get OAuth token: $e');
      rethrow;
    }
  }

  Future<String> _refreshOAuthToken() async {
    try {
      Logger.logBasic('Refreshing Flutterwave OAuth token');

      // Ensure dotenv is loaded before accessing environment variables
      await _ensureDotenvLoaded();

      // Check each environment variable individually to identify the issue
      String? clientId;
      String? clientSecret;
      String? oauthUrl;

      try {
        clientId = Env.flutterwaveClientId;
        Logger.logBasic('✅ Client ID retrieved: ${clientId?.substring(0, 8)}...');
      } catch (e) {
        Logger.logError('❌ Failed to get Client ID: $e');
        throw Exception('Flutterwave Client ID not accessible: $e');
      }

      try {
        clientSecret = Env.flutterwaveClientSecret;
        Logger.logBasic('✅ Client Secret retrieved: ${clientSecret != null ? 'Configured' : 'Not Configured'}');
      } catch (e) {
        Logger.logError('❌ Failed to get Client Secret: $e');
        throw Exception('Flutterwave Client Secret not accessible: $e');
      }

      try {
        oauthUrl = Env.flutterwaveOAuthUrl;
        Logger.logBasic('✅ OAuth URL retrieved: $oauthUrl');
      } catch (e) {
        Logger.logError('❌ Failed to get OAuth URL: $e');
        throw Exception('Flutterwave OAuth URL not accessible: $e');
      }

      if (clientId == null || clientId.isEmpty) {
        throw Exception('Flutterwave Client ID is null or empty');
      }

      if (clientSecret == null || clientSecret.isEmpty) {
        throw Exception('Flutterwave Client Secret is null or empty');
      }

      Logger.logBasic('✅ All credentials validated, making OAuth request...');

      http.Response response;
      try {
        response = await http.post(
          Uri.parse(oauthUrl),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'grant_type': 'client_credentials',
            'client_id': clientId,
            'client_secret': clientSecret,
          },
        );
        Logger.logBasic('✅ HTTP request completed successfully');
      } catch (e) {
        Logger.logError('❌ HTTP request failed: $e');
        throw Exception('OAuth HTTP request failed: $e');
      }

      Logger.logBasic('OAuth response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data;
        try {
          data = json.decode(response.body);
          Logger.logBasic('✅ Response JSON decoded successfully');
        } catch (e) {
          Logger.logError('❌ Failed to decode JSON response: $e');
          Logger.logError('Raw response body: ${response.body}');
          throw Exception('Failed to decode OAuth response: $e');
        }

        final accessToken = data['access_token'];
        final expiresIn = data['expires_in'] ?? 3600; // Default to 1 hour

        if (accessToken == null) {
          Logger.logError('❌ No access_token in response: $data');
          throw Exception('OAuth response missing access_token');
        }

        // Store in memory cache (always works)
        final expiryTime = DateTime.now().add(Duration(seconds: expiresIn - 300));
        _memoryToken = accessToken;
        _memoryTokenExpiry = expiryTime;
        Logger.logSuccess('Flutterwave OAuth token stored in memory cache');

        // Try to store in Hive cache (may fail, but that's okay)
        try {
          final expiryDuration = Duration(seconds: expiresIn - 300);
          await _cacheService.store(
            ApiConstants.flutterwaveOAuthTokenCacheKey,
            accessToken,
            expiry: expiryDuration,
          );
          Logger.logSuccess('Flutterwave OAuth token also stored in Hive cache');
        } catch (e) {
          Logger.logWarning('Failed to store token in Hive cache (using memory cache): $e');
        }

        Logger.logSuccess('Flutterwave OAuth token refreshed and cached');
        return accessToken;
      } else {
        Logger.logError('OAuth token request failed. Response: ${response.body}');
        final errorData = json.decode(response.body);
        final errorMessage =
            errorData['message'] ??
            errorData['error'] ??
            'OAuth token request failed';
        throw Exception('Failed to get OAuth token: $errorMessage');
      }
    } catch (e) {
      Logger.logError('❌ CRITICAL: Failed to refresh OAuth token');
      Logger.logError('Error type: ${e.runtimeType}');
      Logger.logError('Error message: ${e.toString()}');
      Logger.logError('Stack trace: ${StackTrace.current}');

      // If it's a NotInitializedError, provide more context
      if (e.toString().contains('NotInitializedError')) {
        Logger.logError('🔍 This is a NotInitializedError - likely from flutter_dotenv');
        Logger.logError('💡 Suggestion: Check if .env file is loaded properly');
      }

      rethrow;
    }
  }

  // Helper method to ensure dotenv is loaded
  Future<void> _ensureDotenvLoaded() async {
    try {
      Logger.logBasic('🔍 Checking if dotenv is loaded...');

      // For web builds, environment variables are already available
      if (kIsWeb) {
        Logger.logBasic('✅ Running on web - using platform environment variables');
        return;
      }

      // Try to access a dotenv variable to see if it's loaded
      try {
        dotenv.env['FLUTTERWAVE_CLIENT_ID']; // Test access
        Logger.logBasic('✅ Dotenv is already loaded (test access successful)');
      } catch (e) {
        Logger.logWarning('⚠️ Dotenv not loaded, attempting to load .env file...');

        try {
          // Try multiple paths for the .env file
          await dotenv.load(fileName: ".env");
          Logger.logSuccess('✅ Successfully loaded .env file');
        } catch (loadError) {
          Logger.logError('❌ Failed to load .env file from root: $loadError');

          // Try alternative paths
          try {
            await dotenv.load(fileName: "assets/.env");
            Logger.logSuccess('✅ Successfully loaded .env file from assets/');
          } catch (assetsError) {
            Logger.logError('❌ Failed to load .env file from assets/: $assetsError');

            try {
              await dotenv.load(fileName: "../.env");
              Logger.logSuccess('✅ Successfully loaded .env file from parent directory');
            } catch (parentError) {
              Logger.logError('❌ Failed to load .env file from parent: $parentError');
              Logger.logWarning('🔄 Using fallback: manually loading environment variables...');

              // Fallback: Manually set the environment variables we know exist
              try {
                dotenv.env['FLUTTERWAVE_CLIENT_ID'] = 'f87d5229-1f49-41b6-bc23-71b2b9fb967c';
                dotenv.env['FLUTTERWAVE_CLIENT_SECRET'] = 'RdGuD6FvA2iRrJY5Occjd9V33i0w7San';
                dotenv.env['FLUTTERWAVE_SECRET_HASH'] = '3JZCy3UnzI6mvO4p2FAkAViXeqTSZw4y6FDeyD';
                dotenv.env['FLUTTERWAVE_ENV'] = 'sandbox';

                Logger.logSuccess('✅ Successfully set fallback environment variables');
              } catch (fallbackError) {
                Logger.logError('❌ Even fallback failed: $fallbackError');
                throw Exception('Critical: Unable to access Flutterwave credentials');
              }
            }
          }
        }
      }
    } catch (e) {
      Logger.logError('❌ Critical error in dotenv loading: $e');
      rethrow;
    }
  }
}
