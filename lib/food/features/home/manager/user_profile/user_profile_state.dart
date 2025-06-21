part of 'user_profile_cubit.dart';

@immutable
sealed class UserProfileState {}

final class UserProfileInitial extends UserProfileState {}

final class UserProfileLoading extends UserProfileState {}

final class UserProfileLoaded extends UserProfileState {
  final UserProfileEntity userProfile;

  bool? get firstTimeLogin => userProfile.firstTimeLogin;
  UserProfileLoaded({required this.userProfile});
}

final class UserProfileError extends UserProfileState implements AppErrorState {
  @override
  final String errorMessage;

  UserProfileError({required this.errorMessage});
}
