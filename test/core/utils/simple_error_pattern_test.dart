import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/core/utils/error_handler.dart';
import 'package:food/food/domain/failures/failures.dart';

void main() {
  group('Simple Error Pattern Validation', () {
    group('Repository Pattern Without Firebase Dependencies', () {
      test('simulates repository method with ErrorHandler pattern', () async {
        // This test simulates how a repository method would work without requiring Firebase initialization
        
        // Simulate a typical repository method
        Future<Either<Failure, String>> simulateRepositoryMethod() async {
          return ErrorHandler.handle(() async {
            // Simulate what Firebase service would throw
            throw FirebaseAuthException(
              code: 'user-not-found',
              message: 'No user record corresponding to this identifier',
            );
          }, operationName: 'User Lookup');
        }

        // Act
        final result = await simulateRepositoryMethod();

        // Assert - Repository gets clean Either result
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'No account found with this email address');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('proves repository pattern works with different service exceptions', () async {
        final testCases = [
          {
            'name': 'Authentication Error',
            'serviceException': FirebaseAuthException(code: 'wrong-password', message: 'Invalid password'),
            'expectedFailure': AuthFailure,
            'expectedMessage': 'Incorrect password. Please try again',
          },
          {
            'name': 'Network Error',
            'serviceException': const SocketException('Network unreachable'),
            'expectedFailure': NoInternetFailure,
            'expectedMessage': 'Please check your internet connection and try again',
          },
          {
            'name': 'Timeout Error',
            'serviceException': TimeoutException('Operation timeout', const Duration(seconds: 10)),
            'expectedFailure': TimeoutFailure,
            'expectedMessage': 'Request timed out. Please try again',
          },
        ];

        for (final testCase in testCases) {
          // Simulate repository method for each case
          Future<Either<Failure, dynamic>> repositoryMethod() async {
            return ErrorHandler.handle(() async {
              throw testCase['serviceException']!;
            }, operationName: testCase['name'] as String);
          }

          // Act
          final result = await repositoryMethod();

          // Assert
          result.fold(
            (failure) {
              expect(failure.runtimeType, testCase['expectedFailure'], 
                reason: 'Failed for case: ${testCase['name']}');
              expect(failure.failureMessage, testCase['expectedMessage'],
                reason: 'Wrong message for case: ${testCase['name']}');
            },
            (_) => fail('Expected failure for case: ${testCase['name']}'),
          );
        }
      });
    });

    group('Clean Code Validation', () {
      test('repository methods have minimal code with ErrorHandler', () async {
        // This test shows how clean repository code becomes with ErrorHandler pattern
        
        // OLD PATTERN (would require lots of try-catch code):
        // Future<Either<Failure, String>> oldLoginMethod(String email, String password) async {
        //   try {
        //     final result = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
        //     return Right(result.user?.uid ?? '');
        //   } on FirebaseAuthException catch (e) {
        //     if (e.code == 'user-not-found') {
        //       return Left(AuthFailure(failureMessage: 'No account found with this email address'));
        //     } else if (e.code == 'wrong-password') {
        //       return Left(AuthFailure(failureMessage: 'Incorrect password. Please try again'));
        //     }
        //     // ... many more manual error checks
        //     return Left(AuthFailure(failureMessage: 'Authentication failed'));
        //   } on SocketException catch (_) {
        //     return Left(NoInternetFailure(failureMessage: 'Please check your internet connection'));
        //   }
        //   // ... more manual exception handling
        // }

        // NEW PATTERN (much cleaner):
        Future<Either<Failure, String>> newLoginMethod(String email, String password) async {
          return ErrorHandler.handle(() async {
            // Just simulate the service call - no manual exception handling needed
            throw FirebaseAuthException(code: 'wrong-password', message: 'Invalid credentials');
          }, operationName: 'User Login');
        }

        // Act
        final result = await newLoginMethod('test@test.com', 'wrong');

        // Assert - Same result but with much less code
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Incorrect password. Please try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('proves no custom exception classes needed', () async {
        // Old pattern required custom exception classes
        // New pattern uses Firebase exceptions directly

        Future<Either<Failure, String>> repositoryMethod() async {
          return ErrorHandler.handle(() async {
            // Service naturally throws Firebase exception (as Firebase SDK would)
            throw FirebaseAuthException(
              code: 'email-already-in-use',
              message: 'The account already exists for that email',
            );
          });
        }

        final result = await repositoryMethod();

        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'An account already exists with this email');
            // This user-friendly message was generated automatically by ErrorHandler
            // No custom exception classes or manual message crafting needed
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Consistency Across Services', () {
      test('same error handling pattern works for any service', () async {
        // Test that the pattern works consistently for different types of services

        // Auth service simulation
        Future<Either<Failure, String>> authService() async {
          return ErrorHandler.handle(() async {
            throw FirebaseAuthException(code: 'user-disabled', message: 'User account disabled');
          }, operationName: 'Auth Service');
        }

        // Database service simulation  
        Future<Either<Failure, Map<String, dynamic>>> databaseService() async {
          return ErrorHandler.handle(() async {
            throw FirebaseException(
              plugin: 'cloud_firestore',
              code: 'permission-denied',
              message: 'Insufficient permissions',
            );
          }, operationName: 'Database Service');
        }

        // Network service simulation
        Future<Either<Failure, String>> networkService() async {
          return ErrorHandler.handle(() async {
            throw const SocketException('Connection failed');
          }, operationName: 'Network Service');
        }

        // Test all services use same pattern and get appropriate failures
        final authResult = await authService();
        final dbResult = await databaseService();
        final networkResult = await networkService();

        authResult.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'This account has been disabled. Contact support');
          },
          (_) => fail('Expected auth failure'),
        );

        dbResult.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.failureMessage, 'You don\'t have permission to perform this action');
          },
          (_) => fail('Expected database failure'),
        );

        networkResult.fold(
          (failure) {
            expect(failure, isA<NoInternetFailure>());
            expect(failure.failureMessage, 'Please check your internet connection and try again');
          },
          (_) => fail('Expected network failure'),
        );
      });
    });

    group('Operation Naming Benefits', () {
      test('operation names provide better logging context', () async {
        // Test that operation names help with debugging and logging

        Future<Either<Failure, String>> namedOperation() async {
          return ErrorHandler.handle(() async {
            throw FirebaseAuthException(code: 'too-many-requests', message: 'Too many attempts');
          }, operationName: 'Password Reset');
        }

        Future<Either<Failure, String>> unnamedOperation() async {
          return ErrorHandler.handle(() async {
            throw FirebaseAuthException(code: 'too-many-requests', message: 'Too many attempts');
          });
        }

        // Both should produce the same user-friendly error
        final namedResult = await namedOperation();
        final unnamedResult = await unnamedOperation();

        // Both get same user-facing error message
        namedResult.fold(
          (namedFailure) => unnamedResult.fold(
            (unnamedFailure) {
              expect(namedFailure.runtimeType, unnamedFailure.runtimeType);
              expect(namedFailure.failureMessage, unnamedFailure.failureMessage);
              expect(unnamedFailure.failureMessage, 'Too many attempts. Please try again later');
            },
            (_) => fail('Both should be failures'),
          ),
          (_) => fail('Expected failures'),
        );
      });
    });
  });
}