part of 'address_cubit.dart';

// Commented out - migrated to BaseState<List<AddressEntity>> system
// @immutable
// sealed class AddressState {}
// 
// final class AddressInitial extends AddressState {}
// 
// final class AddressLoading extends AddressState {}
// 
// final class AddressLoaded extends AddressState implements AppSuccessState {
//   @override
//   final String successMessage = "Addresses loaded successfully";
//   final List<AddressEntity> addresses;
// 
//   AddressLoaded({required this.addresses});
// }
// 
// final class AddressAdded extends AddressState implements AppSuccessState {
//   @override
//   final String successMessage = "Address added successfully";
//   final AddressEntity address;
// 
//   AddressAdded({required this.address});
// }
// 
// final class AddressError extends AddressState implements AppErrorState {
//   @override
//   final String errorMessage;
//   AddressError(this.errorMessage);
// }
// 
// final class AddressUpdated extends AddressState implements AppSuccessState {
//   @override
//   final String successMessage = "Address updated successfully";
//   final AddressEntity address;
// 
//   AddressUpdated({required this.address});
// }
// 
// final class AddressDeleted extends AddressState implements AppSuccessState {
//   @override
//   final String successMessage;
//   AddressDeleted({this.successMessage = "Address deleted successfully"});
// }
