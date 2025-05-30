part of 'forgot_password_bloc.dart';

@immutable
sealed class ForgotPasswordEvent {}

class ForgotPasswordSubmitEvent extends ForgotPasswordEvent {
  final String email;

  ForgotPasswordSubmitEvent({required this.email});
}
