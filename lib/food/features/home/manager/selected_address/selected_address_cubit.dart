import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/features/home/domain/entities/address.dart';
import 'package:food/food/features/home/domain/use_cases/address_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectedAddressCubit extends BaseCubit<BaseState<AddressEntity?>> {
  SelectedAddressCubit() : super(const InitialState<AddressEntity?>()) {
    _loadDefaultAddress();
  }

  final _addressUseCase = AddressUseCase();
  final _auth = FirebaseAuth.instance;

  /// Load the default address on initialization
  void _loadDefaultAddress() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    emit(const LoadingState<AddressEntity?>(message: 'Loading default address...'));

    final result = await _addressUseCase.getDefaultAddress(userId);
    result.fold(
      (failure) {
        // If no default address found, emit empty state
        emit(const LoadedState<AddressEntity?>(data: null));
      },
      (defaultAddress) {
        emit(LoadedState<AddressEntity?>(data: defaultAddress));
      },
    );
  }

  /// Select an address
  void selectAddress(AddressEntity address) {
    emit(LoadedState<AddressEntity?>(data: address));
  }

  /// Clear selected address
  void clearSelectedAddress() {
    emit(const LoadedState<AddressEntity?>(data: null));
  }

  /// Set an address as default and select it
  void setAsDefaultAndSelect(AddressEntity address) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    emit(const LoadingState<AddressEntity?>(message: 'Setting default address...'));

    final result = await _addressUseCase.setDefaultAddress(userId, address.id);
    result.fold(
      (failure) {
        emit(ErrorState<AddressEntity?>(
          errorMessage: failure.failureMessage,
        ));
      },
      (_) {
        // Update the address to reflect it's now default
        final updatedAddress = AddressEntity(
          id: address.id,
          street: address.street,
          city: address.city,
          state: address.state,
          zipCode: address.zipCode,
          address: address.address,
          apartment: address.apartment,
          type: address.type,
          title: address.title,
          latitude: address.latitude,
          longitude: address.longitude,
          isDefault: true,
        );
        emit(LoadedState<AddressEntity?>(data: updatedAddress));
      },
    );
  }

  /// Get currently selected address
  AddressEntity? get selectedAddress => state.hasData ? state.data : null;

  /// Check if any address is selected
  bool get hasSelectedAddress => selectedAddress != null;

  /// Get formatted address string for display
  String get selectedAddressText {
    final address = selectedAddress;
    if (address == null) return 'Select delivery address';
    return address.fullAddress;
  }
}