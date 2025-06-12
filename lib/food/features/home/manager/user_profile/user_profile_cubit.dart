import 'package:bloc/bloc.dart';
import 'package:food/food/core/services/floor_db_service/user_profile/user_profile_database_service.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:meta/meta.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit() : super(UserProfileInitial());
  final db = UserProfileDatabaseService();
  void saveUserProfile(UserProfileEntity userProfile) async {
    emit(UserProfileLoading());
    try {
      Logger.logSuccess(
        "Saving details: ${userProfile.firstName} ${userProfile.lastName} ${userProfile.email} ${userProfile.phoneNumber} ${userProfile.bio}",
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
      emit(
        UserProfileLoaded(
          userProfile: UserProfileEntity(
            firstName: "Guest",
            lastName: "",
            email: "",
            phoneNumber: "",
          ),
        ),
      );
    } catch (e) {
      emit(UserProfileError(errorMessage: e.toString()));
    }
  }

  void loadUserProfile() async {
    emit(UserProfileLoading());
    try {
      final user = await (await db.database).userProfileDao.getUserProfile();
      emit(UserProfileLoaded(userProfile: user.first));
      Logger.logSuccess(
        "User profile loaded successfully: ${user.first.firstName} ${user.first.lastName} ${user.first.email} ${user.first.phoneNumber} ${user.first.bio}",
      );
    } catch (e) {
      emit(UserProfileError(errorMessage: e.toString()));
    }
  }
}
