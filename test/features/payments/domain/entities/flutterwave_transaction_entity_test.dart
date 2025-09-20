import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/features/payments/domain/entities/flutterwave_transaction_entity.dart';

void main() {
  group('FlutterwaveTransactionEntity', () {
    late FlutterwaveTransactionEntity testTransaction;
    late Map<String, dynamic> testJsonData;

    setUp(() {
      testJsonData = {
        'reference': 'FW_REF_123456',
        'orderId': 'order_123',
        'userId': 'user_456',
        'amount': 50000.0,
        'currency': 'NGN',
        'email': 'test@example.com',
        'status': 'pending',
        'authorizationUrl': 'https://checkout.flutterwave.com/v3/hosted/pay/...',
        'accessCode': 'fw_access_123',
        'createdAt': '2025-09-19T10:00:00.000Z',
        'paidAt': null,
        'metadata': {
          'customerName': 'John Doe',
          'customerPhone': '+2348123456789',
          'deliveryAddress': '123 Test Street, Lagos'
        }
      };

      testTransaction = FlutterwaveTransactionEntity(
        reference: 'FW_REF_123456',
        orderId: 'order_123',
        userId: 'user_456',
        amount: 50000.0,
        currency: 'NGN',
        email: 'test@example.com',
        status: 'pending',
        authorizationUrl: 'https://checkout.flutterwave.com/v3/hosted/pay/...',
        accessCode: 'fw_access_123',
        createdAt: DateTime.parse('2025-09-19T10:00:00.000Z'),
        paidAt: null,
        metadata: {
          'customerName': 'John Doe',
          'customerPhone': '+2348123456789',
          'deliveryAddress': '123 Test Street, Lagos'
        },
      );
    });

    group('Constructor', () {
      test('should create FlutterwaveTransactionEntity with all required fields', () {
        expect(testTransaction.reference, equals('FW_REF_123456'));
        expect(testTransaction.orderId, equals('order_123'));
        expect(testTransaction.userId, equals('user_456'));
        expect(testTransaction.amount, equals(50000.0));
        expect(testTransaction.currency, equals('NGN'));
        expect(testTransaction.email, equals('test@example.com'));
        expect(testTransaction.status, equals('pending'));
        expect(testTransaction.authorizationUrl, equals('https://checkout.flutterwave.com/v3/hosted/pay/...'));
        expect(testTransaction.accessCode, equals('fw_access_123'));
        expect(testTransaction.createdAt, equals(DateTime.parse('2025-09-19T10:00:00.000Z')));
        expect(testTransaction.paidAt, isNull);
        expect(testTransaction.metadata, isNotNull);
        expect(testTransaction.metadata!['customerName'], equals('John Doe'));
      });

      test('should create FlutterwaveTransactionEntity with optional fields as null', () {
        final transaction = FlutterwaveTransactionEntity(
          reference: 'FW_REF_789',
          orderId: 'order_789',
          userId: 'user_789',
          amount: 25000.0,
          currency: 'NGN',
          email: 'test2@example.com',
          status: 'success',
          createdAt: DateTime.now(),
        );

        expect(transaction.authorizationUrl, isNull);
        expect(transaction.accessCode, isNull);
        expect(transaction.paidAt, isNull);
        expect(transaction.metadata, isNull);
      });
    });

    group('Helper Methods', () {
      test('isPending should return true when status is pending', () {
        expect(testTransaction.isPending, isTrue);
      });

      test('isSuccess should return true when status is success', () {
        final successTransaction = testTransaction.copyWith(status: 'success');
        expect(successTransaction.isSuccess, isTrue);
        expect(successTransaction.isPending, isFalse);
      });

      test('isFailed should return true when status is failed', () {
        final failedTransaction = testTransaction.copyWith(status: 'failed');
        expect(failedTransaction.isFailed, isTrue);
        expect(failedTransaction.isPending, isFalse);
      });

      test('isProcessing should return true when status is processing', () {
        final processingTransaction = testTransaction.copyWith(status: 'processing');
        expect(processingTransaction.isProcessing, isTrue);
        expect(processingTransaction.isPending, isFalse);
      });

      test('should return false for other status values', () {
        final unknownTransaction = testTransaction.copyWith(status: 'unknown');
        expect(unknownTransaction.isPending, isFalse);
        expect(unknownTransaction.isSuccess, isFalse);
        expect(unknownTransaction.isFailed, isFalse);
        expect(unknownTransaction.isProcessing, isFalse);
      });
    });

    group('JSON Serialization', () {
      test('fromJson should create FlutterwaveTransactionEntity from JSON', () {
        final transaction = FlutterwaveTransactionEntity.fromJson(testJsonData);

        expect(transaction.reference, equals('FW_REF_123456'));
        expect(transaction.orderId, equals('order_123'));
        expect(transaction.userId, equals('user_456'));
        expect(transaction.amount, equals(50000.0));
        expect(transaction.currency, equals('NGN'));
        expect(transaction.email, equals('test@example.com'));
        expect(transaction.status, equals('pending'));
        expect(transaction.authorizationUrl, equals('https://checkout.flutterwave.com/v3/hosted/pay/...'));
        expect(transaction.accessCode, equals('fw_access_123'));
        expect(transaction.createdAt, equals(DateTime.parse('2025-09-19T10:00:00.000Z')));
        expect(transaction.paidAt, isNull);
        expect(transaction.metadata, isNotNull);
      });

      test('fromJson should handle snake_case field names for API compatibility', () {
        final snakeCaseJson = {
          'reference': 'FW_REF_SNAKE',
          'orderId': 'order_snake',
          'userId': 'user_snake',
          'amount': 30000.0,
          'currency': 'NGN',
          'email': 'snake@example.com',
          'status': 'success',
          'authorization_url': 'https://checkout.flutterwave.com/snake',
          'access_code': 'fw_snake_code',
          'createdAt': '2025-09-19T11:00:00.000Z',
          'paidAt': '2025-09-19T11:30:00.000Z',
        };

        final transaction = FlutterwaveTransactionEntity.fromJson(snakeCaseJson);

        expect(transaction.authorizationUrl, equals('https://checkout.flutterwave.com/snake'));
        expect(transaction.accessCode, equals('fw_snake_code'));
      });

      test('fromJson should provide default values for missing fields', () {
        final minimalJson = {
          'reference': 'FW_REF_MIN',
          'orderId': 'order_min',
          'userId': 'user_min',
        };

        final transaction = FlutterwaveTransactionEntity.fromJson(minimalJson);

        expect(transaction.reference, equals('FW_REF_MIN'));
        expect(transaction.orderId, equals('order_min'));
        expect(transaction.userId, equals('user_min'));
        expect(transaction.amount, equals(0.0));
        expect(transaction.currency, equals('NGN'));
        expect(transaction.email, equals(''));
        expect(transaction.status, equals('pending'));
        expect(transaction.createdAt, isNotNull);
      });

      test('toJson should convert FlutterwaveTransactionEntity to JSON', () {
        final json = testTransaction.toJson();

        expect(json['reference'], equals('FW_REF_123456'));
        expect(json['orderId'], equals('order_123'));
        expect(json['userId'], equals('user_456'));
        expect(json['amount'], equals(50000.0));
        expect(json['currency'], equals('NGN'));
        expect(json['email'], equals('test@example.com'));
        expect(json['status'], equals('pending'));
        expect(json['authorizationUrl'], equals('https://checkout.flutterwave.com/v3/hosted/pay/...'));
        expect(json['accessCode'], equals('fw_access_123'));
        expect(json['createdAt'], equals('2025-09-19T10:00:00.000Z'));
        expect(json['paidAt'], isNull);
        expect(json['metadata'], isNotNull);
      });

      test('toJson should handle null optional fields', () {
        final transaction = FlutterwaveTransactionEntity(
          reference: 'FW_REF_NULL',
          orderId: 'order_null',
          userId: 'user_null',
          amount: 15000.0,
          currency: 'NGN',
          email: 'null@example.com',
          status: 'pending',
          createdAt: DateTime.parse('2025-09-19T12:00:00.000Z'),
        );

        final json = transaction.toJson();

        expect(json['authorizationUrl'], isNull);
        expect(json['accessCode'], isNull);
        expect(json['paidAt'], isNull);
        expect(json['metadata'], isNull);
      });
    });

    group('CopyWith', () {
      test('copyWith should create new instance with updated fields', () {
        final updatedTransaction = testTransaction.copyWith(
          status: 'success',
          paidAt: DateTime.parse('2025-09-19T10:30:00.000Z'),
        );

        expect(updatedTransaction.status, equals('success'));
        expect(updatedTransaction.paidAt, equals(DateTime.parse('2025-09-19T10:30:00.000Z')));
        expect(updatedTransaction.reference, equals(testTransaction.reference));
        expect(updatedTransaction.orderId, equals(testTransaction.orderId));
        expect(updatedTransaction.userId, equals(testTransaction.userId));
      });

      test('copyWith should preserve original values when no updates provided', () {
        final copiedTransaction = testTransaction.copyWith();

        expect(copiedTransaction.reference, equals(testTransaction.reference));
        expect(copiedTransaction.orderId, equals(testTransaction.orderId));
        expect(copiedTransaction.userId, equals(testTransaction.userId));
        expect(copiedTransaction.amount, equals(testTransaction.amount));
        expect(copiedTransaction.status, equals(testTransaction.status));
      });

      test('copyWith should allow updating all fields', () {
        final completelyUpdated = testTransaction.copyWith(
          reference: 'NEW_REF',
          orderId: 'new_order',
          userId: 'new_user',
          amount: 75000.0,
          currency: 'USD',
          email: 'new@example.com',
          status: 'completed',
          authorizationUrl: 'https://new-url.com',
          accessCode: 'new_access',
          paidAt: DateTime.parse('2025-09-19T15:00:00.000Z'),
          metadata: {'newField': 'newValue'},
        );

        expect(completelyUpdated.reference, equals('NEW_REF'));
        expect(completelyUpdated.orderId, equals('new_order'));
        expect(completelyUpdated.userId, equals('new_user'));
        expect(completelyUpdated.amount, equals(75000.0));
        expect(completelyUpdated.currency, equals('USD'));
        expect(completelyUpdated.email, equals('new@example.com'));
        expect(completelyUpdated.status, equals('completed'));
        expect(completelyUpdated.authorizationUrl, equals('https://new-url.com'));
        expect(completelyUpdated.accessCode, equals('new_access'));
        expect(completelyUpdated.paidAt, equals(DateTime.parse('2025-09-19T15:00:00.000Z')));
        expect(completelyUpdated.metadata!['newField'], equals('newValue'));
      });
    });

    group('Edge Cases', () {
      test('should handle very large amounts', () {
        final largeAmountTransaction = testTransaction.copyWith(amount: 999999999.99);
        expect(largeAmountTransaction.amount, equals(999999999.99));
      });

      test('should handle empty strings', () {
        final emptyStringTransaction = FlutterwaveTransactionEntity(
          reference: '',
          orderId: '',
          userId: '',
          amount: 0.0,
          currency: '',
          email: '',
          status: '',
          createdAt: DateTime.now(),
        );

        expect(emptyStringTransaction.reference, equals(''));
        expect(emptyStringTransaction.orderId, equals(''));
        expect(emptyStringTransaction.userId, equals(''));
        expect(emptyStringTransaction.currency, equals(''));
        expect(emptyStringTransaction.email, equals(''));
        expect(emptyStringTransaction.status, equals(''));
      });

      test('should handle special characters in metadata', () {
        final specialMetadata = {
          'special_chars': 'àáâãäåæçèéêë',
          'unicode': '🎉💳✅',
          'numbers': '123456789',
          'mixed': 'Test@123#\$%^&*()',
        };

        final transaction = testTransaction.copyWith(metadata: specialMetadata);
        expect(transaction.metadata!['special_chars'], equals('àáâãäåæçèéêë'));
        expect(transaction.metadata!['unicode'], equals('🎉💳✅'));
        expect(transaction.metadata!['numbers'], equals('123456789'));
        expect(transaction.metadata!['mixed'], equals('Test@123#\$%^&*()'));
      });
    });
  });
}