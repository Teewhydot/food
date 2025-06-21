part of 'location_bloc.dart';

@immutable
sealed class LocationState {}

final class LocationInitial extends LocationState {}

final class LocationLoading extends LocationState {}

final class LocationSuccess extends LocationState implements AppSuccessState {
  @override
  final String successMessage;

  LocationSuccess({required this.successMessage});
}

final class LocationFailure extends LocationState implements AppErrorState {
  @override
  final String errorMessage;

  LocationFailure({required this.errorMessage});
}
