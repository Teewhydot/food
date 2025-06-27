import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/auth/domain/entities/user_profile.dart';
import 'package:food/food/features/auth/domain/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/utils/handle_exceptions.dart';
import '../remote/data_sources/email_verification_data_source.dart';
import '../remote/data_sources/login_data_source.dart';
import '../remote/data_sources/register_data_source.dart';

class AuthRepoImpl implements AuthRepository {
  final firebase = FirebaseFirestore.instance;
  final loginService = GetIt.instance<LoginDataSource>();
  final registerService = GetIt.instance<RegisterDataSource>();
  final emailVerificationService =
      GetIt.instance<EmailVerificationDataSource>();
  @override
  Future<Either<Failure, void>> deleteUserAccount() {
    // TODO: implement deleteUserAccount
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) {
    // TODO: implement forgotPassword
    throw UnimplementedError();
  }

  @override
  Future<bool> isAuthenticated() {
    // TODO: implement isAuthenticated
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserProfile>> login(String email, String password) {
    return handleExceptions(() async {
      final user = await loginService.logUserInFirebase(email, password);
      return UserProfile(
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
  Future<Either<Failure, UserProfile>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) {
    return handleExceptions(() async {
      final user = await registerService.registerUser(email, password);
      if (user.user != null) {
        await firebase.collection('users').doc(user.user!.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return UserProfile(
        email: user.user?.email ?? '',
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        id: user.user?.uid ?? '',
        firstTimeLogin: true,
      );
    });
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification(String email) {
    return handleExceptions(() async {
      await emailVerificationService.sendEmailVerification(email);
    });
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) {
    // TODO: implement sendPasswordResetEmail
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserProfile>> verifyEmail() {
    // TODO: implement verifyEmail
    throw UnimplementedError();
  }
}
