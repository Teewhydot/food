import 'package:bloc/bloc.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:food/food/features/auth/domain/use_cases/auth_usecase.dart';
import 'package:meta/meta.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final _authUseCase = AuthUseCase();

  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitEvent>((event, emit) async {
      emit(ForgotPasswordLoading());

      final result = await _authUseCase.sendPasswordResetEmail(event.email);

      result.fold(
        (failure) =>
            emit(ForgotPasswordFailure(errorMessage: failure.failureMessage)),
        (_) => emit(
          ForgotPasswordSuccess(
            successMessage: 'Password reset link sent to ${event.email}',
          ),
        ),
      );
    });
  }
}
