import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';

import '../../../../domain/failures/failures.dart';
import '../entities/profile.dart';
import '../repositories/user_profile_repository.dart';

class UserProfileUseCase {
  final UserProfileRepository repository;

  UserProfileUseCase(this.repository);

  Future<Either<Failure, UserProfileEntity>> getUserProfile(String userId) {
    if (userId.isEmpty) {
      return Future.value(
        Left(UnknownFailure(failureMessage: 'User ID cannot be empty')),
      );
    }
    return repository.getUserProfile(userId);
  }

  Future<Either<Failure, UserProfileEntity>> updateUserProfile(
    UserProfileEntity profile,
  ) {
    if (!_validateProfile(profile)) {
      return Future.value(
        Left(UnknownFailure(failureMessage: 'Invalid profile data')),
      );
    }
    return repository.updateUserProfile(profile);
  }

  Future<Either<Failure, String>> uploadProfileImage(
    String userId,
    File imageFile,
  ) {
    if (userId.isEmpty) {
      return Future.value(
        Left(UnknownFailure(failureMessage: 'User ID cannot be empty')),
      );
    }

    if (!imageFile.existsSync()) {
      return Future.value(
        Left(UnknownFailure(failureMessage: 'Image file does not exist')),
      );
    }

    // Check file size (limit to 5MB)
    final fileSizeInBytes = imageFile.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    if (fileSizeInMB > 5) {
      return Future.value(
        Left(
          UnknownFailure(
            failureMessage: 'Image file too large. Maximum size is 5MB',
          ),
        ),
      );
    }

    return repository.uploadProfileImage(userId, imageFile);
  }

  Future<Either<Failure, void>> deleteProfileImage(String userId) {
    if (userId.isEmpty) {
      return Future.value(
        Left(UnknownFailure(failureMessage: 'User ID cannot be empty')),
      );
    }
    return repository.deleteProfileImage(userId);
  }

  Future<Either<Failure, UserProfileEntity>> updateFirstName(
    String userId,
    String firstName,
  ) {
    if (firstName.trim().isEmpty) {
      return Future.value(
        Left(UnknownFailure(failureMessage: 'First name cannot be empty')),
      );
    }
    return repository.updateProfileField(userId, 'firstName', firstName.trim());
  }

  Future<Either<Failure, UserProfileEntity>> updateLastName(
    String userId,
    String lastName,
  ) {
    if (lastName.trim().isEmpty) {
      return Future.value(
        Left(UnknownFailure(failureMessage: 'Last name cannot be empty')),
      );
    }
    return repository.updateProfileField(userId, 'lastName', lastName.trim());
  }

  Future<Either<Failure, UserProfileEntity>> updateEmail(
    String userId,
    String email,
  ) {
    if (!_isValidEmail(email)) {
      return Future.value(
        Left(UnknownFailure(failureMessage: 'Invalid email format')),
      );
    }
    return repository.updateProfileField(
      userId,
      'email',
      email.trim().toLowerCase(),
    );
  }

  Future<Either<Failure, UserProfileEntity>> updatePhoneNumber(
    String userId,
    String phoneNumber,
  ) {
    if (!_isValidPhoneNumber(phoneNumber)) {
      return Future.value(
        Left(UnknownFailure(failureMessage: 'Invalid phone number format')),
      );
    }
    return repository.updateProfileField(
      userId,
      'phoneNumber',
      phoneNumber.trim(),
    );
  }

  Stream<Either<Failure, UserProfileEntity>> watchUserProfile(String userId) {
    return repository.watchUserProfile(userId);
  }

  bool _validateProfile(UserProfileEntity profile) {
    return profile.firstName.trim().isNotEmpty &&
        profile.lastName.trim().isNotEmpty &&
        _isValidEmail(profile.email) &&
        _isValidPhoneNumber(profile.phoneNumber);
  }

  bool _isValidEmail(String email) {
    return GetUtils.isEmail(email);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    // Basic validation: check if it contains only digits and has a reasonable length
    final cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return cleaned.length >= 7 && cleaned.length <= 15;
  }

  Future<Either<Failure, UserProfileEntity>> updateProfileWithValidation({
    required String userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
  }) async {
    // Get current profile
    final currentProfileResult = await repository.getUserProfile(userId);

    return currentProfileResult.fold((failure) => Left(failure), (
      currentProfile,
    ) {
      // Create updated profile with new values
      final updatedProfile = UserProfileEntity(
        id: currentProfile.id,
        firstName: firstName?.trim() ?? currentProfile.firstName,
        lastName: lastName?.trim() ?? currentProfile.lastName,
        email: email?.trim().toLowerCase() ?? currentProfile.email,
        phoneNumber: phoneNumber?.trim() ?? currentProfile.phoneNumber,
        profileImageUrl: currentProfile.profileImageUrl,
        firstTimeLogin: currentProfile.firstTimeLogin,
      );

      return updateUserProfile(updatedProfile);
    });
  }
}
