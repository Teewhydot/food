import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/features/auth/domain/use_cases/auth_usecase.dart';
import 'package:meta/meta.dart';

part 'update_password_event.dart';

/// UpdatePasswordBloc using BaseState<void>
class UpdatePasswordBloc
    extends BaseBloC<UpdatePasswordEvent, BaseState<void>> {
  final _authUseCase = AuthUseCase();

  UpdatePasswordBloc() : super(const InitialState<void>()) {
    on<UpdatePasswordSubmitEvent>((event, emit) async {
      emit(const LoadingState<void>(message: 'Updating password...'));

      final result = await _authUseCase.updatePassword(
        event.email,
        event.currentPassword,
        event.newPassword,
      );

      result.fold(
        (failure) => emit(
          ErrorState<void>(
            errorMessage: failure.failureMessage,
            errorCode: 'update_password_failed',
            isRetryable: true,
          ),
        ),
        (_) => emit(
          const SuccessState<void>(
            successMessage: 'Password updated successfully',
          ),
        ),
      );
    });
  }
}
