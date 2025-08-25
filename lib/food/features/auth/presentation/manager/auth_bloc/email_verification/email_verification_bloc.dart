import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:meta/meta.dart';

import '../../../../domain/use_cases/auth_usecase.dart';

part 'email_verification_event.dart';
// part 'email_verification_state.dart'; // Commented out - using BaseState now

/// Migrated EmailVerificationBloc to use BaseState<void>
class EmailVerificationBloc
    extends BaseBloC<EmailVerificationEvent, BaseState<void>> {
  final _authUseCase = AuthUseCase();

  EmailVerificationBloc() : super(const InitialState<void>()) {
    on<SendEmailVerificationEvent>((event, emit) async {
      emit(const LoadingState<void>(message: 'Sending verification email...'));
      final result = await _authUseCase.sendEmailVerification(event.email);
      result.fold(
        (failure) => emit(
          ErrorState<void>(
            errorMessage: failure.failureMessage,
            errorCode: 'email_verification_failed',
            isRetryable: true,
          ),
        ),
        (_) => emit(
          const SuccessState<void>(
            successMessage: 'Verification email sent successfully',
          ),
        ),
      );
    });
  }
}
