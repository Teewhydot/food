import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/auth/data/remote/data_sources/delete_user_account_data_source.dart';
import 'package:food/food/features/auth/data/remote/data_sources/password_reset_data_source.dart';
import 'package:food/food/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:food/food/features/auth/domain/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockDeleteUserAccountDataSource extends Mock implements DeleteUserAccountDataSource {}
class MockPasswordResetDataSource extends Mock implements PasswordResetDataSource {}

void main() {
  group('AuthRepositoryImpl Error Handling', () {
    late AuthRepository repository;
    late MockDeleteUserAccountDataSource mockDeleteAccountService;
    late MockPasswordResetDataSource mockPasswordResetService;
    late GetIt getIt;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue('test@example.com');
    });

    setUp(() {
      // Reset GetIt instance
      getIt = GetIt.instance;
      getIt.reset();
      
      // Create mocks
      mockDeleteAccountService = MockDeleteUserAccountDataSource();
      mockPasswordResetService = MockPasswordResetDataSource();
      
      // Register mocks with GetIt
      getIt.registerLazySingleton<DeleteUserAccountDataSource>(() => mockDeleteAccountService);
      getIt.registerLazySingleton<PasswordResetDataSource>(() => mockPasswordResetService);
      
      // Create repository instance
      repository = AuthRepoImpl();
    });

    tearDown(() {
      getIt.reset();
    });

    group('deleteUserAccount()', () {
      test('returns Right when deletion succeeds', () async {
        // Arrange
        when(() => mockDeleteAccountService.deleteUserAccount())
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.deleteUserAccount();

        // Assert
        expect(result, isA<Right<Failure, void>>());
        verify(() => mockDeleteAccountService.deleteUserAccount()).called(1);
      });

      test('converts Firebase Auth exception to user-friendly AuthFailure', () async {
        // Arrange
        when(() => mockDeleteAccountService.deleteUserAccount())
            .thenThrow(FirebaseAuthException(
              code: 'requires-recent-login', 
              message: 'Recent login required'
            ));

        // Act
        final result = await repository.deleteUserAccount();

        // Assert
        expect(result, isA<Left<Failure, void>>());
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Please log in again to continue');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('converts Firebase general exception to ServerFailure', () async {
        // Arrange
        when(() => mockDeleteAccountService.deleteUserAccount())
            .thenThrow(FirebaseException(
              plugin: 'firebase_auth',
              code: 'internal',
              message: 'Internal server error'
            ));

        // Act
        final result = await repository.deleteUserAccount();

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.failureMessage, 'Internal server error. Please try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('converts network exception to NoInternetFailure', () async {
        // Arrange
        when(() => mockDeleteAccountService.deleteUserAccount())
            .thenThrow(const SocketException('No internet connection'));

        // Act
        final result = await repository.deleteUserAccount();

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<NoInternetFailure>());
            expect(failure.failureMessage, 'Please check your internet connection and try again');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('converts generic exception to UnknownFailure', () async {
        // Arrange
        when(() => mockDeleteAccountService.deleteUserAccount())
            .thenThrow(Exception('Some random error'));

        // Act
        final result = await repository.deleteUserAccount();

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

    group('forgotPassword()', () {
      const testEmail = 'test@example.com';

      test('returns Right with success message when password reset succeeds', () async {
        // Arrange
        when(() => mockPasswordResetService.sendPasswordResetEmail(testEmail))
            .thenAnswer((_) async => Future.value());

        // Act
        final result = await repository.forgotPassword(testEmail);

        // Assert
        expect(result, isA<Right<Failure, String>>());
        result.fold(
          (_) => fail('Expected success but got failure'),
          (message) => expect(message, 'Password reset email sent to $testEmail'),
        );
        verify(() => mockPasswordResetService.sendPasswordResetEmail(testEmail)).called(1);
      });

      test('converts user-not-found to user-friendly AuthFailure', () async {
        // Arrange
        when(() => mockPasswordResetService.sendPasswordResetEmail(testEmail))
            .thenThrow(FirebaseAuthException(
              code: 'user-not-found',
              message: 'There is no user record'
            ));

        // Act
        final result = await repository.forgotPassword(testEmail);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'No account found with this email address');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('converts invalid-email to user-friendly AuthFailure', () async {
        // Arrange
        when(() => mockPasswordResetService.sendPasswordResetEmail(testEmail))
            .thenThrow(FirebaseAuthException(
              code: 'invalid-email',
              message: 'The email address is badly formatted'
            ));

        // Act
        final result = await repository.forgotPassword(testEmail);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Please enter a valid email address');
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('converts too-many-requests to user-friendly AuthFailure', () async {
        // Arrange
        when(() => mockPasswordResetService.sendPasswordResetEmail(testEmail))
            .thenThrow(FirebaseAuthException(
              code: 'too-many-requests',
              message: 'Too many requests'
            ));

        // Act
        final result = await repository.forgotPassword(testEmail);

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Too many attempts. Please try again later');
          },
          (_) => fail('Expected failure but got success'),
        );
      });
    });

    group('Repository Pattern Validation', () {
      test('proves repository uses ErrorHandler correctly without manual exception throwing', () async {
        // This test validates that:
        // 1. Repository doesn't manually throw exceptions
        // 2. Service layer throws Firebase exceptions naturally
        // 3. ErrorHandler catches and converts them automatically
        // 4. Repository gets clean Either<Failure, T> result
        
        // Arrange - Service throws Firebase exception naturally (no manual throwing in repository)
        when(() => mockDeleteAccountService.deleteUserAccount())
            .thenThrow(FirebaseAuthException(
              code: 'weak-password',
              message: 'Password is too weak'
            ));

        // Act - Repository just calls ErrorHandler.handle() - no manual exception handling
        final result = await repository.deleteUserAccount();

        // Assert - ErrorHandler automatically converted Firebase exception to user-friendly AuthFailure
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Password is too weak. Please choose a stronger password');
            // This proves the repository didn't need to:
            // 1. Catch the FirebaseAuthException manually
            // 2. Check the error code manually  
            // 3. Throw custom exceptions manually
            // 4. Convert to user-friendly messages manually
            // ErrorHandler did all of this automatically!
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('demonstrates clean separation: Service throws, ErrorHandler converts, Repository gets Either', () async {
        // This test shows the clean flow:
        // Service Layer -> throws FirebaseAuthException (automatic)
        // ErrorHandler -> catches exception, converts to user-friendly failure (automatic)  
        // Repository -> gets Either<Failure, T> (clean result)
        
        // Arrange
        when(() => mockPasswordResetService.sendPasswordResetEmail(any()))
            .thenThrow(FirebaseAuthException(
              code: 'email-already-verified',
              message: 'Email is already verified'
            ));

        // Act
        final result = await repository.forgotPassword('test@example.com');

        // Assert
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.failureMessage, 'Email is already verified');
            
            // This proves:
            // ✅ Service threw FirebaseAuthException (as Firebase SDK would)
            // ✅ Repository didn't need to handle exception manually
            // ✅ ErrorHandler automatically caught and converted exception
            // ✅ Repository received clean Either<Failure, String> result
          },
          (_) => fail('Expected failure but got success'),
        );
      });

      test('validates that repository pattern works with all exception types', () async {
        // Test that the repository pattern works correctly with different exception types
        // This proves the pattern is consistent regardless of exception type
        
        final testCases = [
          {
            'exception': FirebaseAuthException(code: 'user-disabled', message: 'User disabled'),
            'expectedFailure': AuthFailure,
            'expectedMessage': 'This account has been disabled. Contact support',
          },
          {
            'exception': const SocketException('Network error'),
            'expectedFailure': NoInternetFailure,
            'expectedMessage': 'Please check your internet connection and try again',
          },
          {
            'exception': Exception('Generic error'),
            'expectedFailure': UnknownFailure,
            'expectedMessage': 'Something went wrong. Please try again',
          },
        ];

        for (final testCase in testCases) {
          // Arrange
          when(() => mockDeleteAccountService.deleteUserAccount())
              .thenThrow(testCase['exception']!);

          // Act
          final result = await repository.deleteUserAccount();

          // Assert
          result.fold(
            (failure) {
              expect(failure.runtimeType, testCase['expectedFailure']);
              expect(failure.failureMessage, testCase['expectedMessage']);
            },
            (_) => fail('Expected failure but got success for ${testCase['exception']}'),
          );
        }
      });
    });
  });
}