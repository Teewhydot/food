part of 'login_bloc.dart';

@immutable
sealed class LoginState {}

final class LoginInitialState extends LoginState {}

final class LoginLoadingState extends LoginState {}

final class LoginSuccessState extends LoginState implements AppSuccessState {
  @override
  final String successMessage;

  LoginSuccessState({required this.successMessage});
}

final class LoginFailureState extends LoginState implements AppErrorState {
  @override
  final String errorMessage;

  LoginFailureState({required this.errorMessage});
}
