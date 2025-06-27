part of 'register_bloc.dart';

@immutable
sealed class RegisterEvent {}

class RegisterInitialEvent extends RegisterEvent {
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final String password;

  RegisterInitialEvent({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.password,
  });
}
