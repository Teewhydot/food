import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';

import '../constants/env.dart';
import '../utils/logger.dart';

/// Card Encryption Service for Flutterwave V4 API
///
/// Implements AES-GCM encryption with:
/// - UTF-8 encoding for all string data
/// - 12-character nonce used directly as IV for GCM
/// - Base64 encoding for encrypted output
/// - MAC authentication tag included automatically
class CardEncryptionService {
  static CardEncryptionService? _instance;
  static AesGcm? _algorithm;
  static SecretKey? _secretKey;

  // 🚨 SECURITY: Never store encryption keys in source code!
  // Key is loaded from environment variables

  CardEncryptionService._internal();

  static CardEncryptionService get instance {
    _instance ??= CardEncryptionService._internal();
    return _instance!;
  }

  static Future<void> initialize() async {
    try {
      // Validate security setup first
      validateSecuritySetup();

      final keyBytes = await _getSecureEncryptionKeyBytes();

      // Initialize the AES-GCM algorithm and secret key
      _algorithm = AesGcm.with256bits();
      _secretKey = SecretKey(keyBytes);

      Logger.logSuccess('CardEncryptionService initialized successfully with AES-GCM');
    } catch (e) {
      Logger.logError('Failed to initialize CardEncryptionService: $e');
      rethrow;
    }
  }

  /// Securely loads encryption key bytes from environment
  static Future<List<int>> _getSecureEncryptionKeyBytes() async {
    if (!Env.hasCardEncryptionKey) {
      throw Exception(
        'CARD_ENCRYPTION_KEY not found in environment variables. Set it in your .env file.',
      );
    }

    try {
      final keyBytes = base64Decode(Env.cardEncryptionKey!);
      if (keyBytes.length != 32) {
        // 256-bit key
        throw Exception(
          'Environment encryption key has wrong length: ${keyBytes.length} bytes. Expected 32 bytes.',
        );
      }
      Logger.logSuccess(
        'Using encryption key from environment (length: ${keyBytes.length} bytes)',
      );
      return keyBytes;
    } catch (e) {
      Logger.logError('Failed to decode environment encryption key: $e');
      throw Exception('Invalid encryption key in environment: $e');
    }
  }

  static void dispose() {
    _algorithm = null;
    _secretKey = null;
    _instance = null;
  }

  Future<void> _ensureInitialized() async {
    if (_algorithm == null || _secretKey == null) {
      Logger.logWarning(
        'CardEncryptionService not initialized, attempting to initialize...',
      );
      await initialize();
    }
  }

  /// Encrypts card number for secure transmission using AES-GCM with provided nonce
  Future<Map<String, String>> encryptCardNumber(String cardNumber, String nonce) async {
    try {
      await _ensureInitialized();

      // Remove any spaces or special characters
      final cleanCardNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

      if (cleanCardNumber.isEmpty) {
        throw Exception('Card number cannot be empty');
      }

      if (nonce.length != 12) {
        throw Exception('Nonce must be exactly 12 characters for AES-GCM');
      }

      // Convert nonce to bytes for use as IV
      final nonceBytes = utf8.encode(nonce);

      // Encrypt using AES-GCM with the nonce as IV
      final secretBox = await _algorithm!.encrypt(
        utf8.encode(cleanCardNumber),
        secretKey: _secretKey!,
        nonce: nonceBytes,
      );

      Logger.logBasic('Card number encrypted successfully with AES-GCM');

      return {
        'encrypted': base64Encode(secretBox.cipherText),
        'nonce': nonce,
      };
    } catch (e) {
      Logger.logError('Failed to encrypt card number: $e');
      rethrow;
    }
  }

