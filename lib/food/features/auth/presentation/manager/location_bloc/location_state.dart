part of 'location_bloc.dart';

@immutable
sealed class LocationState {}

final class LocationInitial extends LocationState {}

final class LocationLoading extends LocationState {}

final class LocationSuccess extends LocationState {
  final String message;

  LocationSuccess({required this.message});
}

final class LocationFailure extends LocationState {
  final String error;

  LocationFailure({required this.error});
}
