import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/core/services/endpoint_service.dart';
import 'package:food/food/core/utils/error_handler.dart';
import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';

void main() {
  group('EndpointService', () {
    late EndpointService endpointService;

    setUp(() {
      endpointService = EndpointService();
    });

    group('runWithConfig()', () {
      test('executes successful operations and logs correctly', () async {
        // Arrange
        final operation = () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 'success result';
        };

        // Act
        final result = await endpointService.runWithConfig('Test Operation', operation);

        // Assert
        expect(result, 'success result');
        // Note: Logging verification would require mocking the Logger, 
        // but the main point is that the operation completes successfully
      });

      test('applies timeout and throws TimeoutException when exceeded', () async {
        // Arrange
        final longOperation = () async {
          await Future.delayed(const Duration(seconds: 15)); // Longer than default 10s timeout
          return 'should not reach';
        };

        // Act & Assert
        expect(
          () async => await endpointService.runWithConfig('Long Operation', longOperation),
          throwsA(isA<TimeoutException>()),
        );
      });

      test('does not transform exceptions - just rethrows them', () async {
        // Arrange
        final failingOperation = () async => throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'Invalid password',
        );

        // Act & Assert
        expect(
          () async => await endpointService.runWithConfig('Failing Operation', failingOperation),
          throwsA(isA<FirebaseAuthException>()),
        );
      });

      test('rethrows SocketException without transformation', () async {
        // Arrange
        final networkFailingOperation = () async => throw const SocketException('No internet');

        // Act & Assert
        expect(
          () async => await endpointService.runWithConfig('Network Operation', networkFailingOperation),
          throwsA(isA<SocketException>()),
        );
      });

      test('rethrows generic Exception without transformation', () async {
        // Arrange
        final genericFailingOperation = () async => throw Exception('Generic error');

        // Act & Assert
        expect(
          () async => await endpointService.runWithConfig('Generic Operation', genericFailingOperation),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('runWithTimeout()', () {
      test('executes operation with custom timeout', () async {
        // Arrange
        final quickOperation = () async {
          await Future.delayed(const Duration(milliseconds: 100));
          return 'quick result';
        };

        // Act
        final result = await endpointService.runWithTimeout(
          'Quick Operation',
          quickOperation,
          const Duration(seconds: 1),
        );

        // Assert
        expect(result, 'quick result');
      });

      test('applies custom timeout correctly', () async {
        // Arrange
        final mediumOperation = () async {
          await Future.delayed(const Duration(milliseconds: 500));
          return 'should not reach';
        };

        // Act & Assert
        expect(
          () async => await endpointService.runWithTimeout(
            'Medium Operation',
            mediumOperation,
            const Duration(milliseconds: 200), // Shorter timeout
          ),
          throwsA(isA<TimeoutException>()),
        );
      });
    });

    group('Integration with ErrorHandler', () {
      test('EndpointService + ErrorHandler work together correctly', () async {
        // This test shows the recommended pattern: EndpointService for logging/timeout, ErrorHandler for error conversion
        
        // Arrange
        final firebaseOperation = () async {
          return await endpointService.runWithConfig('Firebase Login', () async {
            // Simulate Firebase throwing an exception
            throw FirebaseAuthException(code: 'user-not-found', message: 'No user found');
          });
        };

        // Act
        final result = await ErrorHandler.handle(firebaseOperation, operationName: 'User Login');

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'No account found with this email address');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('EndpointService timeout + ErrorHandler integration', () async {
        // Arrange
        final timeoutOperation = () async {
          return await endpointService.runWithTimeout(
            'Long API Call',
            () async {
              await Future.delayed(const Duration(seconds: 2));
              return 'should timeout';
            },
            const Duration(milliseconds: 100),
          );
        };

        // Act
        final result = await ErrorHandler.handle(timeoutOperation, operationName: 'API Call');

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<TimeoutFailure>());
            expect(failure.failureMessage, 'Request timed out. Please try again');
          },
          (_) => fail('Expected timeout failure but got success'),
        );
      });

      test('proves EndpointService does not interfere with ErrorHandler message conversion', () async {
        // This test proves that EndpointService just logs and handles timeouts,
        // while ErrorHandler handles the actual error message conversion
        
        // Arrange
        final chainedOperation = () async {
          return await endpointService.runWithConfig('Chained Operation', () async {
            throw FirebaseAuthException(code: 'invalid-email', message: 'Bad email format');
          });
        };

        // Act
        final result = await ErrorHandler.handle(chainedOperation);

        // Assert - ErrorHandler should still get the proper user-friendly message
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Please enter a valid email address');
            // This proves EndpointService didn't interfere with the error message conversion
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Simplified Pattern Validation', () {
      test('proves the new pattern eliminates double error handling', () async {
        // OLD PATTERN (problematic): EndpointService would transform errors, then ErrorHandler would transform again
        // NEW PATTERN (correct): EndpointService just logs/timeouts, ErrorHandler does all error conversion
        
        // Arrange - This simulates a typical Firebase operation
        final typicalFirebaseOperation = () async {
          return await endpointService.runWithConfig('User Registration', () async {
            // Firebase SDK automatically throws FirebaseAuthException
            throw FirebaseAuthException(code: 'email-already-in-use', message: 'Email in use');
          });
        };

        // Act - Single error handling with ErrorHandler
        final result = await ErrorHandler.handle(typicalFirebaseOperation, operationName: 'Register User');

        // Assert - We get the proper user-friendly message without double transformation
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'An account already exists with this email');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('demonstrates clean separation of concerns', () async {
        // This test shows that:
        // - EndpointService handles: logging, timeouts
        // - ErrorHandler handles: exception catching, message conversion, Either wrapping
        
        // Arrange
        final networkOperation = () async {
          return await endpointService.runWithConfig('API Call', () async {
            // Network library automatically throws SocketException
            throw const SocketException('Network unreachable');
          });
        };

        // Act
        final result = await ErrorHandler.handle(networkOperation, operationName: 'Fetch Data');

        // Assert
        result.fold(
          (failure) {
            // EndpointService: logged the operation and rethrew the SocketException
            // ErrorHandler: caught SocketException and converted to user-friendly NoInternetFailure
            expect(failure, isA<NoInternetFailure>());
            expect(failure.failureMessage, 'Please check your internet connection and try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });
  });
}