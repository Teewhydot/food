import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:food/food/features/auth/domain/use_cases/auth_usecase.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_usecase_test.mocks.dart';

@GenerateMocks([AuthRepoImpl])
void main() {
  late AuthUseCase authUseCase;
  late MockAuthRepoImpl mockAuthRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepoImpl();
    authUseCase = AuthUseCase();
  });

  group('AuthUseCase', () {
    group('login', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      test('should return UserProfileEntity when login is successful', () async {
        final testUserProfile = UserProfileEntity(
          id: 'test-id',
          email: testEmail,
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '+1234567890',
          firstTimeLogin: false,
        );

        when(mockAuthRepo.login(testEmail, testPassword))
            .thenAnswer((_) async => Right(testUserProfile));

        final result = await mockAuthRepo.login(testEmail, testPassword);

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (userProfile) => expect(userProfile, testUserProfile),
        );
        verify(mockAuthRepo.login(testEmail, testPassword)).called(1);
      });

      test('should return Failure when login fails', () async {
        final testFailure = ServerFailure(failureMessage: 'Login failed');

        when(mockAuthRepo.login(testEmail, testPassword))
            .thenAnswer((_) async => Left(testFailure));

        final result = await mockAuthRepo.login(testEmail, testPassword);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, testFailure),
          (userProfile) => fail('Should not return user profile'),
        );
      });
    });

    group('register', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testFirstName = 'John';
      const testLastName = 'Doe';
      const testPhoneNumber = '+1234567890';

      test('should return UserProfileEntity when registration is successful', () async {
        final testUserProfile = UserProfileEntity(
          id: 'test-id',
          email: testEmail,
          firstName: testFirstName,
          lastName: testLastName,
          phoneNumber: testPhoneNumber,
          firstTimeLogin: true,
        );

        when(mockAuthRepo.register(
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          password: testPassword,
        )).thenAnswer((_) async => Right(testUserProfile));

        final result = await mockAuthRepo.register(
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          password: testPassword,
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (userProfile) => expect(userProfile, testUserProfile),
        );
        verify(mockAuthRepo.register(
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          password: testPassword,
        )).called(1);
      });

      test('should return Failure when registration fails', () async {
        final testFailure = ServerFailure(failureMessage: 'Registration failed');

        when(mockAuthRepo.register(
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          password: testPassword,
        )).thenAnswer((_) async => Left(testFailure));

        final result = await mockAuthRepo.register(
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          password: testPassword,
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, testFailure),
          (userProfile) => fail('Should not return user profile'),
        );
      });
    });

    group('sendEmailVerification', () {
      const testEmail = 'test@example.com';

      test('should return success when email verification is sent', () async {
        when(mockAuthRepo.sendEmailVerification(testEmail))
            .thenAnswer((_) async => const Right(null));

        final result = await mockAuthRepo.sendEmailVerification(testEmail);

        expect(result.isRight(), true);
        verify(mockAuthRepo.sendEmailVerification(testEmail)).called(1);
      });

      test('should return Failure when sending email verification fails', () async {
        final testFailure = ServerFailure(failureMessage: 'Send verification failed');

        when(mockAuthRepo.sendEmailVerification(testEmail))
            .thenAnswer((_) async => Left(testFailure));

        final result = await mockAuthRepo.sendEmailVerification(testEmail);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, testFailure),
          (_) => fail('Should not return success'),
        );
      });
    });

    group('sendPasswordResetEmail', () {
      const testEmail = 'test@example.com';

      test('should return success when password reset email is sent', () async {
        when(mockAuthRepo.sendPasswordResetEmail(testEmail))
            .thenAnswer((_) async => const Right(null));

        final result = await mockAuthRepo.sendPasswordResetEmail(testEmail);

        expect(result.isRight(), true);
        verify(mockAuthRepo.sendPasswordResetEmail(testEmail)).called(1);
      });

      test('should return Failure when sending password reset email fails', () async {
        final testFailure = ServerFailure(failureMessage: 'Send password reset failed');

        when(mockAuthRepo.sendPasswordResetEmail(testEmail))
            .thenAnswer((_) async => Left(testFailure));

        final result = await mockAuthRepo.sendPasswordResetEmail(testEmail);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, testFailure),
          (_) => fail('Should not return success'),
        );
      });
    });

    group('signOut', () {
      test('should return success when sign out is successful', () async {
        when(mockAuthRepo.signOut())
            .thenAnswer((_) async => const Right(null));

        final result = await mockAuthRepo.signOut();

        expect(result.isRight(), true);
        verify(mockAuthRepo.signOut()).called(1);
      });

      test('should return Failure when sign out fails', () async {
        final testFailure = ServerFailure(failureMessage: 'Sign out failed');

        when(mockAuthRepo.signOut())
            .thenAnswer((_) async => Left(testFailure));

        final result = await mockAuthRepo.signOut();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, testFailure),
          (_) => fail('Should not return success'),
        );
      });
    });

    group('deleteUserAccount', () {
      test('should return success when account deletion is successful', () async {
        when(mockAuthRepo.deleteUserAccount())
            .thenAnswer((_) async => const Right(null));

        final result = await mockAuthRepo.deleteUserAccount();

        expect(result.isRight(), true);
        verify(mockAuthRepo.deleteUserAccount()).called(1);
      });

      test('should return Failure when account deletion fails', () async {
        final testFailure = ServerFailure(failureMessage: 'Delete account failed');

        when(mockAuthRepo.deleteUserAccount())
            .thenAnswer((_) async => Left(testFailure));

        final result = await mockAuthRepo.deleteUserAccount();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, testFailure),
          (_) => fail('Should not return success'),
        );
      });
    });

    group('verifyEmail', () {
      test('should return UserProfileEntity when email verification is successful', () async {
        final testUserProfile = UserProfileEntity(
          id: 'test-id',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '+1234567890',
          firstTimeLogin: false,
        );

        when(mockAuthRepo.verifyEmail())
            .thenAnswer((_) async => Right(testUserProfile));

        final result = await mockAuthRepo.verifyEmail();

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (userProfile) => expect(userProfile, testUserProfile),
        );
        verify(mockAuthRepo.verifyEmail()).called(1);
      });

      test('should return Failure when email verification fails', () async {
        final testFailure = ServerFailure(failureMessage: 'Email verification failed');

        when(mockAuthRepo.verifyEmail())
            .thenAnswer((_) async => Left(testFailure));

        final result = await mockAuthRepo.verifyEmail();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, testFailure),
          (userProfile) => fail('Should not return user profile'),
        );
      });
    });

    group('getCurrentUser', () {
      test('should return UserProfileEntity when getting current user is successful', () async {
        final testUserProfile = UserProfileEntity(
          id: 'test-id',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '+1234567890',
          firstTimeLogin: false,
        );

        when(mockAuthRepo.getCurrentUser())
            .thenAnswer((_) async => Right(testUserProfile));

        final result = await mockAuthRepo.getCurrentUser();

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (userProfile) => expect(userProfile, testUserProfile),
        );
        verify(mockAuthRepo.getCurrentUser()).called(1);
      });

      test('should return Failure when getting current user fails', () async {
        final testFailure = ServerFailure(failureMessage: 'Get current user failed');

        when(mockAuthRepo.getCurrentUser())
            .thenAnswer((_) async => Left(testFailure));

        final result = await mockAuthRepo.getCurrentUser();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, testFailure),
          (userProfile) => fail('Should not return user profile'),
        );
      });
    });
  });
}