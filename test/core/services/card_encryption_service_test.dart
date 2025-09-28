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

    test('should encrypt card number successfully', () async {
      const testCardNumber = '4111111111111111';

      final result = await encryptionService.encryptCardNumber(testCardNumber);

      expect(result, isA<Map<String, String>>());
      expect(result['encrypted'], isNotNull);
      expect(result['iv'], isNotNull);
      expect(result['encrypted'], isNotEmpty);
      expect(result['iv'], isNotEmpty);
      expect(result['encrypted'], isNot(equals(testCardNumber)));
    });

    test('should encrypt CVV successfully', () async {
      const testCVV = '123';

      final result = await encryptionService.encryptCVV(testCVV);

      expect(result, isA<Map<String, String>>());
      expect(result['encrypted'], isNotNull);
      expect(result['iv'], isNotNull);
      expect(result['encrypted'], isNotEmpty);
      expect(result['iv'], isNotEmpty);
      expect(result['encrypted'], isNot(equals(testCVV)));
    });

    test('should encrypt expiry month successfully', () async {
      const testMonth = '12';

      final result = await encryptionService.encryptExpiryMonth(testMonth);

      expect(result, isA<Map<String, String>>());
      expect(result['encrypted'], isNotNull);
      expect(result['iv'], isNotNull);
      expect(result['encrypted'], isNotEmpty);
      expect(result['iv'], isNotEmpty);
      expect(result['encrypted'], isNot(equals(testMonth)));
    });

    test('should encrypt expiry year successfully', () async {
      const testYear = '2025';

      final result = await encryptionService.encryptExpiryYear(testYear);

      expect(result, isA<Map<String, String>>());
      expect(result['encrypted'], isNotNull);
      expect(result['iv'], isNotNull);
      expect(result['encrypted'], isNotEmpty);
      expect(result['iv'], isNotEmpty);
      expect(result['encrypted'], isNot(equals(testYear)));
    });

    test('should encrypt and decrypt data correctly', () async {
      const testData = 'test card data';

      final encryptedResult = await encryptionService.encryptCardData(testData);
      final decrypted = await encryptionService.decryptCardData(
        encryptedResult['encrypted']!,
        encryptedResult['iv']!,
      );

      expect(decrypted, equals(testData));
    });

    test('should generate unique IVs for each encryption', () async {
      const testData = 'test data';

      final result1 = await encryptionService.encryptCardData(testData);
      final result2 = await encryptionService.encryptCardData(testData);

      // IVs should be different for each encryption
      expect(result1['iv'], isNot(equals(result2['iv'])));
      // Encrypted data should also be different due to unique IVs
      expect(result1['encrypted'], isNot(equals(result2['encrypted'])));
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
      expect(encryptedData['iv'], isNotNull);  // Should have a single IV

      // Verify all encrypted values are different from original
      expect(encryptedData['encrypted_card_number'], isNot(equals(cardNumber)));
      expect(encryptedData['encrypted_cvv'], isNot(equals(cvv)));
      expect(encryptedData['encrypted_expiry_month'], isNot(equals(expiryMonth)));
      expect(encryptedData['encrypted_expiry_year'], isNot(equals(expiryYear)));

      // Test decryption with the same IV
      final decryptedCardNumber = await encryptionService.decryptCardData(
        encryptedData['encrypted_card_number']!,
        encryptedData['iv']!,
      );
      expect(decryptedCardNumber, equals(cardNumber));
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

      final resultWithSpaces = await encryptionService.encryptCardNumber(cardNumberWithSpaces);
      final resultWithoutSpaces = await encryptionService.encryptCardNumber(cardNumberWithoutSpaces);

      // Decrypt both to verify they produce the same clean card number
      final decryptedWithSpaces = await encryptionService.decryptCardData(
        resultWithSpaces['encrypted']!,
        resultWithSpaces['iv']!,
      );
      final decryptedWithoutSpaces = await encryptionService.decryptCardData(
        resultWithoutSpaces['encrypted']!,
        resultWithoutSpaces['iv']!,
      );

      // Both should decrypt to the same cleaned card number
      expect(decryptedWithSpaces, equals(cardNumberWithoutSpaces));
      expect(decryptedWithoutSpaces, equals(cardNumberWithoutSpaces));
    });

    test('should pad expiry month correctly', () async {
      const singleDigitMonth = '5';
      const doubleDigitMonth = '05';

      final resultSingle = await encryptionService.encryptExpiryMonth(singleDigitMonth);
      final resultDouble = await encryptionService.encryptExpiryMonth(doubleDigitMonth);

      // Decrypt both to verify padding
      final decryptedSingle = await encryptionService.decryptCardData(
        resultSingle['encrypted']!,
        resultSingle['iv']!,
      );
      final decryptedDouble = await encryptionService.decryptCardData(
        resultDouble['encrypted']!,
        resultDouble['iv']!,
      );

      // Both should decrypt to the padded version '05'
      expect(decryptedSingle, equals('05'));
      expect(decryptedDouble, equals('05'));
    });
  });
}