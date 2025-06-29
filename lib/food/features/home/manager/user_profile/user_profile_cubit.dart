import 'package:bloc/bloc.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:food/food/core/services/floor_db_service/user_profile/user_profile_database_service.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:food/food/features/auth/domain/use_cases/auth_usecase.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:meta/meta.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit() : super(UserProfileInitial());
  final db = UserProfileDatabaseService();
  final authUseCase = AuthUseCase();

  void saveUserProfile(UserProfileEntity userProfile) async {
    emit(UserProfileLoading());
    try {
      Logger.logSuccess(
        "Saving details: ${userProfile.firstName} ${userProfile.lastName} ${userProfile.email} ${userProfile.phoneNumber} ${userProfile.bio} ${userProfile.firstTimeLogin}",
      );
      await (await db.database).userProfileDao.saveUserProfile(userProfile);
      // emit(UserProfileLoaded(userProfile: userProfile));
      loadUserProfile();
    } catch (e) {
      emit(UserProfileError(errorMessage: e.toString()));
    }
  }

  void updateUserProfile(UserProfileEntity userProfile) async {
    emit(UserProfileLoading());
    try {
      Logger.logSuccess(
        "Updated details: ${userProfile.firstName} ${userProfile.lastName} ${userProfile.email} ${userProfile.phoneNumber} ${userProfile.bio}",
      );
      await (await db.database).userProfileDao.updateUserProfile(userProfile);
      // emit(UserProfileLoaded(userProfile: userProfile));
      loadUserProfile();
    } catch (e) {
      emit(UserProfileError(errorMessage: e.toString()));
    }
  }

  void clearUserProfile() async {
    emit(UserProfileLoading());
    try {
      await (await db.database).userProfileDao.deleteUserProfile();
    } catch (e) {
      emit(UserProfileError(errorMessage: e.toString()));
    }
  }

  void loadUserProfile() async {
    emit(UserProfileLoading());
    try {
      // If not in database, fetch from remote using AuthUseCase
      final result = await authUseCase.getCurrentUser();
      result.fold(
        (failure) {
          Logger.logError("Failed to get user: ${failure.failureMessage}");
        },
        (userProfile) async {
          // Success - save to database and emit loaded state
          Logger.logSuccess(
            "User fetched from server: ${userProfile.firstName} ${userProfile.lastName}",
          );
          await (await db.database).userProfileDao.saveUserProfile(userProfile);
          emit(UserProfileLoaded(userProfile: userProfile));
        },
      );
    } catch (e) {
      emit(UserProfileError(errorMessage: e.toString()));
      Logger.logError("Error loading user profile: ${e.toString()}");
    }
  }
}
