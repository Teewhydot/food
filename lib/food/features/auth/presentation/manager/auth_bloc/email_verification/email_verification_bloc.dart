import 'package:bloc/bloc.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:meta/meta.dart';

import '../../../../domain/use_cases/auth_usecase.dart';

part 'email_verification_event.dart';
part 'email_verification_state.dart';

class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  final _authUseCase = AuthUseCase();

  EmailVerificationBloc() : super(EmailVerificationInitialState()) {
    on<SendEmailVerificationEvent>((event, emit) async {
      emit(EmailVerificationLoadingState());
      final result = await _authUseCase.sendEmailVerification(event.email);
      result.fold(
        (failure) => emit(
          EmailVerificationFailureState(errorMessage: failure.failureMessage),
        ),
        (_) => emit(
          EmailVerificationSuccessState(
            successMessage: 'Verification email sent successfully',
          ),
        ),
      );
    });
  }
}
