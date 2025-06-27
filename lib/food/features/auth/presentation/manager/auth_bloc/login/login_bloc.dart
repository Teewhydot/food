import 'package:bloc/bloc.dart';
import 'package:food/food/core/bloc/app_state.dart';
import 'package:meta/meta.dart';

import '../../../../domain/use_cases/auth_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final _authUseCase = AuthUseCase();
  LoginBloc() : super(LoginInitialState()) {
    on<AuthLoginEvent>((event, emit) async {
      emit(LoginLoadingState());
      final result = await _authUseCase.login(event.email, event.password);
      result.fold(
        (failure) =>
            emit(LoginFailureState(errorMessage: failure.failureMessage)),
        (userProfile) =>
            emit(LoginSuccessState(successMessage: 'Successfully logged in')),
      );
    });
  }
}
