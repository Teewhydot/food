import 'package:bloc/bloc.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:meta/meta.dart';

part 'verification_event.dart';
part 'verification_state.dart';

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  VerificationBloc() : super(VerificationInitial()) {
    on<VerificationRequestedEvent>((event, emit) async {
      emit(VerificationLoading());
      // Simulate a network call
      await Future.delayed(const Duration(seconds: 5), () {
        if (event.otpCode == "1234") {
          emit(
            VerificationSuccess(successMessage: "OTP verified successfully!"),
          );
        } else {
          emit(VerificationFailure(errorMessage: "Invalid OTP code!"));
        }
      });
    });
  }
}
