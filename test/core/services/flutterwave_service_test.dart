import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/core/services/flutterwave_service.dart';
import 'package:food/food/core/services/endpoint_service.dart';

void main() {
  group('FlutterwaveService', () {
    late FlutterwaveService flutterwaveService;
    late EndpointService endpointService;

    setUp(() {
      endpointService = EndpointService();
      flutterwaveService = FlutterwaveService(endpointService);
    });

    group('Constructor and Setup', () {
      test('should create FlutterwaveService instance', () {
        expect(flutterwaveService, isNotNull);
        expect(flutterwaveService, isA<FlutterwaveService>());
      });
    });

    group('getPaymentUrl', () {
      test('should return authorization URL', () {
        // Arrange
        const authorizationUrl = 'https://checkout.flutterwave.com/v3/hosted/pay/test';
        const reference = 'FW_REF_123456';

        // Act
        final result = flutterwaveService.getPaymentUrl(
          authorizationUrl: authorizationUrl,
          reference: reference,
        );

        // Assert
        expect(result, equals(authorizationUrl));
      });

      test('should handle empty URL gracefully', () {
        // Arrange
        const authorizationUrl = '';
        const reference = 'FW_REF_123456';

        // Act
        final result = flutterwaveService.getPaymentUrl(
          authorizationUrl: authorizationUrl,
          reference: reference,
        );

        // Assert
        expect(result, equals(''));
      });
    });

    group('parsePaymentCallback', () {
      test('should parse successful payment callback', () {
        // Arrange
        const callbackUrl = 'https://yourapp.com/callback?status=successful&tx_ref=FW_REF_123456&transaction_id=123456789';

        // Act
        final result = flutterwaveService.parsePaymentCallback(callbackUrl);

        // Assert
        expect(result['status'], equals('successful'));
        expect(result['tx_ref'], equals('FW_REF_123456'));
        expect(result['transaction_id'], equals('123456789'));
      });

      test('should parse failed payment callback', () {
        // Arrange
        const callbackUrl = 'https://yourapp.com/callback?status=cancelled';

        // Act
        final result = flutterwaveService.parsePaymentCallback(callbackUrl);

        // Assert
        expect(result['status'], equals('cancelled'));
      });

      test('should handle callback URL without parameters', () {
        // Arrange
        const callbackUrl = 'https://yourapp.com/callback';

        // Act
        final result = flutterwaveService.parsePaymentCallback(callbackUrl);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['status'], equals('unknown'));
      });

      test('should handle malformed callback URL gracefully', () {
        // Arrange
        const callbackUrl = 'invalid-url';

        // Act
        final result = flutterwaveService.parsePaymentCallback(callbackUrl);

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['status'], equals('unknown'));
        expect(result['tx_ref'], isNull);
        expect(result['transaction_id'], isNull);
        expect(result['flw_ref'], isNull);
      });

      test('should parse callback with flw_ref parameter', () {
        // Arrange
        const callbackUrl = 'https://yourapp.com/callback?status=successful&tx_ref=FW_REF_123&flw_ref=FLW123456';

        // Act
        final result = flutterwaveService.parsePaymentCallback(callbackUrl);

        // Assert
        expect(result['status'], equals('successful'));
        expect(result['tx_ref'], equals('FW_REF_123'));
        expect(result['flw_ref'], equals('FLW123456'));
      });
    });

    group('Service Configuration', () {
      test('should be properly configured with EndpointService', () {
        // This test verifies that the service is properly initialized
        // and the dependency injection is working
        expect(flutterwaveService, isNotNull);

        // Test that the service can handle basic operations
        const url = 'https://test.com';
        const ref = 'test_ref';

        final paymentUrl = flutterwaveService.getPaymentUrl(
          authorizationUrl: url,
          reference: ref,
        );

        expect(paymentUrl, equals(url));
      });
    });

    group('Error Handling', () {
      test('should handle edge cases in parsePaymentCallback', () {
        // Test with URL containing special characters
        const specialUrl = 'https://app.com/callback?status=success&data=test%20with%20spaces';

        final result = flutterwaveService.parsePaymentCallback(specialUrl);
        expect(result['status'], equals('success'));
      });

      test('should handle URL with multiple parameters', () {
        const complexUrl = 'https://app.com/callback?status=successful&tx_ref=FW_123&transaction_id=456&amount=5000&currency=NGN';

        final result = flutterwaveService.parsePaymentCallback(complexUrl);
        expect(result['status'], equals('successful'));
        expect(result['tx_ref'], equals('FW_123'));
        expect(result['transaction_id'], equals('456'));
      });
    });
  });
}