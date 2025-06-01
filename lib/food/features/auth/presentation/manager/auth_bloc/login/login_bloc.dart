import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitialState()) {
    // For login
    on<AuthLoginEvent>((event, emit) async {
      emit(LoginLoadingState());
      // Simulate a network call

      await Future.delayed(const Duration(seconds: 1), () {
        emit(LoginSuccessState());
      });
    });
  }
}
