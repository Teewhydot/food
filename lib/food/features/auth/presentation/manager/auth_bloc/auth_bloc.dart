import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitialState()) {
    // For login
    on<AuthLoginEvent>((event, emit)async {
      emit(AuthLoadingState());
      // Simulate a network call

     await Future.delayed(const Duration(seconds: 5), () {
        emit(AuthFailureState(
          error: "Login failed. Please try again.",
        ));
      });
    });

    // For SignUp
    on<AuthSignUpEvent>((event, emit) async{
      emit(AuthLoadingState());
      // Simulate a network call

    await  Future.delayed(const Duration(seconds: 2), () {
        emit(AuthSuccessState());
      });
    });

    // For forgot password
    on<AuthForgotPasswordEvent>((event, emit) async {
      emit(AuthLoadingState());
      // Simulate a network call

    await  Future.delayed(const Duration(seconds: 2), () {
        emit(AuthSuccessState());
      });
    });
  }
}
