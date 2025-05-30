part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

class AuthInitialEvent extends LoginEvent {}

class AuthLoginEvent extends LoginEvent {
  final String email;
  final String password;

  AuthLoginEvent({required this.email, required this.password});
}