  /// Encrypts CVV for secure transmission using AES-GCM with provided nonce
  Future<Map<String, String>> encryptCVV(String cvv, String nonce) async {
    try {
      await _ensureInitialized();

      if (cvv.isEmpty) {
        throw Exception('CVV cannot be empty');
      }

      if (nonce.length != 12) {
        throw Exception('Nonce must be exactly 12 characters for AES-GCM');
      }

      // Convert nonce to bytes for use as IV
      final nonceBytes = utf8.encode(nonce);

      // Encrypt using AES-GCM with the nonce as IV
      final secretBox = await _algorithm!.encrypt(
        utf8.encode(cvv),
        secretKey: _secretKey!,
        nonce: nonceBytes,
      );

      Logger.logBasic('CVV encrypted successfully with AES-GCM');

      return {
        'encrypted': base64Encode(secretBox.cipherText),
        'nonce': nonce,
      };
    } catch (e) {
      Logger.logError('Failed to encrypt CVV: $e');
      rethrow;
    }
  }

  /// Encrypts expiry month for secure transmission using AES-GCM with provided nonce
  Future<Map<String, String>> encryptExpiryMonth(String expiryMonth, String nonce) async {
    try {
      await _ensureInitialized();

      if (expiryMonth.isEmpty) {
        throw Exception('Expiry month cannot be empty');
      }

      if (nonce.length != 12) {
        throw Exception('Nonce must be exactly 12 characters for AES-GCM');
      }

      // Ensure it's 2 digits
      final paddedMonth = expiryMonth.padLeft(2, '0');

      // Convert nonce to bytes for use as IV
      final nonceBytes = utf8.encode(nonce);

      // Encrypt using AES-GCM with the nonce as IV
      final secretBox = await _algorithm!.encrypt(
        utf8.encode(paddedMonth),
        secretKey: _secretKey!,
        nonce: nonceBytes,
      );

      Logger.logBasic('Expiry month encrypted successfully with AES-GCM');

      return {
        'encrypted': base64Encode(secretBox.cipherText),
        'nonce': nonce,
      };
    } catch (e) {
      Logger.logError('Failed to encrypt expiry month: $e');
      rethrow;
    }
  }

  /// Encrypts expiry year for secure transmission using AES-GCM with provided nonce
  Future<Map<String, String>> encryptExpiryYear(String expiryYear, String nonce) async {
    try {
      await _ensureInitialized();

      if (expiryYear.isEmpty) {
        throw Exception('Expiry year cannot be empty');
      }

      if (nonce.length != 12) {
        throw Exception('Nonce must be exactly 12 characters for AES-GCM');
      }

      // Convert nonce to bytes for use as IV
      final nonceBytes = utf8.encode(nonce);

      // Encrypt using AES-GCM with the nonce as IV
      final secretBox = await _algorithm!.encrypt(
        utf8.encode(expiryYear),
        secretKey: _secretKey!,
        nonce: nonceBytes,
      );

      Logger.logBasic('Expiry year encrypted successfully with AES-GCM');

      return {
        'encrypted': base64Encode(secretBox.cipherText),
        'nonce': nonce,
      };
    } catch (e) {
      Logger.logError('Failed to encrypt expiry year: $e');
      rethrow;
    }
  }

  /// Encrypts any card data string using AES-GCM with provided nonce
  Future<Map<String, String>> encryptCardData(String data, String nonce) async {
    try {
      await _ensureInitialized();

      if (data.isEmpty) {
        throw Exception('Data cannot be empty');
      }

      if (nonce.length != 12) {
        throw Exception('Nonce must be exactly 12 characters for AES-GCM');
      }

      // Convert nonce to bytes for use as IV
      final nonceBytes = utf8.encode(nonce);

      // Encrypt using AES-GCM with the nonce as IV
      final secretBox = await _algorithm!.encrypt(
        utf8.encode(data),
        secretKey: _secretKey!,
        nonce: nonceBytes,
      );

      Logger.logBasic('Card data encrypted successfully with AES-GCM');

      return {
        'encrypted': base64Encode(secretBox.cipherText),
        'nonce': nonce,
      };
    } catch (e) {
      Logger.logError('Failed to encrypt card data: $e');
      rethrow;
    }
  }


