import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/bloc/base/base_bloc.dart';
import '../../../../core/bloc/base/base_state.dart';
import '../../../../core/bloc/mixins/cacheable_bloc_mixin.dart';
import '../../../../core/bloc/mixins/refreshable_bloc_mixin.dart';
import '../../../../core/bloc/utils/state_utils.dart';
import '../../../../core/services/floor_db_service/user_profile/user_profile_database_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/failures/failures.dart';
import '../../../auth/domain/use_cases/auth_usecase.dart';
import '../../domain/entities/profile.dart';
import '../../domain/use_cases/user_profile_usecase.dart';

/// Enhanced User Profile Cubit with modern state management
class UserProfileCubit extends BaseCubit<BaseState<UserProfileEntity>>
    with
        CacheableBlocMixin<BaseState<UserProfileEntity>>,
        RefreshableBlocMixin<BaseState<UserProfileEntity>> {
  final UserProfileUseCase _userProfileUseCase;
  final AuthUseCase _authUseCase;
  final UserProfileDatabaseService _databaseService;

  UserProfileCubit({
    UserProfileUseCase? userProfileUseCase,
    AuthUseCase? authUseCase,
    UserProfileDatabaseService? databaseService,
  }) : _userProfileUseCase =
           userProfileUseCase ?? GetIt.instance<UserProfileUseCase>(),
       _authUseCase = authUseCase ?? AuthUseCase(),
       _databaseService = databaseService ?? UserProfileDatabaseService(),
       super(const InitialState<UserProfileEntity>());

  @override
  String get cacheKey => 'user_profile_cubit';

  @override
  bool get autoRefreshEnabled => true;

  @override
  Duration get autoRefreshInterval => const Duration(minutes: 30);

  @override
  Duration get cacheTimeout => const Duration(hours: 24);

  /// Initialize the cubit and load user profile
  Future<void> initialize() async {
    // Try to load from cache first
    final cachedState = await loadStateFromCache();
    if (cachedState != null) {
      emit(cachedState);
      Logger.logBasic('User profile loaded from cache');

      // Refresh in background if cache is getting old
      final cacheAge = await getCacheAge();
      if (cacheAge != null && cacheAge > const Duration(hours: 1)) {
        _refreshInBackground();
      }
      return;
    }

    // Load fresh data
    await loadUserProfile();
  }

  Stream<Either<Failure, UserProfileEntity>> watchUserProfile(
    String userId,
  ) async* {
    try {
      yield* _userProfileUseCase.watchUserProfile(userId);
    } catch (e, stackTrace) {
      handleException(Exception(e.toString()), stackTrace);
    }
  }

  /// Load user profile from remote and cache it
  Future<void> loadUserProfile({bool showLoading = true}) async {
    if (showLoading) {
      emit(const LoadingState<UserProfileEntity>());
    }

    try {
      // Get current user from auth service
      final result = await _authUseCase.getCurrentUser();

      await result.fold(
        (failure) async {
          final errorMessage =
              'Failed to load user profile: ${failure.failureMessage}';
          final errorState = ErrorState<UserProfileEntity>(
            errorMessage: errorMessage,
            isRetryable: true,
          );

          emit(errorState);
          Logger.logError(errorMessage);
        },
        (userProfile) async {
          // Save to local database
          await _databaseService.insertUserProfile(userProfile);

          // Create loaded state
          final loadedState = StateUtils.createLoadedState(
            userProfile,
            isFromCache: false,
          );

          emit(loadedState);
          await saveStateToCache(loadedState);

          Logger.logSuccess(
            'User profile loaded successfully: ${userProfile.firstName} ${userProfile.lastName}',
          );
        },
      );
    } catch (e, stackTrace) {
      handleException(Exception(e.toString()), stackTrace);
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfileEntity updatedProfile) async {
    // Show loading with existing data if available
    emit(const LoadingState<UserProfileEntity>());
    final currentData = state.data;
    try {
      // Update via use case (handles both remote and local)
      final result = await _userProfileUseCase.updateUserProfile(
        updatedProfile,
      );

      await result.fold(
        (failure) async {
          final errorMessage =
              'Failed to update profile: ${failure.failureMessage}';

          emit(
            ErrorState<UserProfileEntity>(
              errorMessage: errorMessage,
              isRetryable: false,
            ),
          );
          Logger.logError(errorMessage);
        },
        (profile) async {
          final loadedState = StateUtils.createLoadedState(
            profile,
            isFromCache: false,
          );

          emit(loadedState);
          await saveStateToCache(loadedState);
          Logger.logSuccess(
            'Profile updated: ${profile.firstName} ${profile.lastName}',
          );
        },
      );
    } catch (e, stackTrace) {
      final errorMessage = 'Failed to update profile: $e';

      if (currentData != null) {
        emit(
          StateUtils.createErrorWithDataState(
            currentData,
            errorMessage,
            exception: Exception(e.toString()),
            isRetryable: true,
          ),
        );
      } else {
        handleException(Exception(e.toString()), stackTrace);
      }
    }
  }

  /// Save user profile (for new profiles)
  Future<void> saveUserProfile(UserProfileEntity profile) async {
    emit(const LoadingState<UserProfileEntity>(message: 'Saving profile...'));

    try {
      await _databaseService.insertUserProfile(profile);

      final loadedState = StateUtils.createLoadedState(
        profile,
        isFromCache: false,
      );

      emit(loadedState);
      await saveStateToCache(loadedState);

      _emitSuccessState('Profile saved successfully');
      Logger.logSuccess(
        'Profile saved: ${profile.firstName} ${profile.lastName}',
      );
    } catch (e, stackTrace) {
      handleException(Exception(e.toString()), stackTrace);
    }
  }

  /// Clear user profile (logout scenario)
  Future<void> clearUserProfile() async {
    emit(const LoadingState<UserProfileEntity>(message: 'Clearing profile...'));

    try {
      await _databaseService.deleteUserProfile();
      await clearCache();

      emit(const InitialState<UserProfileEntity>());
      _emitSuccessState('Profile cleared successfully');

      Logger.logBasic('User profile cleared');
    } catch (e, stackTrace) {
      handleException(Exception(e.toString()), stackTrace);
    }
  }

  /// Toggle first-time login status
  Future<void> markNotFirstTimeLogin() async {
    final currentProfile = state.data;
    if (currentProfile == null) return;

    final updatedProfile = UserProfileEntity(
      id: currentProfile.id,
      firstName: currentProfile.firstName,
      lastName: currentProfile.lastName,
      email: currentProfile.email,
      phoneNumber: currentProfile.phoneNumber,
      profileImageUrl: currentProfile.profileImageUrl,
      firstTimeLogin: false, // Mark as not first time
    );

    await updateUserProfile(updatedProfile);
  }

  /// Refresh user profile data
  @override
  Future<void> onRefresh() async {
    await loadUserProfile(showLoading: false);
  }

  /// Refresh in background without showing loading
  Future<void> _refreshInBackground() async {
    try {
      final result = await _authUseCase.getCurrentUser();

      await result.fold(
        (failure) async {
          Logger.logWarning(
            'Background refresh failed: ${failure.failureMessage}',
          );
        },
        (userProfile) async {
          await _databaseService.insertUserProfile(userProfile);

          final loadedState = StateUtils.createLoadedState(
            userProfile,
            isFromCache: false,
          );

          emit(loadedState);
          await saveStateToCache(loadedState);

          Logger.logBasic('Background refresh completed');
        },
      );
    } catch (e) {
      Logger.logWarning('Background refresh failed: $e');
    }
  }

  /// Convert state to JSON for caching
  @override
  Map<String, dynamic>? stateToJson(BaseState<UserProfileEntity> state) {
    if (state is LoadedState<UserProfileEntity> && state.data != null) {
      return {
        'type': 'loaded',
        'data': state.data!.toJson(),
        'lastUpdated': state.lastUpdated?.millisecondsSinceEpoch,
        'isFromCache': state.isFromCache,
      };
    }

    if (state is AsyncLoadedState<UserProfileEntity> && state.data != null) {
      return {
        'type': 'async_loaded',
        'data': state.data!.toJson(),
        'lastUpdated': state.lastUpdated.millisecondsSinceEpoch,
        'isFromCache': state.isFromCache,
      };
    }

    return null;
  }

  /// Create state from cached JSON
  @override
  BaseState<UserProfileEntity>? stateFromJson(Map<String, dynamic> json) {
    try {
      final type = json['type'] as String;
      final data = UserProfileEntity.fromJson(
        json['data'] as Map<String, dynamic>,
      );

      if (type == 'loaded') {
        return LoadedState<UserProfileEntity>(
          data: data,
          lastUpdated:
              json['lastUpdated'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                    json['lastUpdated'] as int,
                  )
                  : null,
          isFromCache: json['isFromCache'] as bool? ?? true,
        );
      }

      if (type == 'async_loaded') {
        return AsyncLoadedState<UserProfileEntity>(
          data: data,
          lastUpdated: DateTime.fromMillisecondsSinceEpoch(
            json['lastUpdated'] as int,
          ),
          isFromCache: json['isFromCache'] as bool? ?? true,
        );
      }
    } catch (e) {
      Logger.logError('Failed to deserialize cached state: $e');
    }

    return null;
  }

  /// Properly typed success state emitter
  void _emitSuccessState(String message, [Map<String, dynamic>? metadata]) {
    emit(
      SuccessState<UserProfileEntity>(
        successMessage: message,
        metadata: metadata,
      ),
    );
  }

  @override
  Future<void> close() {
    disposeRefreshable();
    return super.close();
  }
}
