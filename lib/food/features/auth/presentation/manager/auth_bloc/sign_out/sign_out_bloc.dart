import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/services/floor_db_service/user_profile/user_profile_database_service.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:meta/meta.dart';

import '../../../../domain/use_cases/auth_usecase.dart';

part 'sign_out_event.dart';
// part 'sign_out_state.dart'; // Commented out - using BaseState now

/// Migrated SignOutBloc to use BaseState<void>
class SignOutBloc extends BaseBloC<SignOutEvent, BaseState<void>> {
  final _authUseCase = AuthUseCase();
  final _userProfileDatabaseService = UserProfileDatabaseService();

  SignOutBloc() : super(const InitialState<void>()) {
    on<SignOutRequestEvent>((event, emit) async {
      emit(const LoadingState<void>(message: 'Signing out...'));

      final result = await _authUseCase.signOut();

      result.fold(
        (failure) => emit(
          ErrorState<void>(
            errorMessage: failure.failureMessage,
            errorCode: 'sign_out_failed',
            isRetryable: true,
          ),
        ),
        (_) async {
          // Clear user profile from database on successful sign out
          try {
            final database = await _userProfileDatabaseService.database;
            await database.userProfileDao.deleteUserProfile();
            Logger.logSuccess("User profile cleared from database on sign out");
          } catch (e) {
            Logger.logError("Error clearing user profile: ${e.toString()}");
            // Continue with sign out even if database clear fails
          }
          emit(
            const SuccessState<void>(
              successMessage: 'Successfully signed out',
            ),
          );
        },
      );
    });
  }
}
