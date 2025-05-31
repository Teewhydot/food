part of 'verification_bloc.dart';

@immutable
sealed class VerificationState {}

final class VerificationInitial extends VerificationState {}

final class VerificationLoading extends VerificationState {}

final class VerificationSuccess extends VerificationState {
  final String message;

  VerificationSuccess({required this.message});
}

final class VerificationFailure extends VerificationState {
  final String error;

  VerificationFailure({required this.error});
}
