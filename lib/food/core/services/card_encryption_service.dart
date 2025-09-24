import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import '../utils/logger.dart';
import '../constants/env.dart';

class CardEncryptionService {
  static CardEncryptionService? _instance;
  static Encrypter? _encrypter;
  static IV? _staticIV;

  // 🚨 SECURITY: Never store encryption keys in source code!
  // Key is loaded from environment variables or generated dynamically

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

      // Create a static IV for consistent encryption (use dynamic IV in production)
      _staticIV = IV.fromSecureRandom(16);

      Logger.logSuccess('CardEncryptionService initialized successfully');
    } catch (e) {
      Logger.logError('Failed to initialize CardEncryptionService: $e');
      rethrow;
    }
  }

  /// Securely loads or generates encryption key
  static Future<Key> _getSecureEncryptionKey() async {
    // First priority: Environment variable
    if (Env.hasCardEncryptionKey) {
      try {
        final keyBytes = base64Decode(Env.cardEncryptionKey!);
        if (keyBytes.length == 32) { // 256-bit key
          Logger.logSuccess('Using encryption key from environment');
          return Key(keyBytes);
        } else {
          Logger.logWarning('Environment encryption key has wrong length: ${keyBytes.length} bytes');
        }
      } catch (e) {
        Logger.logError('Failed to decode environment encryption key: $e');
      }
    }

    // Fallback: Generate a secure key (WARNING: Will be different each app restart)
    Logger.logWarning('🚨 SECURITY WARNING: Generating temporary encryption key!');
    Logger.logWarning('⚠️  This key will change on app restart, making previous encrypted data unrecoverable!');
    Logger.logWarning('⚠️  For production, set CARD_ENCRYPTION_KEY in your .env file!');

    return _generateSecureKey();
  }

  /// Generates a cryptographically secure 256-bit encryption key
  static Key _generateSecureKey() {
    final random = Random.secure();
    final keyBytes = Uint8List(32); // 256 bits

    for (int i = 0; i < keyBytes.length; i++) {
      keyBytes[i] = random.nextInt(256);
    }

    if (kDebugMode) {
      Logger.logWarning('Generated temporary key (base64): ${base64Encode(keyBytes)}');
      Logger.logWarning('Save this key to your .env file as CARD_ENCRYPTION_KEY for consistency');
    }

    return Key(keyBytes);
  }

  static void dispose() {
    _encrypter = null;
    _staticIV = null;
    _instance = null;
  }

  Future<void> _ensureInitialized() async {
    if (_encrypter == null || _staticIV == null) {
      Logger.logWarning('CardEncryptionService not initialized, attempting to initialize...');
      await initialize();
    }
  }

  /// Encrypts card number for secure transmission
  Future<String> encryptCardNumber(String cardNumber) async {
    try {
      await _ensureInitialized();

      // Remove any spaces or special characters
      final cleanCardNumber = cardNumber.replaceAll(RegExp(r'[^\d]'), '');

      if (cleanCardNumber.isEmpty) {
        throw Exception('Card number cannot be empty');
      }

      final encrypted = _encrypter!.encrypt(cleanCardNumber, iv: _staticIV!);
      Logger.logBasic('Card number encrypted successfully');
      return encrypted.base64;
    } catch (e) {
      Logger.logError('Failed to encrypt card number: $e');
      rethrow;
    }
  }

  /// Encrypts CVV for secure transmission
  Future<String> encryptCVV(String cvv) async {
    try {
      await _ensureInitialized();

      if (cvv.isEmpty) {
        throw Exception('CVV cannot be empty');
      }

      final encrypted = _encrypter!.encrypt(cvv, iv: _staticIV!);
      Logger.logBasic('CVV encrypted successfully');
      return encrypted.base64;
    } catch (e) {
      Logger.logError('Failed to encrypt CVV: $e');
      rethrow;
    }
  }

  /// Encrypts expiry month for secure transmission
  Future<String> encryptExpiryMonth(String expiryMonth) async {
    try {
      await _ensureInitialized();

      if (expiryMonth.isEmpty) {
        throw Exception('Expiry month cannot be empty');
      }

      // Ensure it's 2 digits
      final paddedMonth = expiryMonth.padLeft(2, '0');

      final encrypted = _encrypter!.encrypt(paddedMonth, iv: _staticIV!);
      Logger.logBasic('Expiry month encrypted successfully');
      return encrypted.base64;
    } catch (e) {
      Logger.logError('Failed to encrypt expiry month: $e');
      rethrow;
    }
  }

  /// Encrypts expiry year for secure transmission
  Future<String> encryptExpiryYear(String expiryYear) async {
    try {
      await _ensureInitialized();

      if (expiryYear.isEmpty) {
        throw Exception('Expiry year cannot be empty');
      }

      final encrypted = _encrypter!.encrypt(expiryYear, iv: _staticIV!);
      Logger.logBasic('Expiry year encrypted successfully');
      return encrypted.base64;
    } catch (e) {
      Logger.logError('Failed to encrypt expiry year: $e');
      rethrow;
    }
  }

  /// Encrypts any card data string
  Future<String> encryptCardData(String data) async {
    try {
      await _ensureInitialized();

      if (data.isEmpty) {
        throw Exception('Data cannot be empty');
      }

      final encrypted = _encrypter!.encrypt(data, iv: _staticIV!);
      Logger.logBasic('Card data encrypted successfully');
      return encrypted.base64;
    } catch (e) {
      Logger.logError('Failed to encrypt card data: $e');
      rethrow;
    }
  }

  /// Decrypts card data (for testing/verification purposes only)
  Future<String> decryptCardData(String encryptedData) async {
    try {
      await _ensureInitialized();

      if (encryptedData.isEmpty) {
        throw Exception('Encrypted data cannot be empty');
      }

      final encrypted = Encrypted.fromBase64(encryptedData);
      final decrypted = _encrypter!.decrypt(encrypted, iv: _staticIV!);
      Logger.logBasic('Card data decrypted successfully');
      return decrypted;
    } catch (e) {
      Logger.logError('Failed to decrypt card data: $e');
      rethrow;
    }
  }

  /// Generates a secure nonce for Flutterwave API
  String generateSecureNonce(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Validates if the encryption service is ready to use
  bool get isInitialized => _encrypter != null && _staticIV != null;

  /// Gets the IV as base64 string (for debugging purposes only - never log in production)
  String? get ivBase64 {
    if (kDebugMode) {
      return _staticIV?.base64;
    }
    return '[REDACTED]'; // Don't expose IV in production
  }

  /// Validates encryption setup and logs security warnings
  static bool validateSecuritySetup() {
    bool isSecure = true;

    if (!Env.hasCardEncryptionKey) {
      Logger.logError('🚨 SECURITY RISK: No encryption key configured in environment!');
      Logger.logError('⚠️  Add CARD_ENCRYPTION_KEY to your .env file immediately!');
      Logger.logError('⚠️  Generate key with: openssl rand -base64 32');
      isSecure = false;
    }

    if (kDebugMode && isSecure) {
      Logger.logSuccess('✅ Card encryption is properly configured');
    }

    return isSecure;
  }

  /// Encrypts all card details at once
  Future<Map<String, String>> encryptAllCardDetails({
    required String cardNumber,
    required String cvv,
    required String expiryMonth,
    required String expiryYear,
  }) async {
    try {
      await _ensureInitialized();

      Logger.logBasic('Encrypting all card details...');

      final results = await Future.wait([
        encryptCardNumber(cardNumber),
        encryptCVV(cvv),
        encryptExpiryMonth(expiryMonth),
        encryptExpiryYear(expiryYear),
      ]);

      final encryptedData = {
        'encrypted_card_number': results[0],
        'encrypted_cvv': results[1],
        'encrypted_expiry_month': results[2],
        'encrypted_expiry_year': results[3],
      };

      Logger.logSuccess('All card details encrypted successfully');
      return encryptedData;

    } catch (e) {
      Logger.logError('Failed to encrypt all card details: $e');
      rethrow;
    }
  }
}