import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/auth/domain/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../home/domain/entities/profile.dart';
import '../remote/data_sources/delete_user_account_data_source.dart';
import '../remote/data_sources/email_verification_data_source.dart';
import '../remote/data_sources/email_verification_status_data_source.dart';
import '../remote/data_sources/login_data_source.dart';
import '../remote/data_sources/password_reset_data_source.dart';
import '../remote/data_sources/register_data_source.dart';
import '../remote/data_sources/sign_out_data_source.dart';
import '../remote/data_sources/update_password_data_source.dart';
import '../remote/data_sources/user_data_source.dart';

class AuthRepoImpl implements AuthRepository {
  final firebase = FirebaseFirestore.instance;
  final loginService = GetIt.instance<LoginDataSource>();
  final registerService = GetIt.instance<RegisterDataSource>();
  final emailVerificationService =
      GetIt.instance<EmailVerificationDataSource>();
  final emailVerificationStatusService =
      GetIt.instance<EmailVerificationStatusDataSource>();
  final passwordResetService = GetIt.instance<PasswordResetDataSource>();
  final signOutService = GetIt.instance<SignOutDataSource>();
  final deleteAccountService = GetIt.instance<DeleteUserAccountDataSource>();
  final updatePasswordService = GetIt.instance<UpdatePasswordDataSource>();
  final userProfileService = GetIt.instance<UserDataSource>();
  final authStatusService = GetIt.instance<UserDataSource>();
  @override
  Future<Either<Failure, void>> deleteUserAccount() {
    return ErrorHandler.handle(
      () async => await deleteAccountService.deleteUserAccount(),
      operationName: 'Delete User Account',
    );
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) {
    return ErrorHandler.handle(
      () async {
        await passwordResetService.sendPasswordResetEmail(email);
        return 'Password reset email sent to $email';
      },
      operationName: 'Forgot Password',
    );
  }

  @override
  Future<Either<Failure, UserProfileEntity>> isAuthenticated() async {
   return ErrorHandler.handle(() async {
    final authStatus = await authStatusService.getCurrentUser();
    return authStatus;
   });
  }

  @override
  Future<Either<Failure, UserProfileEntity>> login(
    String email,
    String password,
  ) {
    return ErrorHandler.handle(() async {
      final user = await loginService.logUserInFirebase(email, password);
      return UserProfileEntity(
        email: user.user?.email ?? '',
        firstName: user.user?.displayName?.split(' ').first ?? '',
        lastName: user.user?.displayName?.split(' ').last ?? '',
        phoneNumber: user.user?.phoneNumber ?? '',
        id: user.user?.uid ?? '',
        firstTimeLogin: false,
      );
    });
  }

  @override
  Future<Either<Failure, UserProfileEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) {
    return ErrorHandler.handle(() async {
      final user = await registerService.registerUser(email, password);
      if (user.user != null) {
        await firebase.collection('users').doc(user.user!.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'profileImageUrl': "",
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return UserProfileEntity(
        email: user.user?.email ?? '',
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        id: user.user?.uid ?? '',
        profileImageUrl: null,
        firstTimeLogin: true,
      );
    });
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification(String email) {
    return ErrorHandler.handle(() async {
      await emailVerificationService.sendEmailVerification(email);
    });
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) {
    return ErrorHandler.handle(() async {
      await passwordResetService.sendPasswordResetEmail(email);
    });
  }

  @override
  Future<Either<Failure, void>> signOut() {
    return ErrorHandler.handle(() async {
      await signOutService.signOut();
    });
  }

  @override
  Future<Either<Failure, UserProfileEntity>> verifyEmail() {
    return ErrorHandler.handle(() async {
      final userProfile =
          await emailVerificationStatusService.checkEmailVerification();
      return userProfile;
    });
  }

  @override
  Future<Either<Failure, UserProfileEntity>> getCurrentUser() {
    return ErrorHandler.handle(() async {
      final userProfile = await userProfileService.getCurrentUser();
      return userProfile;
    });
  }

  @override
  Future<Either<Failure, void>> updatePassword(
    String currentPassword,
    String newPassword,
  ) {
    return ErrorHandler.handle(
      () async => await updatePasswordService.updatePassword(
        currentPassword,
        newPassword,
      ),
      operationName: 'Update Password',
    );
  }
}
