part of 'email_verification_status_bloc.dart';

// Commented out - migrated to BaseState<UserProfileEntity> system
// @immutable
// sealed class VerifyEmailState {}
// 
// final class EmailVerificationStatusInitial extends VerifyEmailState {}
// 
// final class EmailVerificationStatusLoading extends VerifyEmailState {}
// 
// final class EmailVerificationStatusSuccess extends VerifyEmailState
//     implements AppSuccessState {
//   final UserProfileEntity userProfile;
// 
//   @override
//   final String successMessage;
// 
//   EmailVerificationStatusSuccess({
//     required this.successMessage,
//     required this.userProfile,
//   });
// }
// 
// final class EmailVerificationResendSuccess extends VerifyEmailState
//     implements AppSuccessState {
//   @override
//   final String successMessage;
// 
//   EmailVerificationResendSuccess({required this.successMessage});
// }
// 
// final class EmailVerificationStatusFailure extends VerifyEmailState
//     implements AppErrorState {
//   @override
//   final String errorMessage;
// 
//   EmailVerificationStatusFailure({required this.errorMessage});
// }
