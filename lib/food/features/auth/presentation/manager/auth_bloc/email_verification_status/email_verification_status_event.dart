part of 'email_verification_status_bloc.dart';

@immutable
sealed class VerifyEmailEvent {}

class CheckEmailVerificationEvent extends VerifyEmailEvent {}

class ResendVerificationEmailEvent extends VerifyEmailEvent {
  final String email;

  ResendVerificationEmailEvent({required this.email});
}
