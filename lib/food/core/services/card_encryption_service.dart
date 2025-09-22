import 'dart:convert';
import 'dart:math';
import 'package:encrypt/encrypt.dart';
import '../utils/logger.dart';

class CardEncryptionService {
  static CardEncryptionService? _instance;
  static Encrypter? _encrypter;
  static IV? _staticIV;

  // The encryption key provided by the user
  static const String _encryptionKey = 'xrSZOopWtmZUdEoJAv+15MQM+a3ubvWZisXGRC+ymCw=';

  CardEncryptionService._internal();

  static CardEncryptionService get instance {
    _instance ??= CardEncryptionService._internal();
    return _instance!;
  }

  static Future<void> initialize() async {
    try {
      // Decode the base64 key
      final keyBytes = base64Decode(_encryptionKey);

      // Create the key for AES encryption
      final key = Key(keyBytes);

      // Initialize the encrypter with AES algorithm
      _encrypter = Encrypter(AES(key));

      // Create a static IV for consistent encryption (you might want to use dynamic IV in production)
      _staticIV = IV.fromSecureRandom(16);

      Logger.logSuccess('CardEncryptionService initialized successfully');
    } catch (e) {
      Logger.logError('Failed to initialize CardEncryptionService: $e');
      rethrow;
    }
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

  /// Gets the IV as base64 string (for debugging purposes)
  String? get ivBase64 => _staticIV?.base64;

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