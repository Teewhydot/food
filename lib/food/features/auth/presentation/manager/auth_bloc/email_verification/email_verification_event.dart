part of 'email_verification_bloc.dart';

@immutable
sealed class EmailVerificationEvent {}

class EmailVerificationInitialEvent extends EmailVerificationEvent {}

class SendEmailVerificationEvent extends EmailVerificationEvent {
  final String email;

  SendEmailVerificationEvent({required this.email});
}
