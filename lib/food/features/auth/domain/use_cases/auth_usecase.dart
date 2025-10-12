import 'package:dartz/dartz.dart';

import '../../../../domain/failures/failures.dart';
import '../../../home/domain/entities/profile.dart';
import '../../data/repositories/auth_repo_impl.dart';

class AuthUseCase {
  final authRepo = AuthRepoImpl();

  Future<Either<Failure, UserProfileEntity>> getCurrentUser() {
    return authRepo.getCurrentUser();
  }

  Future<Either<Failure, UserProfileEntity>> login(
    String email,
    String password,
  ) {
    return authRepo.login(email, password);
  }

  Future<Either<Failure, UserProfileEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) {
    return authRepo.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );
  }

  Future<Either<Failure, void>> sendEmailVerification(String email) {
    return authRepo.sendEmailVerification(email);
  }

  Future<Either<Failure, void>> sendPasswordResetEmail(String email) {
    return authRepo.sendPasswordResetEmail(email);
  }

  Future<Either<Failure, void>> signOut() {
    return authRepo.signOut();
  }

  Future<Either<Failure, void>> deleteUserAccount(String email, token) {
    return authRepo.deleteUserAccount(email, token);
  }

  Future<Either<Failure, UserProfileEntity>> verifyEmail() {
    return authRepo.verifyEmail();
  }

  Future<Either<Failure, void>> updatePassword(
    String email,
    String currentPassword,
    String newPassword,
  ) {
    return authRepo.updatePassword(email, currentPassword, newPassword);
  }
}
