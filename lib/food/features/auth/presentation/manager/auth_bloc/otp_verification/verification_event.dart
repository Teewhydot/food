part of 'verification_bloc.dart';

@immutable
sealed class VerificationEvent {}

class VerificationRequestedEvent extends VerificationEvent {
  final String otpCode;

  VerificationRequestedEvent({required this.otpCode});
}
