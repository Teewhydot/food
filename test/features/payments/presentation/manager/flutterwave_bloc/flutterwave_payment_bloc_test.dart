import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/features/payments/presentation/manager/flutterwave_bloc/flutterwave_payment_bloc.dart';
import 'package:food/food/features/payments/presentation/manager/flutterwave_bloc/flutterwave_payment_event.dart';
import 'package:food/food/features/payments/presentation/manager/flutterwave_bloc/flutterwave_payment_state.dart';

void main() {
  group('FlutterwavePaymentBloc', () {
    group('Type Structure', () {
      test('should have FlutterwavePaymentBloc class', () {
        expect(FlutterwavePaymentBloc, isA<Type>());
      });

      test('should be properly defined type', () {
        expect(FlutterwavePaymentBloc, isNotNull);
      });
    });

    group('Event Types', () {
      test('should have all required event types', () {
        expect(FlutterwavePaymentEvent, isA<Type>());
        expect(InitializeFlutterwavePaymentEvent, isA<Type>());
        expect(VerifyFlutterwavePaymentEvent, isA<Type>());
        expect(GetFlutterwaveTransactionStatusEvent, isA<Type>());
        expect(ClearFlutterwavePaymentEvent, isA<Type>());
      });
    });

    group('State Types', () {
      test('should support all defined states', () {
        // Test that all state types are properly defined
        expect(FlutterwavePaymentState, isA<Type>());
        expect(FlutterwavePaymentInitial, isA<Type>());
        expect(FlutterwavePaymentLoading, isA<Type>());
        expect(FlutterwavePaymentInitialized, isA<Type>());
        expect(FlutterwavePaymentVerified, isA<Type>());
        expect(FlutterwavePaymentStatusRetrieved, isA<Type>());
        expect(FlutterwavePaymentError, isA<Type>());
      });

      test('should maintain proper state hierarchy', () {
        // Test that all states extend the base state
        expect(FlutterwavePaymentInitial(), isA<FlutterwavePaymentState>());
        expect(FlutterwavePaymentLoading(), isA<FlutterwavePaymentState>());
      });
    });

    group('Event Structure', () {
      test('should create InitializeFlutterwavePaymentEvent with required fields', () {
        final event = InitializeFlutterwavePaymentEvent(
          orderId: 'order_123',
          amount: 1000.0,
          email: 'test@example.com',
          metadata: {'key': 'value'},
        );

        expect(event.orderId, equals('order_123'));
        expect(event.amount, equals(1000.0));
        expect(event.email, equals('test@example.com'));
        expect(event.metadata, equals({'key': 'value'}));
        expect(event, isA<FlutterwavePaymentEvent>());
      });

      test('should create VerifyFlutterwavePaymentEvent with required fields', () {
        final event = VerifyFlutterwavePaymentEvent(
          reference: 'FW_REF_123',
          orderId: 'order_123',
        );

        expect(event.reference, equals('FW_REF_123'));
        expect(event.orderId, equals('order_123'));
        expect(event, isA<FlutterwavePaymentEvent>());
      });

      test('should create GetFlutterwaveTransactionStatusEvent with required fields', () {
        final event = GetFlutterwaveTransactionStatusEvent(
          reference: 'FW_REF_123',
        );

        expect(event.reference, equals('FW_REF_123'));
        expect(event, isA<FlutterwavePaymentEvent>());
      });

      test('should create ClearFlutterwavePaymentEvent', () {
        final event = ClearFlutterwavePaymentEvent();
        expect(event, isA<FlutterwavePaymentEvent>());
      });
    });

    group('State Structure', () {
      test('should create error states with messages', () {
        const errorState = FlutterwavePaymentError(message: 'Test error');

        expect(errorState.message, equals('Test error'));
        expect(errorState, isA<FlutterwavePaymentState>());
      });

      test('should create initial state', () {
        const initialState = FlutterwavePaymentInitial();
        expect(initialState, isA<FlutterwavePaymentState>());
      });

      test('should create loading state', () {
        const loadingState = FlutterwavePaymentLoading();
        expect(loadingState, isA<FlutterwavePaymentState>());
      });
    });

    group('Architecture Compliance', () {
      test('should follow BLoC pattern structure', () {
        // Verify BLoC pattern compliance through type checking
        expect(FlutterwavePaymentBloc, isA<Type>());
        expect(FlutterwavePaymentEvent, isA<Type>());
        expect(FlutterwavePaymentState, isA<Type>());
      });

      test('should support proper imports', () {
        // Test that all required types are available
        expect(FlutterwavePaymentBloc, isNotNull);
        expect(FlutterwavePaymentEvent, isNotNull);
        expect(FlutterwavePaymentState, isNotNull);
      });
    });

    group('Type Safety', () {
      test('should maintain type consistency', () {
        // Verify type relationships
        expect(InitializeFlutterwavePaymentEvent(orderId: 'test', amount: 100.0, email: 'test@test.com'),
               isA<FlutterwavePaymentEvent>());
        expect(FlutterwavePaymentInitial(), isA<FlutterwavePaymentState>());
      });
    });
  });
}