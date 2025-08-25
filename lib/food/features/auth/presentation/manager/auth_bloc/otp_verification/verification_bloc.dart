import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:meta/meta.dart';

part 'verification_event.dart';
// part 'verification_state.dart'; // Commented out - using BaseState now

/// Migrated VerificationBloc to use BaseState<void>
/// Since verification doesn't return data, we use void as the type parameter
class VerificationBloc extends BaseBloC<VerificationEvent, BaseState<void>> {
  VerificationBloc() : super(const InitialState<void>()) {
    on<VerificationRequestedEvent>((event, emit) async {
      emit(const LoadingState<void>(message: 'Verifying OTP...'));
      // Simulate a network call
      await Future.delayed(const Duration(seconds: 5));
      
      if (event.otpCode == "1234") {
        emit(
          const SuccessState<void>(
            successMessage: "OTP verified successfully!",
          ),
        );
      } else {
        emit(
          const ErrorState<void>(
            errorMessage: "Invalid OTP code!",
            errorCode: 'invalid_otp',
            isRetryable: true,
          ),
        );
      }
    });
  }
}
