import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialState()) {
    // For login
    on<AuthLoginEvent>((event, emit) {
      emit(AuthLoadingState());
      // Simulate a network call

      Future.delayed(const Duration(seconds: 2), () {
        emit(AuthSuccessState());
      });
    });

    // For SignUp
    on<AuthSignUpEvent>((event, emit) {
      emit(AuthLoadingState());
      // Simulate a network call

      Future.delayed(const Duration(seconds: 2), () {
        emit(AuthSuccessState());
      });
    });

    // For forgot password
    on<AuthForgotPasswordEvent>((event, emit) {
      emit(AuthLoadingState());
      // Simulate a network call

      Future.delayed(const Duration(seconds: 2), () {
        emit(AuthSuccessState());
      });
    });
  }
}
