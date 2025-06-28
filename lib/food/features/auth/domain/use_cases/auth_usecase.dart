import 'package:dartz/dartz.dart';
import 'package:food/food/features/auth/domain/entities/user_profile.dart';

import '../../../../domain/failures/failures.dart';
import '../../data/repositories/auth_repo_impl.dart';

class AuthUseCase {
  final authRepo = AuthRepoImpl();

  Future<Either<Failure, UserProfile>> login(String email, String password) {
    return authRepo.login(email, password);
  }

  Future<Either<Failure, UserProfile>> register({
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

  Future<Either<Failure, void>> deleteUserAccount() {
    return authRepo.deleteUserAccount();
  }

  Future<Either<Failure, UserProfile>> verifyEmail() {
    return authRepo.verifyEmail();
  }
}
