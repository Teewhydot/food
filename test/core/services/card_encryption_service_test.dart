import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/core/services/card_encryption_service.dart';

void main() {
  group('CardEncryptionService', () {
    late CardEncryptionService encryptionService;

    setUpAll(() async {
      // Initialize the encryption service before running tests
      await CardEncryptionService.initialize();
      encryptionService = CardEncryptionService.instance;
    });

    tearDownAll(() {
      // Clean up after tests
      CardEncryptionService.dispose();
    });

    test('should initialize correctly', () {
      expect(encryptionService.isInitialized, isTrue);
    });

    test('should encrypt card number successfully with nonce', () async {
      const testCardNumber = '4111111111111111';
      const testNonce = 'A1B2C3D4E5F6'; // 12 characters

      final result = await encryptionService.encryptCardNumber(testCardNumber, testNonce);

      expect(result, isA<Map<String, String>>());
      expect(result['encrypted'], isNotNull);
      expect(result['nonce'], isNotNull);
      expect(result['encrypted'], isNotEmpty);
      expect(result['nonce'], equals(testNonce));
      expect(result['encrypted'], isNot(equals(testCardNumber)));
    });

    test('should encrypt CVV successfully with nonce', () async {
      const testCVV = '123';
      const testNonce = 'X9Y8Z7A6B5C4'; // 12 characters

      final result = await encryptionService.encryptCVV(testCVV, testNonce);

      expect(result, isA<Map<String, String>>());
      expect(result['encrypted'], isNotNull);
      expect(result['nonce'], isNotNull);
      expect(result['encrypted'], isNotEmpty);
      expect(result['nonce'], equals(testNonce));
      expect(result['encrypted'], isNot(equals(testCVV)));
    });

    test('should encrypt expiry month successfully with nonce', () async {
      const testMonth = '12';
      const testNonce = 'M1N2O3P4Q5R6'; // 12 characters

      final result = await encryptionService.encryptExpiryMonth(testMonth, testNonce);

      expect(result, isA<Map<String, String>>());
      expect(result['encrypted'], isNotNull);
      expect(result['nonce'], isNotNull);
      expect(result['encrypted'], isNotEmpty);
      expect(result['nonce'], equals(testNonce));
      expect(result['encrypted'], isNot(equals(testMonth)));
    });

    test('should encrypt expiry year successfully with nonce', () async {
      const testYear = '2025';
      const testNonce = 'Y1E2A3R4T5S6'; // 12 characters

      final result = await encryptionService.encryptExpiryYear(testYear, testNonce);

      expect(result, isA<Map<String, String>>());
      expect(result['encrypted'], isNotNull);
      expect(result['nonce'], isNotNull);
      expect(result['encrypted'], isNotEmpty);
      expect(result['nonce'], equals(testNonce));
      expect(result['encrypted'], isNot(equals(testYear)));
    });

    test('should encrypt and decrypt data correctly with nonce', () async {
      const testData = 'test card data';
      const testNonce = 'T1E2S3T4D5A6'; // 12 characters

      final encryptedResult = await encryptionService.encryptCardData(testData, testNonce);
      final decrypted = await encryptionService.decryptCardData(
        encryptedResult['encrypted']!,
        encryptedResult['nonce']!,
      );

      expect(decrypted, equals(testData));
    });

    test('should produce different encrypted data with different nonces', () async {
      const testData = 'test data';
      const nonce1 = 'N1O2N3C4E5F6'; // 12 characters
      const nonce2 = 'D1I2F3F4E5R6'; // 12 characters

      final result1 = await encryptionService.encryptCardData(testData, nonce1);
      final result2 = await encryptionService.encryptCardData(testData, nonce2);

      // Nonces should be different
      expect(result1['nonce'], isNot(equals(result2['nonce'])));
      // Encrypted data should also be different due to different nonces
      expect(result1['encrypted'], isNot(equals(result2['encrypted'])));
    });

    test('should encrypt all card details at once with single nonce', () async {
      const cardNumber = '4111111111111111';
      const cvv = '123';
      const expiryMonth = '12';
      const expiryYear = '2025';
      const testNonce = 'A1L2L3C4A5R6'; // 12 characters

      final encryptedData = await encryptionService.encryptAllCardDetails(
        cardNumber: cardNumber,
        cvv: cvv,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        nonce: testNonce,
      );

      expect(encryptedData, isA<Map<String, String>>());
      expect(encryptedData['encrypted_card_number'], isNotNull);
      expect(encryptedData['encrypted_cvv'], isNotNull);
      expect(encryptedData['encrypted_expiry_month'], isNotNull);
      expect(encryptedData['encrypted_expiry_year'], isNotNull);
      expect(encryptedData['nonce'], isNotNull);  // Should have the same nonce
      expect(encryptedData['nonce'], equals(testNonce));

      // Verify all encrypted values are different from original
      expect(encryptedData['encrypted_card_number'], isNot(equals(cardNumber)));
      expect(encryptedData['encrypted_cvv'], isNot(equals(cvv)));
      expect(encryptedData['encrypted_expiry_month'], isNot(equals(expiryMonth)));
      expect(encryptedData['encrypted_expiry_year'], isNot(equals(expiryYear)));
    });

    test('should reject invalid nonce length', () async {
      const testData = 'test data';
      const invalidNonce = 'TOO_SHORT'; // Only 9 characters

      expect(
        () => encryptionService.encryptCardData(testData, invalidNonce),
        throwsA(isA<Exception>()),
      );
    });

    test('should use same nonce for all fields in encryptAllCardDetails', () async {
      const cardNumber = '4111111111111111';
      const cvv = '123';
      const expiryMonth = '12';
      const expiryYear = '2025';
      const testNonce = 'S1A2M3E4N5O6'; // 12 characters

      final encryptedData = await encryptionService.encryptAllCardDetails(
        cardNumber: cardNumber,
        cvv: cvv,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        nonce: testNonce,
      );

      // All encrypted fields should be non-empty and different from originals
      expect(encryptedData['encrypted_card_number'], isNotEmpty);
      expect(encryptedData['encrypted_cvv'], isNotEmpty);
      expect(encryptedData['encrypted_expiry_month'], isNotEmpty);
      expect(encryptedData['encrypted_expiry_year'], isNotEmpty);

      // Nonce should be preserved
      expect(encryptedData['nonce'], equals(testNonce));
    });
  });
}