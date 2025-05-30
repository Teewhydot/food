part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

class AuthInitialEvent extends LoginEvent {}

class AuthLoginEvent extends LoginEvent {
  final String email;
  final String password;

  AuthLoginEvent({required this.email, required this.password});
}

class AuthSignUpEvent extends LoginEvent {
  final String fullName;
  final String email;
  final String password;

  AuthSignUpEvent({
    required this.fullName,
    required this.email,
    required this.password,
  });
}

class AuthLogoutEvent extends LoginEvent {}

class AuthForgotPasswordEvent extends LoginEvent {
  final String email;

  AuthForgotPasswordEvent({required this.email});
}
