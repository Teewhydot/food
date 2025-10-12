part of 'update_password_bloc.dart';

@immutable
sealed class UpdatePasswordEvent {}

class UpdatePasswordSubmitEvent extends UpdatePasswordEvent {
  final String email;
  final String currentPassword;
  final String newPassword;

  UpdatePasswordSubmitEvent({
    required this.email,
    required this.currentPassword,
    required this.newPassword,
  });
}
