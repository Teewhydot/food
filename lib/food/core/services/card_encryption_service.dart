import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;

import '../constants/env.dart';
import '../utils/logger.dart';

/// Card Encryption Service for Flutterwave V4 API
///
/// Implements AES-256-CBC encryption with:
/// - UTF-8 encoding for all string data (handled internally by encrypt package)
/// - Unique IV generation for each encryption operation
/// - Base64 encoding for encrypted output and IV
class CardEncryptionService {
  static CardEncryptionService? _instance;
  static Encrypter? _encrypter;

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

      final key = await _getSecureEncryptionKey();

      // Initialize the encrypter with AES algorithm
      _encrypter = Encrypter(AES(key));

      Logger.logSuccess('CardEncryptionService initialized successfully');
    } catch (e) {
      Logger.logError('Failed to initialize CardEncryptionService: $e');
      rethrow;
    }
  }

  /// Securely loads encryption key from environment
  static Future<Key> _getSecureEncryptionKey() async {
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
        'Using encryption key from environment ${Env.cardEncryptionKey!}... (length: ${keyBytes.length} bytes)',
      );
      return Key(keyBytes);
    } catch (e) {
      Logger.logError('Failed to decode environment encryption key: $e');
      throw Exception('Invalid encryption key in environment: $e');
    }
  }

  static void dispose() {
    _encrypter = null;
    _instance = null;
  }

  Future<void> _ensureInitialized() async {
    if (_encrypter == null) {
      Logger.logWarning(
        'CardEncryptionService not initialized, attempting to initialize...',
      );
      await initialize();
    }
  }

  /// Encrypts card number for secure transmission
  Future<Map<String, String>> encryptCardNumber(String cardNumber) async {
    try {
      await _ensureInitialized();

      // Remove any spaces or special characters
      final cleanCardNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

      if (cleanCardNumber.isEmpty) {
        throw Exception('Card number cannot be empty');
      }

      // Generate unique IV for this encryption
      final iv = IV.fromSecureRandom(16);

      // The encrypt library handles UTF-8 encoding internally
      final encrypted = _encrypter!.encrypt(cleanCardNumber, iv: iv);
      Logger.logBasic('Card number encrypted successfully (UTF-8 encoded)');

      return {
        'encrypted': encrypted.base64,
        'iv': iv.base64,
      };
    } catch (e) {
      Logger.logError('Failed to encrypt card number: $e');
      rethrow;
    }
  }

  /// Encrypts CVV for secure transmission
  Future<Map<String, String>> encryptCVV(String cvv) async {
    try {
      await _ensureInitialized();

      if (cvv.isEmpty) {
        throw Exception('CVV cannot be empty');
      }

      // Generate unique IV for this encryption
      final iv = IV.fromSecureRandom(16);

      // The encrypt library handles UTF-8 encoding internally
      final encrypted = _encrypter!.encrypt(cvv, iv: iv);
      Logger.logBasic('CVV encrypted successfully (UTF-8 encoded)');

      return {
        'encrypted': encrypted.base64,
        'iv': iv.base64,
      };
    } catch (e) {
      Logger.logError('Failed to encrypt CVV: $e');
      rethrow;
    }
  }

  /// Encrypts expiry month for secure transmission
  Future<Map<String, String>> encryptExpiryMonth(String expiryMonth) async {
    try {
      await _ensureInitialized();

      if (expiryMonth.isEmpty) {
        throw Exception('Expiry month cannot be empty');
      }

      // Ensure it's 2 digits
      final paddedMonth = expiryMonth.padLeft(2, '0');

      // Generate unique IV for this encryption
      final iv = IV.fromSecureRandom(16);

      // The encrypt library handles UTF-8 encoding internally
      final encrypted = _encrypter!.encrypt(paddedMonth, iv: iv);
      Logger.logBasic('Expiry month encrypted successfully (UTF-8 encoded)');

      return {
        'encrypted': encrypted.base64,
        'iv': iv.base64,
      };
    } catch (e) {
      Logger.logError('Failed to encrypt expiry month: $e');
      rethrow;
    }
  }

  /// Encrypts expiry year for secure transmission
  Future<Map<String, String>> encryptExpiryYear(String expiryYear) async {
    try {
      await _ensureInitialized();

      if (expiryYear.isEmpty) {
        throw Exception('Expiry year cannot be empty');
      }

      // Generate unique IV for this encryption
      final iv = IV.fromSecureRandom(16);

      // The encrypt library handles UTF-8 encoding internally
      final encrypted = _encrypter!.encrypt(expiryYear, iv: iv);
      Logger.logBasic('Expiry year encrypted successfully (UTF-8 encoded)');

      return {
        'encrypted': encrypted.base64,
        'iv': iv.base64,
      };
    } catch (e) {
      Logger.logError('Failed to encrypt expiry year: $e');
      rethrow;
    }
  }

  /// Encrypts any card data string
  Future<Map<String, String>> encryptCardData(String data) async {
    try {
      await _ensureInitialized();

      if (data.isEmpty) {
        throw Exception('Data cannot be empty');
      }

      // Generate unique IV for this encryption
      final iv = IV.fromSecureRandom(16);

      // The encrypt library handles UTF-8 encoding internally
      final encrypted = _encrypter!.encrypt(data, iv: iv);
      Logger.logBasic('Card data encrypted successfully (UTF-8 encoded)');

      return {
        'encrypted': encrypted.base64,
        'iv': iv.base64,
      };
    } catch (e) {
      Logger.logError('Failed to encrypt card data: $e');
      rethrow;
    }
  }


  /// Decrypts card data (for testing/verification purposes only)
  /// Requires both the encrypted data and the IV used for encryption
  Future<String> decryptCardData(String encryptedData, String ivBase64) async {
    try {
      await _ensureInitialized();

      if (encryptedData.isEmpty || ivBase64.isEmpty) {
        throw Exception('Encrypted data and IV cannot be empty');
      }

      final encrypted = Encrypted.fromBase64(encryptedData);
      final iv = IV.fromBase64(ivBase64);

      // The encrypt library handles UTF-8 decoding internally
      final decrypted = _encrypter!.decrypt(encrypted, iv: iv);
      Logger.logBasic('Card data decrypted successfully (UTF-8 decoded)');
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
  bool get isInitialized => _encrypter != null;

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

  /// Encrypts all card details at once with a single IV for the entire payload
  Future<Map<String, String>> encryptAllCardDetails({
    required String cardNumber,
    required String cvv,
    required String expiryMonth,
    required String expiryYear,
  }) async {
    try {
      await _ensureInitialized();

      Logger.logBasic('Encrypting all card details...');

      // Generate a single IV for the entire card data
      final iv = IV.fromSecureRandom(16);

      // Remove any spaces or special characters from card number
      final cleanCardNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

      // Ensure expiry month is 2 digits
      final paddedMonth = expiryMonth.padLeft(2, '0');

      // Encrypt each field with the same IV (UTF-8 encoding handled internally)
      final encryptedCardNumber = _encrypter!.encrypt(cleanCardNumber, iv: iv);
      final encryptedCVV = _encrypter!.encrypt(cvv, iv: iv);
      final encryptedExpiryMonth = _encrypter!.encrypt(paddedMonth, iv: iv);
      final encryptedExpiryYear = _encrypter!.encrypt(expiryYear, iv: iv);

      final encryptedData = {
        'encrypted_card_number': encryptedCardNumber.base64,
        'encrypted_cvv': encryptedCVV.base64,
        'encrypted_expiry_month': encryptedExpiryMonth.base64,
        'encrypted_expiry_year': encryptedExpiryYear.base64,
        'iv': iv.base64, // Single IV for all fields
      };

      Logger.logSuccess('All card details encrypted successfully (UTF-8 encoded)');
      return encryptedData;
    } catch (e) {
      Logger.logError('Failed to encrypt all card details: $e');
      rethrow;
    }
  }
}
