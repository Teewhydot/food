import 'package:bloc/bloc.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:food/food/core/services/floor_db_service/user_profile/user_profile_database_service.dart';
import 'package:food/food/core/utils/logger.dart';
import 'package:meta/meta.dart';

import '../../../../domain/use_cases/auth_usecase.dart';

part 'sign_out_event.dart';
part 'sign_out_state.dart';

class SignOutBloc extends Bloc<SignOutEvent, SignOutState> {
  final _authUseCase = AuthUseCase();
  final _userProfileDatabaseService = UserProfileDatabaseService();

  SignOutBloc() : super(SignOutInitialState()) {
    on<SignOutRequestEvent>((event, emit) async {
      emit(SignOutLoadingState());

      final result = await _authUseCase.signOut();

      result.fold(
        (failure) =>
            emit(SignOutFailureState(errorMessage: failure.failureMessage)),
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
          emit(SignOutSuccessState(successMessage: 'Successfully signed out'));
        },
      );
    });
  }
}
