part of 'address_cubit.dart';

@immutable
sealed class AddressState {}

final class AddressInitial extends AddressState {}

final class AddressLoading extends AddressState {}

final class AddressLoaded extends AddressState {
  final List<AddressEntity> addresses;

  AddressLoaded({required this.addresses});
}

final class AddressAdded extends AddressState {
  final AddressEntity address;

  AddressAdded({required this.address});
}

final class AddressUpdated extends AddressState {
  final AddressEntity address;

  AddressUpdated({required this.address});
}

final class AddressDeleted extends AddressState {
  final String message;

  AddressDeleted({required this.message});
}

final class AddressError extends AddressState {
  final String errorMessage;

  AddressError({required this.errorMessage});
}
