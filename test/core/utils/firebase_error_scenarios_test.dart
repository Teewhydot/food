import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/core/utils/error_handler.dart';
import 'package:food/food/domain/failures/failures.dart';

void main() {
  group('Firebase Error Scenarios', () {
    group('Real-World Authentication Flow', () {
      test('login with incorrect password shows user-friendly message', () async {
        // Simulate what happens in real Firebase Auth when password is wrong
        loginAttempt() async {
          // This is what Firebase SDK does - throws FirebaseAuthException automatically
          throw FirebaseAuthException(
            code: 'wrong-password',
            message: 'The password is invalid or the user does not have a password.',
          );
        }

        // Repository just wraps this with ErrorHandler - no manual exception handling needed
        final result = await ErrorHandler.handle(loginAttempt, operationName: 'User Login');

        // User sees friendly message, not technical Firebase error
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Incorrect password. Please try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('registration with existing email shows clear message', () async {
        // Simulate Firebase throwing exception when email already exists
        registrationAttempt() async {
          throw FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'The account already exists for that email.',
          );
        }

        final result = await ErrorHandler.handle(registrationAttempt, operationName: 'User Registration');

        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'An account already exists with this email');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('weak password validation happens automatically', () async {
        // Firebase SDK automatically validates password strength
        passwordValidation() async {
          throw FirebaseAuthException(
            code: 'weak-password',
            message: 'The password provided is too weak.',
          );
        }

        final result = await ErrorHandler.handle(passwordValidation, operationName: 'Password Validation');

        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Password is too weak. Please choose a stronger password');
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Real-World Firestore Operations', () {
      test('permission denied on restricted document access', () async {
        // Simulate Firestore security rules denying access
        documentAccess() async {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
            message: 'Missing or insufficient permissions.',
          );
        }

        final result = await ErrorHandler.handle(documentAccess, operationName: 'Document Access');

        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.failureMessage, 'You don\'t have permission to perform this action');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('document not found shows user-friendly message', () async {
        // Simulate accessing non-existent document
        documentFetch() async {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'not-found',
            message: 'Some requested document was not found.',
          );
        }

        final result = await ErrorHandler.handle(documentFetch, operationName: 'Fetch Document');

        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.failureMessage, 'The requested data was not found');
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Network and Connection Issues', () {
      test('no internet connection during Firebase operation', () async {
        // Network layer throws SocketException when no internet
        networkOperation() async {
          throw const SocketException('Failed host lookup: \'firebase.com\'');
        }

        final result = await ErrorHandler.handle(networkOperation, operationName: 'Firebase API Call');

        result.fold(
          (failure) {
            expect(failure, isA<NoInternetFailure>());
            expect(failure.failureMessage, 'Please check your internet connection and try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('timeout during Firebase authentication', () async {
        // .timeout() automatically throws TimeoutException
        timeoutAuth() async {
          throw TimeoutException('Firebase Auth timeout', const Duration(seconds: 30));
        }

        final result = await ErrorHandler.handle(timeoutAuth, operationName: 'Firebase Auth');

        result.fold(
          (failure) {
            expect(failure, isA<TimeoutFailure>());
            expect(failure.failureMessage, 'Request timed out. Please try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Edge Cases and Rare Errors', () {
      test('Firebase internal error maps to server failure', () async {
        // Rare Firebase internal errors
        internalError() async {
          throw FirebaseException(
            plugin: 'firebase_auth',
            code: 'internal',
            message: 'Internal server error occurred.',
          );
        }

        final result = await ErrorHandler.handle(internalError, operationName: 'Internal Operation');

        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.failureMessage, 'Internal server error. Please try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('unknown Firebase error falls back to original message', () async {
        // Firebase might introduce new error codes
        unknownError() async {
          throw FirebaseAuthException(
            code: 'new-error-code-2024',
            message: 'New type of Firebase error',
          );
        }

        final result = await ErrorHandler.handle(unknownError, operationName: 'Unknown Error Test');

        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'New type of Firebase error');
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Multiple Exception Types in Same Flow', () {
      test('handles different exceptions in user registration flow', () async {
        final testScenarios = [
          {
            'name': 'Invalid Email Format',
            'exception': FirebaseAuthException(code: 'invalid-email', message: 'Bad email'),
            'expectedType': AuthFailure,
            'expectedMessage': 'Please enter a valid email address',
          },
          {
            'name': 'Network Interruption',
            'exception': const SocketException('Connection lost'),
            'expectedType': NoInternetFailure,
            'expectedMessage': 'Please check your internet connection and try again',
          },
          {
            'name': 'Server Timeout',
            'exception': TimeoutException('Timeout', const Duration(seconds: 10)),
            'expectedType': TimeoutFailure,
            'expectedMessage': 'Request timed out. Please try again',
          },
          {
            'name': 'Unexpected Error',
            'exception': Exception('Unexpected system error'),
            'expectedType': UnknownFailure,
            'expectedMessage': 'Something went wrong. Please try again',
          },
        ];

        for (final scenario in testScenarios) {
          // Simulate different types of errors that can occur during registration
          registrationFlow() async {
            throw scenario['exception']!;
          }

          final result = await ErrorHandler.handle(
            registrationFlow,
            operationName: 'Registration: ${scenario['name']}',
          );

          result.fold(
            (failure) {
              expect(failure.runtimeType, scenario['expectedType'], 
                reason: 'Failed for scenario: ${scenario['name']}');
              expect(failure.failureMessage, scenario['expectedMessage'],
                reason: 'Wrong message for scenario: ${scenario['name']}');
            },
            (_) => fail('Expected failure for scenario: ${scenario['name']}'),
          );
        }
      });
    });

    group('Proves No Manual Exception Handling Needed', () {
      test('repository methods work without try-catch blocks', () async {
        // This test proves that repository methods don't need manual try-catch
        // because ErrorHandler.handle() does all the exception catching automatically

        // Simulate typical repository method implementation
        Future<Either<Failure, String>> simulateRepositoryMethod() async {
          // Repository just calls the service and wraps with ErrorHandler
          // No try-catch needed because ErrorHandler catches everything
          return ErrorHandler.handle(() async {
            // Service layer throws exceptions naturally (no manual throwing)
            throw FirebaseAuthException(code: 'user-disabled', message: 'Account disabled');
          });
        }

        // Act
        final result = await simulateRepositoryMethod();

        // Assert - Repository gets clean Either result without manual exception handling
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'This account has been disabled. Contact support');
            // This proves:
            // ✅ Repository didn't need try-catch
            // ✅ Service threw exception naturally
            // ✅ ErrorHandler caught and converted automatically
            // ✅ Repository got clean Either<Failure, T> result
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('data sources throw exceptions naturally without manual intervention', () async {
        // This proves that data sources (Firebase calls) throw exceptions automatically
        // We don't need to manually throw or catch anything

        simulateFirebaseDataSource() async {
          // Firebase SDK methods throw exceptions automatically when they fail
          // We don't manually check for errors or throw custom exceptions
          throw FirebaseAuthException(
            code: 'requires-recent-login',
            message: 'This operation requires recent authentication',
          );
        }

        // Repository wraps data source call with ErrorHandler (no try-catch needed)
        final result = await ErrorHandler.handle(simulateFirebaseDataSource);

        // Assert - Everything works automatically
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Please log in again to continue');
            // This proves the entire flow works without manual exception handling:
            // 1. Firebase SDK throws exception automatically ✅
            // 2. Repository wraps call with ErrorHandler.handle() ✅  
            // 3. ErrorHandler catches and converts exception automatically ✅
            // 4. Repository receives clean Either<Failure, T> ✅
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });
  });
}