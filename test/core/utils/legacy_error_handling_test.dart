import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/core/utils/error_handler.dart';
import 'package:food/food/core/utils/handle_exceptions.dart';
import 'package:food/food/domain/failures/failures.dart';

void main() {
  group('Legacy Error Handling Compatibility', () {
    group('handleExceptions() Wrapper Function', () {
      test('legacy handleExceptions function works with new ErrorHandler', () async {
        // The legacy handleExceptions function is just a thin wrapper around ErrorHandler.handle()
        // This ensures backward compatibility for existing code that uses handleExceptions()

        // Arrange
        operation() async => throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found',
        );

        // Act - Using legacy function
        final result = await handleExceptions(operation);

        // Assert - Same behavior as ErrorHandler.handle()
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'No account found with this email address');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('legacy handleExceptions maintains identical behavior to ErrorHandler.handle', () async {
        final testCases = [
          {
            'exception': FirebaseAuthException(code: 'wrong-password', message: 'Wrong password'),
            'expectedType': AuthFailure,
            'expectedMessage': 'Incorrect password. Please try again',
          },
          {
            'exception': const SocketException('Network error'),
            'expectedType': NoInternetFailure,
            'expectedMessage': 'Please check your internet connection and try again',
          },
          {
            'exception': TimeoutException('Timeout', const Duration(seconds: 5)),
            'expectedType': TimeoutFailure,
            'expectedMessage': 'Request timed out. Please try again',
          },
        ];

        for (final testCase in testCases) {
          // Test both legacy and new approach give identical results
          operation() async => throw testCase['exception']!;

          final legacyResult = await handleExceptions(operation);
          final newResult = await ErrorHandler.handle(operation);

          // Both should produce identical results
          expect(legacyResult.runtimeType, newResult.runtimeType);
          
          legacyResult.fold(
            (legacyFailure) => newResult.fold(
              (newFailure) {
                expect(legacyFailure.runtimeType, newFailure.runtimeType);
                expect(legacyFailure.failureMessage, newFailure.failureMessage);
              },
              (_) => fail('Results should both be failures'),
            ),
            (legacySuccess) => newResult.fold(
              (_) => fail('Results should both be successes'),
              (newSuccess) => expect(legacySuccess, newSuccess),
            ),
          );
        }
      });
    });

    group('Migration Path Validation', () {
      test('existing repositories can migrate gradually without breaking changes', () async {
        // This test shows that existing code using handleExceptions() 
        // continues to work while new code can use ErrorHandler.handle() directly

        // Simulate old repository method using handleExceptions
        Future<Either<Failure, String>> oldRepositoryMethod() async {
          return handleExceptions(() async {
            throw FirebaseAuthException(code: 'email-already-in-use', message: 'Email in use');
          });
        }

        // Simulate new repository method using ErrorHandler.handle directly
        Future<Either<Failure, String>> newRepositoryMethod() async {
          return ErrorHandler.handle(() async {
            throw FirebaseAuthException(code: 'email-already-in-use', message: 'Email in use');
          });
        }

        // Act
        final oldResult = await oldRepositoryMethod();
        final newResult = await newRepositoryMethod();

        // Assert - Both approaches work identically
        expect(oldResult.runtimeType, newResult.runtimeType);
        
        oldResult.fold(
          (oldFailure) => newResult.fold(
            (newFailure) {
              expect(oldFailure.runtimeType, newFailure.runtimeType);
              expect(oldFailure.failureMessage, newFailure.failureMessage);
              expect(newFailure.failureMessage, 'An account already exists with this email');
            },
            (_) => fail('Both should be failures'),
          ),
          (_) => fail('Expected failures but got success'),
        );
      });
    });

    group('Deprecated Pattern Elimination', () {
      test('proves old manual try-catch pattern is no longer needed', () async {
        // This test shows that the old pattern of manual try-catch in repositories
        // is no longer needed with the new ErrorHandler approach

        // OLD PATTERN (no longer needed):
        // Future<Either<Failure, T>> oldManualPattern() async {
        //   try {
        //     final result = await someFirebaseCall();
        //     return Right(result);
        //   } on FirebaseAuthException catch (e) {
        //     if (e.code == 'user-not-found') {
        //       return Left(AuthFailure(failureMessage: 'No user found'));
        //     }
        //     // ... lots of manual error checking
        //   } on SocketException catch (_) {
        //     return Left(NoInternetFailure(failureMessage: 'No internet'));
        //   }
        //   // ... more manual catch blocks
        // }

        // NEW PATTERN (much simpler):
        Future<Either<Failure, String>> newSimplifiedPattern() async {
          return ErrorHandler.handle(() async {
            // Just call the operation - no manual try-catch needed
            throw FirebaseAuthException(code: 'user-not-found', message: 'No user record');
          });
        }

        // Act
        final result = await newSimplifiedPattern();

        // Assert - New pattern gives better error messages with less code
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'No account found with this email address');
            // This user-friendly message was generated automatically by ErrorHandler
            // No manual error message crafting needed in the repository
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('proves no need for custom exception classes in repositories', () async {
        // Old pattern required custom exception classes and manual throwing
        // New pattern uses Firebase exceptions directly and converts them automatically

        // Simulate what Firebase SDK does naturally
        firebaseOperation() async {
          throw FirebaseAuthException(code: 'weak-password', message: 'Password too weak');
        }

        // New pattern - just wrap with ErrorHandler
        final result = await ErrorHandler.handle(firebaseOperation);

        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Password is too weak. Please choose a stronger password');
            // This proves:
            // ✅ No custom exception classes needed
            // ✅ No manual exception throwing in repositories  
            // ✅ Firebase exceptions converted automatically
            // ✅ User gets friendly messages without manual crafting
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Consistency Validation', () {
      test('all error types get consistent handling regardless of entry point', () async {
        // Test that the same exception type gets the same treatment
        // whether using handleExceptions() or ErrorHandler.handle() directly

        final exceptionTypes = [
          FirebaseAuthException(code: 'invalid-email', message: 'Invalid email'),
          const SocketException('Network failure'),
          TimeoutException('Request timeout', const Duration(seconds: 10)),
          const FormatException('Bad format'),
          Exception('Generic error'),
        ];

        for (final exception in exceptionTypes) {
          operation() async => throw exception;

          // Test both entry points
          final legacyResult = await handleExceptions(operation);
          final directResult = await ErrorHandler.handle(operation);

          // Results should be identical
          expect(legacyResult.runtimeType, directResult.runtimeType);
          
          legacyResult.fold(
            (legacyFailure) => directResult.fold(
              (directFailure) {
                expect(legacyFailure.runtimeType, directFailure.runtimeType);
                expect(legacyFailure.failureMessage, directFailure.failureMessage);
              },
              (_) => fail('Both should be failures for $exception'),
            ),
            (legacySuccess) => directResult.fold(
              (_) => fail('Both should be successes for $exception'),
              (directSuccess) => expect(legacySuccess, directSuccess),
            ),
          );
        }
      });

      test('operation names work consistently across both approaches', () async {
        // Test that operation naming works the same way

        operation() async => throw FirebaseAuthException(
          code: 'user-disabled',
          message: 'User account disabled',
        );

        // Legacy approach doesn't support operation names (limitation)
        final legacyResult = await handleExceptions(operation);
        
        // New approach supports operation names for better logging
        final namedResult = await ErrorHandler.handle(operation, operationName: 'Test Operation');

        // Error conversion should be identical even without operation name
        legacyResult.fold(
          (legacyFailure) => namedResult.fold(
            (namedFailure) {
              expect(legacyFailure.runtimeType, namedFailure.runtimeType);
              expect(legacyFailure.failureMessage, namedFailure.failureMessage);
              expect(namedFailure.failureMessage, 'This account has been disabled. Contact support');
            },
            (_) => fail('Both should be failures'),
          ),
          (_) => fail('Expected failures but got success'),
        );
      });
    });

    group('Future-Proofing', () {
      test('new Firebase error codes work automatically without code changes', () async {
        // If Firebase introduces new error codes, they should work automatically
        // without requiring code changes in repositories

        futureFirebaseError() async {
          throw FirebaseAuthException(
            code: 'future-error-2025',
            message: 'New Firebase feature error',
          );
        }

        final result = await ErrorHandler.handle(futureFirebaseError);

        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            // For unknown codes, falls back to original Firebase message
            expect(failure.failureMessage, 'New Firebase feature error');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('system works with any async operation that might throw', () async {
        // The pattern works for any async operation, not just Firebase
        
        final testOperations = [
          () async => throw HttpException('HTTP error'),
          () async => throw const OSError('OS error', 1),
          () async => throw StateError('Invalid state'),
          () async => throw ArgumentError('Invalid argument'),
        ];

        for (final operation in testOperations) {
          final result = await ErrorHandler.handle(operation);

          // All should be converted to UnknownFailure with user-friendly message
          result.fold(
            (failure) {
              expect(failure, isA<UnknownFailure>());
              expect(failure.failureMessage, 'Something went wrong. Please try again');
            },
            (_) => fail('Expected failure but got success'),
          );
        }
      });
    });
  });
}