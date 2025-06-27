import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';
import 'package:food/food/features/auth/domain/entities/user_profile.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendEmailVerification(String email);
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, UserProfile>> verifyEmail();

  /// Signs out the user.
  Future<Either<Failure, void>> signOut();

  /// Checks if the user is authenticated.
  Future<bool> isAuthenticated();

  /// Login
  Future<Either<Failure, UserProfile>> login(String email, String password);

  /// Registers a new user with the provided details.
  Future<Either<Failure, UserProfile>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  /// Forgot password
  Future<Either<Failure, String>> forgotPassword(String email);

  /// Delete user account
  Future<Either<Failure, void>> deleteUserAccount();
}
