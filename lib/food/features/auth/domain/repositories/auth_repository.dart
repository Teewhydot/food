import 'package:dartz/dartz.dart';
import 'package:food/food/domain/failures/failures.dart';

import '../../../home/domain/entities/profile.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendEmailVerification(String email);
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, UserProfileEntity>> verifyEmail();

  /// Signs out the user.
  Future<Either<Failure, void>> signOut();

  /// Checks if the user is authenticated.
  Future<Either<Failure, UserProfileEntity>> isAuthenticated();

  /// Login
  Future<Either<Failure, UserProfileEntity>> login(
    String email,
    String password,
  );

  /// Registers a new user with the provided details.
  Future<Either<Failure, UserProfileEntity>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  /// Forgot password
  Future<Either<Failure, String>> forgotPassword(String email);

  /// Delete user account
  Future<Either<Failure, void>> deleteUserAccount(String email, String token);

  Future<Either<Failure, UserProfileEntity>> getCurrentUser();

  /// Update user password
  Future<Either<Failure, void>> updatePassword(
    String email,
    String currentPassword,
    String newPassword,
  );
}
