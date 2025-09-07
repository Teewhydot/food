import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/services/floor_db_service/user_profile/user_profile_database_service.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:food/food/features/auth/domain/use_cases/auth_usecase.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';

// part 'user_profile_state.dart'; // Commented out - using BaseState now

/// Migrated UserProfileCubit to use BaseState<UserProfileEntity>
class UserProfileCubit extends BaseCubit<BaseState<UserProfileEntity>> {
  UserProfileCubit() : super(const InitialState<UserProfileEntity>());
  final db = UserProfileDatabaseService();
  final authUseCase = AuthUseCase();

  void saveUserProfile(UserProfileEntity userProfile) async {
    emit(const LoadingState<UserProfileEntity>(message: 'Saving profile...'));
    try {
      Logger.logSuccess(
        "Saving details: ${userProfile.firstName} ${userProfile.lastName} ${userProfile.email} ${userProfile.phoneNumber} ${userProfile.bio} ${userProfile.firstTimeLogin}",
      );
      await (await db.database).userProfileDao.saveUserProfile(userProfile);
      
      // Emit loaded state with saved profile
      emit(
        LoadedState<UserProfileEntity>(
          data: userProfile,
          lastUpdated: DateTime.now(),
        ),
      );
      
      // Also emit success notification
      emit(
        const SuccessState<UserProfileEntity>(
          successMessage: 'Profile saved successfully',
        ),
      );
    } catch (e) {
      emit(
        ErrorState<UserProfileEntity>(
          errorMessage: e.toString(),
          errorCode: 'save_profile_failed',
          isRetryable: true,
        ),
      );
    }
  }

  void updateUserProfile(UserProfileEntity userProfile) async {
    emit(const LoadingState<UserProfileEntity>(message: 'Updating profile...'));
    try {
      Logger.logSuccess(
        "Updated details: ${userProfile.firstName} ${userProfile.lastName} ${userProfile.email} ${userProfile.phoneNumber} ${userProfile.bio}",
      );
      await (await db.database).userProfileDao.updateUserProfile(userProfile);
      
      // Emit loaded state with updated profile
      emit(
        LoadedState<UserProfileEntity>(
          data: userProfile,
          lastUpdated: DateTime.now(),
        ),
      );
      
      // Also emit success notification
      emit(
        const SuccessState<UserProfileEntity>(
          successMessage: 'Profile updated successfully',
        ),
      );
    } catch (e) {
      emit(
        ErrorState<UserProfileEntity>(
          errorMessage: e.toString(),
          errorCode: 'update_profile_failed',
          isRetryable: true,
        ),
      );
    }
  }

  void clearUserProfile() async {
    emit(const LoadingState<UserProfileEntity>(message: 'Clearing profile...'));
    try {
      await (await db.database).userProfileDao.deleteUserProfile();
      
      // Emit success after clearing
      emit(
        const SuccessState<UserProfileEntity>(
          successMessage: 'Profile cleared successfully',
        ),
      );
      
      // Reset to initial state
      emit(const InitialState<UserProfileEntity>());
    } catch (e) {
      emit(
        ErrorState<UserProfileEntity>(
          errorMessage: e.toString(),
          errorCode: 'clear_profile_failed',
          isRetryable: true,
        ),
      );
    }
  }

  void loadUserProfile() async {
    emit(const LoadingState<UserProfileEntity>(message: 'Loading profile...'));
    try {
      // First check local database for cached profile
      final localProfiles = await (await db.database).userProfileDao.getUserProfile();
      
      if (localProfiles.isNotEmpty) {
        final localProfile = localProfiles.first;
        // Emit local profile immediately for instant UI update
        Logger.logSuccess("User loaded from local database: ${localProfile.firstName} ${localProfile.lastName}");
        emit(
          LoadedState<UserProfileEntity>(
            data: localProfile,
            lastUpdated: DateTime.now(),
          ),
        );
        
        // Then fetch fresh data from server in background (optional)
        _fetchAndUpdateFromServer();
      } else {
        // No local data, fetch from server
        final result = await authUseCase.getCurrentUser();
        result.fold(
          (failure) {
            Logger.logError("Failed to get user: ${failure.failureMessage}");
            emit(
              ErrorState<UserProfileEntity>(
                errorMessage: failure.failureMessage,
                errorCode: 'load_profile_failed',
                isRetryable: true,
              ),
            );
          },
          (userProfile) async {
            // Success - save to database and emit loaded state
            Logger.logSuccess(
              "User fetched from server: ${userProfile.firstName} ${userProfile.lastName}",
            );
            await (await db.database).userProfileDao.saveUserProfile(userProfile);
            
            emit(
              LoadedState<UserProfileEntity>(
                data: userProfile,
                lastUpdated: DateTime.now(),
              ),
            );
          },
        );
      }
    } catch (e) {
      emit(
        ErrorState<UserProfileEntity>(
          errorMessage: e.toString(),
          errorCode: 'load_profile_failed',
          isRetryable: true,
        ),
      );
      Logger.logError("Error loading user profile: ${e.toString()}");
    }
  }
  
  /// Fetch fresh data from server and update local cache
  void _fetchAndUpdateFromServer() async {
    try {
      final result = await authUseCase.getCurrentUser();
      result.fold(
        (failure) {
          // Silent fail - we already have local data
          Logger.logError("Background sync failed: ${failure.failureMessage}");
        },
        (userProfile) async {
          // Update local database and emit fresh data
          await (await db.database).userProfileDao.updateUserProfile(userProfile);
          emit(
            LoadedState<UserProfileEntity>(
              data: userProfile,
              lastUpdated: DateTime.now(),
            ),
          );
          Logger.logSuccess("User profile synced from server");
        },
      );
    } catch (e) {
      // Silent fail - we already have local data
      Logger.logError("Background sync error: ${e.toString()}");
    }
  }
}
