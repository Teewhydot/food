part of 'sign_out_bloc.dart';

@immutable
sealed class SignOutState {}

final class SignOutInitialState extends SignOutState {}

final class SignOutLoadingState extends SignOutState {}

final class SignOutSuccessState extends SignOutState
    implements AppSuccessState {
  @override
  final String successMessage;

  SignOutSuccessState({required this.successMessage});
}

final class SignOutFailureState extends SignOutState implements AppErrorState {
  @override
  final String errorMessage;

  SignOutFailureState({required this.errorMessage});
}
