import 'package:bloc/bloc.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:meta/meta.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(ForgotPasswordInitial()) {
    on<ForgotPasswordSubmitEvent>((event, emit) async {
      emit(ForgotPasswordLoading());
      // Simulate a network call

      await Future.delayed(const Duration(seconds: 5), () {
        emit(
          ForgotPasswordSuccess(successMessage: 'Code sent to ${event.email}'),
        );
      });
    });
  }
}
