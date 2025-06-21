part of 'verification_bloc.dart';

@immutable
sealed class VerificationState {}

final class VerificationInitial extends VerificationState {}

final class VerificationLoading extends VerificationState {}

final class VerificationSuccess extends VerificationState
    implements AppSuccessState {
  @override
  final String successMessage;

  VerificationSuccess({required this.successMessage});
}

final class VerificationFailure extends VerificationState
    implements AppErrorState {
  @override
  final String errorMessage;

  VerificationFailure({required this.errorMessage});
}
