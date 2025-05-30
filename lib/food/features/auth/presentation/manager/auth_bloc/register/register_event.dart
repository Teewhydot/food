part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}

class RegisterInitialEvent extends RegisterEvent {
  final String fullName;
  final String email;
  final String password;

  RegisterInitialEvent({
    required this.fullName,
    required this.email,
    required this.password,
  });
}
