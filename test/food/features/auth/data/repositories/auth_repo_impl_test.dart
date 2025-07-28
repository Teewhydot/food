import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/auth/data/remote/data_sources/delete_user_account_data_source.dart';
import 'package:food/food/features/auth/data/remote/data_sources/email_verification_data_source.dart';
import 'package:food/food/features/auth/data/remote/data_sources/email_verification_status_data_source.dart';
import 'package:food/food/features/auth/data/remote/data_sources/login_data_source.dart';
import 'package:food/food/features/auth/data/remote/data_sources/password_reset_data_source.dart';
import 'package:food/food/features/auth/data/remote/data_sources/register_data_source.dart';
import 'package:food/food/features/auth/data/remote/data_sources/sign_out_data_source.dart';
import 'package:food/food/features/auth/data/remote/data_sources/user_data_source.dart';
import 'package:food/food/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repo_impl_test.mocks.dart';

@GenerateMocks([
  LoginDataSource,
  RegisterDataSource,
  EmailVerificationDataSource,
  EmailVerificationStatusDataSource,
  PasswordResetDataSource,
  SignOutDataSource,
  DeleteUserAccountDataSource,
  UserDataSource,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  UserCredential,
  User,
  FirebaseAuth,
])
void main() {
  late AuthRepoImpl authRepo;
  late MockLoginDataSource mockLoginDataSource;
  late MockRegisterDataSource mockRegisterDataSource;
  late MockEmailVerificationDataSource mockEmailVerificationDataSource;
  late MockEmailVerificationStatusDataSource mockEmailVerificationStatusDataSource;
  late MockPasswordResetDataSource mockPasswordResetDataSource;
  late MockSignOutDataSource mockSignOutDataSource;
  late MockDeleteUserAccountDataSource mockDeleteUserAccountDataSource;
  late MockUserDataSource mockUserDataSource;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    GetIt.instance.reset();
    
    mockLoginDataSource = MockLoginDataSource();
    mockRegisterDataSource = MockRegisterDataSource();
    mockEmailVerificationDataSource = MockEmailVerificationDataSource();
    mockEmailVerificationStatusDataSource = MockEmailVerificationStatusDataSource();
    mockPasswordResetDataSource = MockPasswordResetDataSource();
    mockSignOutDataSource = MockSignOutDataSource();
    mockDeleteUserAccountDataSource = MockDeleteUserAccountDataSource();
    mockUserDataSource = MockUserDataSource();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocument = MockDocumentReference<Map<String, dynamic>>();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockFirebaseAuth = MockFirebaseAuth();

    GetIt.instance.registerLazySingleton<LoginDataSource>(() => mockLoginDataSource);
    GetIt.instance.registerLazySingleton<RegisterDataSource>(() => mockRegisterDataSource);
    GetIt.instance.registerLazySingleton<EmailVerificationDataSource>(() => mockEmailVerificationDataSource);
    GetIt.instance.registerLazySingleton<EmailVerificationStatusDataSource>(() => mockEmailVerificationStatusDataSource);
    GetIt.instance.registerLazySingleton<PasswordResetDataSource>(() => mockPasswordResetDataSource);
    GetIt.instance.registerLazySingleton<SignOutDataSource>(() => mockSignOutDataSource);
    GetIt.instance.registerLazySingleton<DeleteUserAccountDataSource>(() => mockDeleteUserAccountDataSource);
    GetIt.instance.registerLazySingleton<UserDataSource>(() => mockUserDataSource);

    authRepo = AuthRepoImpl();
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  group('AuthRepoImpl', () {
    group('login', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testUserId = 'test-user-id';
      const testDisplayName = 'John Doe';

      test('should return UserProfileEntity when login is successful', () async {
        when(mockUser.uid).thenReturn(testUserId);
        when(mockUser.email).thenReturn(testEmail);
        when(mockUser.displayName).thenReturn(testDisplayName);
        when(mockUser.phoneNumber).thenReturn('+1234567890');
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockLoginDataSource.logUserInFirebase(testEmail, testPassword))
            .thenAnswer((_) async => mockUserCredential);

        final result = await authRepo.login(testEmail, testPassword);

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (userProfile) {
            expect(userProfile.email, testEmail);
            expect(userProfile.firstName, 'John');
            expect(userProfile.lastName, 'Doe');
            expect(userProfile.id, testUserId);
            expect(userProfile.firstTimeLogin, false);
          },
        );
        verify(mockLoginDataSource.logUserInFirebase(testEmail, testPassword)).called(1);
      });

      test('should return Failure when login throws exception', () async {
        when(mockLoginDataSource.logUserInFirebase(testEmail, testPassword))
            .thenThrow(FirebaseAuthException(code: 'user-not-found'));

        final result = await authRepo.login(testEmail, testPassword);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
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
      const testUserId = 'test-user-id';

      test('should return UserProfileEntity when registration is successful', () async {
        when(mockUser.uid).thenReturn(testUserId);
        when(mockUser.email).thenReturn(testEmail);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockRegisterDataSource.registerUser(testEmail, testPassword))
            .thenAnswer((_) async => mockUserCredential);

        final result = await authRepo.register(
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          password: testPassword,
        );

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (userProfile) {
            expect(userProfile.email, testEmail);
            expect(userProfile.firstName, testFirstName);
            expect(userProfile.lastName, testLastName);
            expect(userProfile.phoneNumber, testPhoneNumber);
            expect(userProfile.id, testUserId);
            expect(userProfile.firstTimeLogin, true);
          },
        );
        verify(mockRegisterDataSource.registerUser(testEmail, testPassword)).called(1);
      });

      test('should return Failure when registration throws exception', () async {
        when(mockRegisterDataSource.registerUser(testEmail, testPassword))
            .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

        final result = await authRepo.register(
          firstName: testFirstName,
          lastName: testLastName,
          email: testEmail,
          phoneNumber: testPhoneNumber,
          password: testPassword,
        );

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
          (userProfile) => fail('Should not return user profile'),
        );
      });
    });

    group('isAuthenticated', () {
      test('should return true when user is authenticated', () async {
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        final result = await authRepo.isAuthenticated();

        expect(result, true);
      });

      test('should return false when user is not authenticated', () async {
        final result = await authRepo.isAuthenticated();

        expect(result, false);
      });

      test('should return false when exception occurs', () async {
        final result = await authRepo.isAuthenticated();

        expect(result, false);
      });
    });

    group('forgotPassword', () {
      const testEmail = 'test@example.com';

      test('should return success message when password reset email is sent', () async {
        when(mockPasswordResetDataSource.sendPasswordResetEmail(testEmail))
            .thenAnswer((_) async {});

        final result = await authRepo.forgotPassword(testEmail);

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (message) => expect(message, 'Password reset email sent to $testEmail'),
        );
        verify(mockPasswordResetDataSource.sendPasswordResetEmail(testEmail)).called(1);
      });

      test('should return Failure when sending password reset email fails', () async {
        when(mockPasswordResetDataSource.sendPasswordResetEmail(testEmail))
            .thenThrow(FirebaseAuthException(code: 'user-not-found'));

        final result = await authRepo.forgotPassword(testEmail);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
          (message) => fail('Should not return success message'),
        );
      });
    });

    group('signOut', () {
      test('should return success when sign out is successful', () async {
        when(mockSignOutDataSource.signOut()).thenAnswer((_) async {});

        final result = await authRepo.signOut();

        expect(result.isRight(), true);
        verify(mockSignOutDataSource.signOut()).called(1);
      });

      test('should return Failure when sign out fails', () async {
        when(mockSignOutDataSource.signOut())
            .thenThrow(Exception('Sign out failed'));

        final result = await authRepo.signOut();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
          (_) => fail('Should not return success'),
        );
      });
    });

    group('deleteUserAccount', () {
      test('should return success when account deletion is successful', () async {
        when(mockDeleteUserAccountDataSource.deleteUserAccount())
            .thenAnswer((_) async {});

        final result = await authRepo.deleteUserAccount();

        expect(result.isRight(), true);
        verify(mockDeleteUserAccountDataSource.deleteUserAccount()).called(1);
      });

      test('should return Failure when account deletion fails', () async {
        when(mockDeleteUserAccountDataSource.deleteUserAccount())
            .thenThrow(Exception('Delete account failed'));

        final result = await authRepo.deleteUserAccount();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
          (_) => fail('Should not return success'),
        );
      });
    });

    group('sendEmailVerification', () {
      const testEmail = 'test@example.com';

      test('should return success when email verification is sent', () async {
        when(mockEmailVerificationDataSource.sendEmailVerification(testEmail))
            .thenAnswer((_) async {});

        final result = await authRepo.sendEmailVerification(testEmail);

        expect(result.isRight(), true);
        verify(mockEmailVerificationDataSource.sendEmailVerification(testEmail)).called(1);
      });

      test('should return Failure when sending email verification fails', () async {
        when(mockEmailVerificationDataSource.sendEmailVerification(testEmail))
            .thenThrow(Exception('Send verification failed'));

        final result = await authRepo.sendEmailVerification(testEmail);

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
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

        when(mockEmailVerificationStatusDataSource.checkEmailVerification())
            .thenAnswer((_) async => testUserProfile);

        final result = await authRepo.verifyEmail();

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (userProfile) => expect(userProfile, testUserProfile),
        );
        verify(mockEmailVerificationStatusDataSource.checkEmailVerification()).called(1);
      });

      test('should return Failure when email verification fails', () async {
        when(mockEmailVerificationStatusDataSource.checkEmailVerification())
            .thenThrow(Exception('Email verification failed'));

        final result = await authRepo.verifyEmail();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
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

        when(mockUserDataSource.getCurrentUser())
            .thenAnswer((_) async => testUserProfile);

        final result = await authRepo.getCurrentUser();

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not return failure'),
          (userProfile) => expect(userProfile, testUserProfile),
        );
        verify(mockUserDataSource.getCurrentUser()).called(1);
      });

      test('should return Failure when getting current user fails', () async {
        when(mockUserDataSource.getCurrentUser())
            .thenThrow(Exception('Get current user failed'));

        final result = await authRepo.getCurrentUser();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<Failure>()),
          (userProfile) => fail('Should not return user profile'),
        );
      });
    });
  });
}