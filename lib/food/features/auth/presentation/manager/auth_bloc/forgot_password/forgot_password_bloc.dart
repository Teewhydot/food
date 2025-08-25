import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/features/auth/domain/use_cases/auth_usecase.dart';
import 'package:meta/meta.dart';

part 'forgot_password_event.dart';
// part 'forgot_password_state.dart'; // Commented out - using BaseState now

/// Migrated ForgotPasswordBloc to use BaseState<void>
class ForgotPasswordBloc
    extends BaseBloC<ForgotPasswordEvent, BaseState<void>> {
  final _authUseCase = AuthUseCase();

  ForgotPasswordBloc() : super(const InitialState<void>()) {
    on<ForgotPasswordSubmitEvent>((event, emit) async {
      emit(const LoadingState<void>(message: 'Sending password reset email...'));

      final result = await _authUseCase.sendPasswordResetEmail(event.email);

      result.fold(
        (failure) => emit(
          ErrorState<void>(
            errorMessage: failure.failureMessage,
            errorCode: 'password_reset_failed',
            isRetryable: true,
          ),
        ),
        (_) => emit(
          SuccessState<void>(
            successMessage: 'Password reset link sent to ${event.email}',
          ),
        ),
      );
    });
  }
}
