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
      expect(encryptionService.ivBase64, isNotNull);
    });

    test('should encrypt card number successfully', () async {
      const testCardNumber = '4111111111111111';

      final encrypted = await encryptionService.encryptCardNumber(testCardNumber);

      expect(encrypted, isNotNull);
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(testCardNumber)));
      expect(encrypted.length, greaterThan(0));
    });

    test('should encrypt CVV successfully', () async {
      const testCVV = '123';

      final encrypted = await encryptionService.encryptCVV(testCVV);

      expect(encrypted, isNotNull);
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(testCVV)));
    });

    test('should encrypt expiry month successfully', () async {
      const testMonth = '12';

      final encrypted = await encryptionService.encryptExpiryMonth(testMonth);

      expect(encrypted, isNotNull);
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(testMonth)));
    });

    test('should encrypt expiry year successfully', () async {
      const testYear = '2025';

      final encrypted = await encryptionService.encryptExpiryYear(testYear);

      expect(encrypted, isNotNull);
      expect(encrypted, isNotEmpty);
      expect(encrypted, isNot(equals(testYear)));
    });

    test('should encrypt and decrypt data correctly', () async {
      const testData = 'test card data';

      final encrypted = await encryptionService.encryptCardData(testData);
      final decrypted = await encryptionService.decryptCardData(encrypted);

      expect(decrypted, equals(testData));
    });

    test('should encrypt all card details at once', () async {
      const cardNumber = '4111111111111111';
      const cvv = '123';
      const expiryMonth = '12';
      const expiryYear = '2025';

      final encryptedData = await encryptionService.encryptAllCardDetails(
        cardNumber: cardNumber,
        cvv: cvv,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
      );

      expect(encryptedData, isA<Map<String, String>>());
      expect(encryptedData['encrypted_card_number'], isNotNull);
      expect(encryptedData['encrypted_cvv'], isNotNull);
      expect(encryptedData['encrypted_expiry_month'], isNotNull);
      expect(encryptedData['encrypted_expiry_year'], isNotNull);

      // Verify all encrypted values are different from original
      expect(encryptedData['encrypted_card_number'], isNot(equals(cardNumber)));
      expect(encryptedData['encrypted_cvv'], isNot(equals(cvv)));
      expect(encryptedData['encrypted_expiry_month'], isNot(equals(expiryMonth)));
      expect(encryptedData['encrypted_expiry_year'], isNot(equals(expiryYear)));
    });

    test('should generate secure nonce', () {
      final nonce1 = encryptionService.generateSecureNonce(12);
      final nonce2 = encryptionService.generateSecureNonce(12);

      expect(nonce1.length, equals(12));
      expect(nonce2.length, equals(12));
      expect(nonce1, isNot(equals(nonce2))); // Should be different each time
      expect(RegExp(r'^[A-Za-z0-9]+$').hasMatch(nonce1), isTrue); // Should be alphanumeric
    });

    test('should handle empty card number', () async {
      expect(
        () => encryptionService.encryptCardNumber(''),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle empty CVV', () async {
      expect(
        () => encryptionService.encryptCVV(''),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle card number with spaces', () async {
      const cardNumberWithSpaces = '4111 1111 1111 1111';
      const cardNumberWithoutSpaces = '4111111111111111';

      final encryptedWithSpaces = await encryptionService.encryptCardNumber(cardNumberWithSpaces);
      final encryptedWithoutSpaces = await encryptionService.encryptCardNumber(cardNumberWithoutSpaces);

      // Should produce the same result as spaces are cleaned
      expect(encryptedWithSpaces, equals(encryptedWithoutSpaces));
    });

    test('should pad expiry month correctly', () async {
      const singleDigitMonth = '5';
      const doubleDigitMonth = '05';

      final encryptedSingle = await encryptionService.encryptExpiryMonth(singleDigitMonth);
      final encryptedDouble = await encryptionService.encryptExpiryMonth(doubleDigitMonth);

      // Should produce the same result as single digit is padded
      expect(encryptedSingle, equals(encryptedDouble));
    });
  });
}