part of 'forgot_password_bloc.dart';

@immutable
sealed class ForgotPasswordState {}

final class ForgotPasswordInitial extends ForgotPasswordState {}

final class ForgotPasswordLoading extends ForgotPasswordState {}

final class ForgotPasswordSuccess extends ForgotPasswordState
    implements AppSuccessState {
  @override
  final String successMessage;

  ForgotPasswordSuccess({required this.successMessage});
}

final class ForgotPasswordFailure extends ForgotPasswordState
    implements AppErrorState {
  @override
  final String errorMessage;

  ForgotPasswordFailure({required this.errorMessage});
}
