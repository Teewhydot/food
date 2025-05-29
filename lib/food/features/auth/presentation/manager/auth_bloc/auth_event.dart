part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthInitialEvent extends AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  AuthLoginEvent({required this.email, required this.password});
}

class AuthSignUpEvent extends AuthEvent {
  final String fullName;
  final String email;
  final String password;

  AuthSignUpEvent({
    required this.fullName,
    required this.email,
    required this.password,
  });
}

class AuthLogoutEvent extends AuthEvent {}

class AuthForgotPasswordEvent extends AuthEvent {
  final String email;

  AuthForgotPasswordEvent({required this.email});
}
