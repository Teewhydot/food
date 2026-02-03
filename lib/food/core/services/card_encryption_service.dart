import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../constants/env.dart';
import '../utils/logger.dart';

/// Card Encryption Service for Flutterwave V3 API
///
/// Note: Flutterwave v3 uses server-side encryption for card payloads.
/// The Flutter app sends raw card details to Firebase Functions, which
/// then encrypts and forwards to Flutterwave v3 API.
///
/// This service is kept for future encryption needs if required client-side.
class CardEncryptionService {
  static CardEncryptionService? _instance;

  // 🚨 SECURITY: Never store encryption keys in source code!
  // Key is loaded from environment variables

  CardEncryptionService._internal();

  static CardEncryptionService get instance {
    _instance ??= CardEncryptionService._internal();
    return _instance!;
  }

  /// Initialize the encryption service
  /// For v3, encryption is handled server-side, so this is a no-op
  static Future<void> initialize() async {
    // No-op for v3 - encryption is handled server-side by Firebase Functions
    Logger.logBasic('CardEncryptionService initialized (v3 server-side encryption)');
  }

  static void dispose() {
    _instance = null;
  }

  /// Note: For Flutterwave v3, encryption is handled server-side by Firebase Functions.
  /// The Flutter app should send raw card details to the Firebase Function,
  /// which will encrypt using 3DES before calling Flutterwave API.
  ///
  /// This method is a placeholder for potential future client-side encryption needs.
  String encryptPayload(Map<String, dynamic> payload) {
    Logger.logWarning('Client-side encryption not implemented for v3. Encryption is handled server-side.');
    // Return JSON string - actual encryption happens on server
    return json.encode(payload);
  }

  /// Validates if the encryption service is ready to use
  bool get isInitialized {
    try {
      final key = Env.flutterwaveEncryptionKey;
      return key != null && key.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Validates encryption setup and logs security warnings
  static bool validateSecuritySetup() {
    bool isSecure = true;

    if (Env.flutterwaveEncryptionKey == null ||
        Env.flutterwaveEncryptionKey!.isEmpty) {
      Logger.logWarning(
        '⚠️  Flutterwave encryption key not configured in environment.',
      );
      Logger.logWarning(
        '⚠️  For v3, encryption is handled server-side by Firebase Functions.',
      );
      Logger.logWarning(
        '⚠️  Add FLUTTERWAVE_ENCRYPTION_KEY to Firebase Functions environment if needed.',
      );
      // This is a warning, not an error for v3 since encryption is server-side
    }

    if (kDebugMode) {
      Logger.logSuccess('✅ Card encryption service initialized (v3 server-side encryption)');
    }

    return isSecure;
  }

  // ========================================================================
  // Legacy methods for v4 AES-GCM encryption (DEPRECATED - DO NOT USE)
  // ========================================================================

  /// @deprecated Server-side encryption is used for v3
  /// Encrypts card number using AES-GCM with provided nonce (v4 only)
  Future<Map<String, String>> encryptCardNumber(String cardNumber, String nonce) async {
    throw UnimplementedError('AES-GCM encryption is deprecated. Server-side encryption is used for v3.');
  }

  /// @deprecated Server-side encryption is used for v3
  /// Encrypts CVV using AES-GCM with provided nonce (v4 only)
  Future<Map<String, String>> encryptCVV(String cvv, String nonce) async {
    throw UnimplementedError('AES-GCM encryption is deprecated. Server-side encryption is used for v3.');
  }

  /// @deprecated Server-side encryption is used for v3
  /// Encrypts expiry month using AES-GCM with provided nonce (v4 only)
  Future<Map<String, String>> encryptExpiryMonth(String expiryMonth, String nonce) async {
    throw UnimplementedError('AES-GCM encryption is deprecated. Server-side encryption is used for v3.');
  }

  /// @deprecated Server-side encryption is used for v3
  /// Encrypts expiry year using AES-GCM with provided nonce (v4 only)
  Future<Map<String, String>> encryptExpiryYear(String expiryYear, String nonce) async {
    throw UnimplementedError('AES-GCM encryption is deprecated. Server-side encryption is used for v3.');
  }

  /// @deprecated Server-side encryption is used for v3
  /// Encrypts all card details using AES-GCM with provided nonce (v4 only)
  Future<Map<String, String>> encryptAllCardDetails({
    required String cardNumber,
    required String cvv,
    required String expiryMonth,
    required String expiryYear,
    required String nonce,
  }) async {
    throw UnimplementedError('AES-GCM encryption is deprecated. Server-side encryption is used for v3.');
  }

  /// @deprecated Not needed for v3 - server-side handles everything
  /// Generates a secure nonce for Flutterwave v4 API
  String generateSecureNonce(int length) {
    throw UnimplementedError('Nonce generation is not needed for v3. Server-side handles encryption.');
  }
}