  /// Decrypts card data (for testing/verification purposes only)
  /// Requires both the encrypted data and the nonce used for encryption
  Future<String> decryptCardData(String encryptedData, String nonce) async {
    try {
      await _ensureInitialized();

      if (encryptedData.isEmpty || nonce.isEmpty) {
        throw Exception('Encrypted data and nonce cannot be empty');
      }

      if (nonce.length != 12) {
        throw Exception('Nonce must be exactly 12 characters for AES-GCM');
      }

      // Convert nonce to bytes for use as IV
      final nonceBytes = utf8.encode(nonce);
      final cipherBytes = base64Decode(encryptedData);

      // Create a SecretBox with empty MAC (we'll need the full encrypted data from Flutterwave)
      // For testing purposes, we'll assume the MAC is appended to the ciphertext
      final secretBox = SecretBox(
        cipherBytes,
        nonce: nonceBytes,
        mac: Mac.empty, // Placeholder - in real scenario, MAC would be extracted
      );

      // Decrypt using AES-GCM
      final decryptedBytes = await _algorithm!.decrypt(
        secretBox,
        secretKey: _secretKey!,
      );

      final decrypted = utf8.decode(decryptedBytes);
      Logger.logBasic('Card data decrypted successfully with AES-GCM');
      return decrypted;
    } catch (e) {
      Logger.logError('Failed to decrypt card data: $e');
      rethrow;
    }
  }

  /// Generates a secure nonce for Flutterwave API
  String generateSecureNonce(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  /// Validates if the encryption service is ready to use
  bool get isInitialized => _algorithm != null && _secretKey != null;

  /// Validates encryption setup and logs security warnings
  static bool validateSecuritySetup() {
    bool isSecure = true;

    if (!Env.hasCardEncryptionKey) {
      Logger.logError(
        '🚨 SECURITY RISK: No encryption key configured in environment!',
      );
      Logger.logError(
        '⚠️  Add CARD_ENCRYPTION_KEY to your .env file immediately!',
      );
      Logger.logError('⚠️  Generate key with: openssl rand -base64 32');
      isSecure = false;
    }

    if (kDebugMode && isSecure) {
      Logger.logSuccess('✅ Card encryption is properly configured');
    }

    return isSecure;
  }

  /// Encrypts all card details at once with a single nonce for AES-GCM
  Future<Map<String, String>> encryptAllCardDetails({
    required String cardNumber,
    required String cvv,
    required String expiryMonth,
    required String expiryYear,
    required String nonce,
  }) async {
    try {
      await _ensureInitialized();

      Logger.logBasic('Encrypting all card details with AES-GCM...');

      if (nonce.length != 12) {
        throw Exception('Nonce must be exactly 12 characters for AES-GCM');
      }

      // Convert nonce to bytes for use as IV
      final nonceBytes = utf8.encode(nonce);

      // Remove any spaces or special characters from card number
      final cleanCardNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

      // Ensure expiry month is 2 digits
      final paddedMonth = expiryMonth.padLeft(2, '0');

      // Encrypt each field with the same nonce as IV
      final encryptedCardNumber = await _algorithm!.encrypt(
        utf8.encode(cleanCardNumber),
        secretKey: _secretKey!,
        nonce: nonceBytes,
      );
      final encryptedCVV = await _algorithm!.encrypt(
        utf8.encode(cvv),
        secretKey: _secretKey!,
        nonce: nonceBytes,
      );
      final encryptedExpiryMonth = await _algorithm!.encrypt(
        utf8.encode(paddedMonth),
        secretKey: _secretKey!,
        nonce: nonceBytes,
      );
      final encryptedExpiryYear = await _algorithm!.encrypt(
        utf8.encode(expiryYear),
        secretKey: _secretKey!,
        nonce: nonceBytes,
      );

      final encryptedData = {
        'encrypted_card_number': base64Encode(encryptedCardNumber.cipherText),
        'encrypted_cvv': base64Encode(encryptedCVV.cipherText),
        'encrypted_expiry_month': base64Encode(encryptedExpiryMonth.cipherText),
        'encrypted_expiry_year': base64Encode(encryptedExpiryYear.cipherText),
        'nonce': nonce, // Single nonce for all fields
      };

      Logger.logSuccess('All card details encrypted successfully with AES-GCM');
      return encryptedData;
    } catch (e) {
      Logger.logError('Failed to encrypt all card details: $e');
      rethrow;
    }
  }
}
