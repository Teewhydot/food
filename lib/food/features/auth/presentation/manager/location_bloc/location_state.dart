part of 'location_bloc.dart';

@immutable
sealed class LocationState {}

final class LocationInitial extends LocationState {}

final class LocationLoading extends LocationState {}

final class LocationSuccess extends LocationState implements AppSuccessState {
  @override
  final String successMessage;
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;

  LocationSuccess({
    required this.successMessage,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
  });
}

final class LocationError extends LocationState implements AppErrorState {
  @override
  final String errorMessage;

  LocationError({required this.errorMessage});
}

// New permission state classes
final class LocationPermissionRequired extends LocationState {
  final String permissionMessage;

  LocationPermissionRequired({required this.permissionMessage});
}

final class LocationPermissionGranted extends LocationState {
  final String permissionMessage;

  LocationPermissionGranted({required this.permissionMessage});
}
