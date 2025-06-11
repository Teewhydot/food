import 'package:bloc/bloc.dart';
import 'package:food/food/core/services/floor_db_service/user_profile/user_profile_database_service.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:meta/meta.dart';

part 'user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit() : super(UserProfileInitial());
  final db = UserProfileDatabaseService();

  void updateUserProfile(UserProfileEntity userProfile) async {
    emit(UserProfileLoading());
    try {
      await (await db.database).userProfileDao.saveUserProfile(userProfile);
      emit(UserProfileLoaded(userProfile: userProfile));
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
      emit(
        UserProfileLoaded(
          userProfile:
              user ??
              UserProfileEntity(
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
}
