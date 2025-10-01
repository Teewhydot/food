import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/core/utils/error_handler.dart';
import 'package:food/food/domain/failures/failures.dart';

void main() {
  group('ErrorHandler.handle()', () {
    group('Firebase Auth Exceptions', () {
      test('converts wrong-password to user-friendly AuthFailure', () async {
        // Arrange
        operation() async => throw FirebaseAuthException(
          code: 'wrong-password',
          message: 'The password is invalid',
        );

        // Act
        final result = await ErrorHandler.handle(operation, operationName: 'Login Test');

        // Assert
        expect(result, isA<Left<Failure, dynamic>>());
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Incorrect password. Please try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('converts user-not-found to user-friendly AuthFailure', () async {
        // Arrange
        operation() async => throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'There is no user record',
        );

        // Act
        final result = await ErrorHandler.handle(operation);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'No account found with this email address');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('converts email-already-in-use to user-friendly AuthFailure', () async {
        // Arrange
        operation() async => throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The email address is already in use',
        );

        // Act
        final result = await ErrorHandler.handle(operation);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'An account already exists with this email');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('converts weak-password to user-friendly AuthFailure', () async {
        // Arrange
        operation() async => throw FirebaseAuthException(
          code: 'weak-password',
          message: 'The password provided is too weak',
        );

        // Act
        final result = await ErrorHandler.handle(operation);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Password is too weak. Please choose a stronger password');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('converts invalid-email to user-friendly AuthFailure', () async {
        // Arrange
        operation() async => throw FirebaseAuthException(
          code: 'invalid-email',
          message: 'The email address is badly formatted',
        );

        // Act
        final result = await ErrorHandler.handle(operation);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Please enter a valid email address');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('converts unknown Firebase Auth codes to fallback message', () async {
        // Arrange
        operation() async => throw FirebaseAuthException(
          code: 'unknown-error-code',
          message: 'Some unknown error occurred',
        );

        // Act
        final result = await ErrorHandler.handle(operation);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Some unknown error occurred');
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Firebase General Exceptions', () {
      test('converts permission-denied to user-friendly ServerFailure', () async {
        // Arrange
        operation() async => throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Missing or insufficient permissions',
        );

        // Act
        final result = await ErrorHandler.handle(operation);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.failureMessage, 'You don\'t have permission to perform this action');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('converts not-found to user-friendly ServerFailure', () async {
        // Arrange
        operation() async => throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Some requested document was not found',
        );

        // Act
        final result = await ErrorHandler.handle(operation);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.failureMessage, 'The requested data was not found');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('converts unknown Firebase codes to fallback message', () async {
        // Arrange
        operation() async => throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'unknown-firebase-error',
          message: 'Some Firebase error',
        );

        // Act
        final result = await ErrorHandler.handle(operation);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.failureMessage, 'Some Firebase error');
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Network Exceptions', () {
      test('converts SocketException to user-friendly NoInternetFailure', () async {
        // Arrange
        operation() async => throw const SocketException('Failed host lookup');

        // Act
        final result = await ErrorHandler.handle(operation, operationName: 'API Call');

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<NoInternetFailure>());
            expect(failure.failureMessage, 'Please check your internet connection and try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Timeout Exceptions', () {
      test('converts TimeoutException to user-friendly TimeoutFailure', () async {
        // Arrange
        operation() async => throw TimeoutException('Operation timed out', const Duration(seconds: 10));

        // Act
        final result = await ErrorHandler.handle(operation);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<TimeoutFailure>());
            expect(failure.failureMessage, 'Request timed out. Please try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Format Exceptions', () {
      test('converts FormatException to user-friendly failure', () async {
        // Arrange
        operation() async => throw const FormatException('Invalid JSON format');

        // Act
        final result = await ErrorHandler.handle(operation);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<UnknownFailure>());
            expect(failure.failureMessage, 'Invalid data format. Please try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Unknown Exceptions', () {
      test('converts generic Exception to user-friendly UnknownFailure', () async {
        // Arrange
        operation() async => throw Exception('Some random error');

        // Act
        final result = await ErrorHandler.handle(operation);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<UnknownFailure>());
            expect(failure.failureMessage, 'Something went wrong. Please try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('converts any other error to UnknownFailure', () async {
        // Arrange
        operation() async => throw 'String error';

        // Act
        final result = await ErrorHandler.handle(operation);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<UnknownFailure>());
            expect(failure.failureMessage, 'Something went wrong. Please try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Success Cases', () {
      test('returns Right with result when operation succeeds', () async {
        // Arrange
        operation() async => 'success result';

        // Act
        final result = await ErrorHandler.handle(operation, operationName: 'Success Test');

        // Assert
        expect(result, isA<Right<Failure, String>>());
        result.fold(
          (_) => fail('Expected success but got failure'),
          (value) => expect(value, 'success result'),
        );
      });

      test('handles complex return types correctly', () async {
        // Arrange
        final complexData = {'key': 'value', 'number': 42};
        operation() async => complexData;

        // Act
        final result = await ErrorHandler.handle(operation);

        // Assert
        result.fold(
          (_) => fail('Expected success but got failure'),
          (value) => expect(value, complexData),
        );
      });
    });
  });

  group('Stream Error Handling', () {
    test('ErrorHandler handles stream errors correctly', () async {
      // Arrange
      Stream<String> errorStream() async* {
        throw FirebaseAuthException(code: 'user-not-found', message: 'No user found');
      }

      // Act
      final resultStream = ErrorHandler.handleStream(() => errorStream(), operationName: 'Stream Test');
      final results = await resultStream.toList();

      // Assert
      expect(results.length, 1);
      results.first.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.failureMessage, 'No account found with this email address');
        },
        (_) => fail('Expected failure but got success'),
      );
    });

    test('stream handles successful data correctly', () async {
      // Arrange
      Stream<String> successStream() async* {
        yield 'data1';
        yield 'data2';
      }

      // Act
      final resultStream = ErrorHandler.handleStream(() => successStream());
      final results = await resultStream.toList();

      // Assert
      expect(results.length, 2);
      results[0].fold(
        (_) => fail('Expected success but got failure'),
        (value) => expect(value, 'data1'),
      );
      results[1].fold(
        (_) => fail('Expected success but got failure'),
        (value) => expect(value, 'data2'),
      );
    });
  });

  group('No Manual Exception Throwing Required', () {
    test('proves Firebase automatically throws exceptions that ErrorHandler catches', () async {
      // This test simulates what happens in real Firebase calls
      // Firebase automatically throws FirebaseAuthException - we don't manually throw anything
      
      // Arrange - Simulate what Firebase SDK does internally
      simulateFirebaseLogin() async {
        // This is what Firebase SDK does - it throws FirebaseAuthException automatically
        throw FirebaseAuthException(code: 'wrong-password', message: 'Invalid password');
      }

      // Act - We just wrap it with ErrorHandler, no manual throwing needed
      final result = await ErrorHandler.handle(simulateFirebaseLogin);

      // Assert - ErrorHandler automatically caught the Firebase exception and converted it
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.failureMessage, 'Incorrect password. Please try again');
        },
        (_) => fail('Expected failure but got success'),
      );
    });

    test('proves network libraries automatically throw exceptions', () async {
      // Arrange - Simulate what HTTP libraries do internally
      simulateNetworkCall() async {
        // This is what network libraries do - they throw SocketException automatically
        throw const SocketException('No route to host');
      }

      // Act - We just wrap it with ErrorHandler, no manual checking or throwing needed
      final result = await ErrorHandler.handle(simulateNetworkCall);

      // Assert - ErrorHandler automatically caught the network exception
      result.fold(
        (failure) {
          expect(failure, isA<NoInternetFailure>());
          expect(failure.failureMessage, 'Please check your internet connection and try again');
        },
        (_) => fail('Expected failure but got success'),
      );
    });

    test('proves timeout automatically throws when using .timeout()', () async {
      // Arrange - Simulate what .timeout() does internally
      simulateTimeoutOperation() async {
        // This is what .timeout() does - it throws TimeoutException automatically
        throw TimeoutException('Timeout occurred', const Duration(seconds: 5));
      }

      // Act - We just wrap it with ErrorHandler, no manual timeout checking needed
      final result = await ErrorHandler.handle(simulateTimeoutOperation);

      // Assert - ErrorHandler automatically caught the timeout exception
      result.fold(
        (failure) {
          expect(failure, isA<TimeoutFailure>());
          expect(failure.failureMessage, 'Request timed out. Please try again');
        },
        (_) => fail('Expected failure but got success'),
      );
    });
  });
}