import 'package:bloc/bloc.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:meta/meta.dart';

import '../../../../../home/domain/entities/profile.dart';
import '../../../../domain/use_cases/auth_usecase.dart';

part 'email_verification_status_event.dart';
part 'email_verification_status_state.dart';

class VerifyEmailBloc extends Bloc<VerifyEmailEvent, VerifyEmailState> {
  final _authUseCase = AuthUseCase();

  VerifyEmailBloc() : super(EmailVerificationStatusInitial()) {
    on<CheckEmailVerificationEvent>((event, emit) async {
      emit(EmailVerificationStatusLoading());

      final result = await _authUseCase.verifyEmail();

      result.fold(
        (failure) => emit(
          EmailVerificationStatusFailure(errorMessage: failure.failureMessage),
        ),
        (userProfile) => emit(
          EmailVerificationStatusSuccess(
            successMessage: 'Email verification successful',
            userProfile: userProfile,
          ),
        ),
      );
    });

    on<ResendVerificationEmailEvent>((event, emit) async {
      emit(EmailVerificationStatusLoading());

      final result = await _authUseCase.sendEmailVerification(event.email);

      result.fold(
        (failure) => emit(
          EmailVerificationStatusFailure(errorMessage: failure.failureMessage),
        ),
        (_) => emit(
          EmailVerificationResendSuccess(
            successMessage:
                'Verification email has been sent to ${event.email}',
          ),
        ),
      );
    });
  }
}
