import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../domain/failures/failures.dart';
import '../entities/profile.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfileEntity>> getUserProfile(String userId);
  Future<Either<Failure, UserProfileEntity>> updateUserProfile(UserProfileEntity profile);
  Future<Either<Failure, String>> uploadProfileImage(String userId, File imageFile);
  Future<Either<Failure, void>> deleteProfileImage(String userId);
  Future<Either<Failure, UserProfileEntity>> updateProfileField(String userId, String field, dynamic value);
  Stream<Either<Failure, UserProfileEntity>> watchUserProfile(String userId);
  Future<Either<Failure, void>> syncLocalProfile(UserProfileEntity profile);
}