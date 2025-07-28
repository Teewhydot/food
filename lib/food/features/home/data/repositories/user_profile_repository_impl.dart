import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/services/floor_db_service/user_profile/user_profile_database_service.dart';
import '../../../../core/utils/handle_exceptions.dart';
import '../../../../domain/failures/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../remote/data_sources/user_profile_remote_data_source.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  final UserProfileDatabaseService localDataSource;

  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile(String userId) {
    return handleExceptions(() async {
      try {
        // Try to get from remote first
        final remoteProfile = await remoteDataSource.getUserProfile(userId);
        
        // Save to local database
        await localDataSource.insertUserProfile(remoteProfile);
        
        return remoteProfile;
      } catch (e) {
        // If remote fails, get from local
        final localProfile = await localDataSource.getUserProfile();
        if (localProfile == null) {
          throw Exception('User profile not found');
        }
        return localProfile;
      }
    });
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateUserProfile(UserProfileEntity profile) {
    return handleExceptions(() async {
      // Update remote first
      final updatedProfile = await remoteDataSource.updateUserProfile(profile);
      
      // Then update local
      await localDataSource.updateUserProfile(updatedProfile);
      
      return updatedProfile;
    });
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage(String userId, File imageFile) {
    return handleExceptions(() async {
      // Upload to remote storage
      final imageUrl = await remoteDataSource.uploadProfileImage(userId, imageFile);
      
      // Update local profile with new image URL
      final currentProfile = await localDataSource.getUserProfile();
      if (currentProfile != null) {
        final updatedProfile = UserProfileEntity(
          id: currentProfile.id,
          firstName: currentProfile.firstName,
          lastName: currentProfile.lastName,
          email: currentProfile.email,
          phoneNumber: currentProfile.phoneNumber,
          profileImageUrl: imageUrl,
          firstTimeLogin: currentProfile.firstTimeLogin,
        );
        await localDataSource.updateUserProfile(updatedProfile);
      }
      
      return imageUrl;
    });
  }

  @override
  Future<Either<Failure, void>> deleteProfileImage(String userId) {
    return handleExceptions(() async {
      // Delete from remote storage
      await remoteDataSource.deleteProfileImage(userId);
      
      // Update local profile to remove image URL
      final currentProfile = await localDataSource.getUserProfile();
      if (currentProfile != null) {
        final updatedProfile = UserProfileEntity(
          id: currentProfile.id,
          firstName: currentProfile.firstName,
          lastName: currentProfile.lastName,
          email: currentProfile.email,
          phoneNumber: currentProfile.phoneNumber,
          profileImageUrl: null,
          firstTimeLogin: currentProfile.firstTimeLogin,
        );
        await localDataSource.updateUserProfile(updatedProfile);
      }
    });
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateProfileField(
    String userId,
    String field,
    dynamic value,
  ) {
    return handleExceptions(() async {
      // Update remote first
      final updatedProfile = await remoteDataSource.updateProfileField(userId, field, value);
      
      // Then update local
      await localDataSource.updateUserProfile(updatedProfile);
      
      return updatedProfile;
    });
  }

  @override
  Stream<Either<Failure, UserProfileEntity>> watchUserProfile(String userId) {
    try {
      return remoteDataSource.watchUserProfile(userId).map<Either<Failure, UserProfileEntity>>((profile) {
        // Update local database with the latest data
        localDataSource.insertUserProfile(profile);
        return Right(profile);
      }).handleError((error) {
        return Stream.value(Left<Failure, UserProfileEntity>(ServerFailure(failureMessage: error.toString())));
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure(failureMessage: e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> syncLocalProfile(UserProfileEntity profile) {
    return handleExceptions(() async {
      // Sync local changes to remote
      await remoteDataSource.syncLocalProfile(profile);
      
      // Update local profile with any server changes
      final remoteProfile = await remoteDataSource.getUserProfile(profile.id!);
      await localDataSource.updateUserProfile(remoteProfile);
    });
  }
}