part of 'location_bloc.dart';

@immutable
sealed class LocationEvent {}

class LocationRequestedEvent extends LocationEvent {}
