import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:meta/meta.dart';

import '../../../../../home/domain/entities/profile.dart';
import '../../../../domain/use_cases/auth_usecase.dart';

part 'email_verification_status_event.dart';
// part 'email_verification_status_state.dart'; // Commented out - using BaseState now

/// Migrated VerifyEmailBloc to use BaseState<UserProfileEntity>
class VerifyEmailBloc extends BaseBloC<VerifyEmailEvent, BaseState<UserProfileEntity>> {
  final _authUseCase = AuthUseCase();

  VerifyEmailBloc() : super(const InitialState<UserProfileEntity>()) {
    on<CheckEmailVerificationEvent>((event, emit) async {
      emit(const LoadingState<UserProfileEntity>(message: 'Checking verification status...'));

      final result = await _authUseCase.verifyEmail();

      result.fold(
        (failure) => emit(
          ErrorState<UserProfileEntity>(
            errorMessage: failure.failureMessage,
            errorCode: 'verification_check_failed',
            isRetryable: false,
          ),
        ),
        (userProfile) {
          emit(
            LoadedState<UserProfileEntity>(
              data: userProfile,
              lastUpdated: DateTime.now(),
            ),
          );
          emit(
            const SuccessState<UserProfileEntity>(
              successMessage: 'Email verification successful',
            ),
          );
        },
      );
    });

    on<ResendVerificationEmailEvent>((event, emit) async {
      emit(const LoadingState<UserProfileEntity>(message: 'Resending verification email...'));

      final result = await _authUseCase.sendEmailVerification(event.email);

      result.fold(
        (failure) => emit(
          ErrorState<UserProfileEntity>(
            errorMessage: failure.failureMessage,
            errorCode: 'resend_verification_failed',
            isRetryable: false,
          ),
        ),
        (_) => emit(
          SuccessState<UserProfileEntity>(
            successMessage:
                'Verification email has been sent to ${event.email}',
          ),
        ),
      );
    });
  }
}
