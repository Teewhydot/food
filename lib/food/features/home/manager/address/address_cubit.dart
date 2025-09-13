import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/features/home/domain/entities/address.dart';
import 'package:food/food/features/home/domain/use_cases/address_usecase.dart';

class AddressCubit extends BaseCubit<BaseState<dynamic>> {
  AddressCubit() : super(const InitialState<dynamic>());
  final addressUseCase = AddressUseCase();

  void addAddress(AddressEntity address) async {
    emit(const LoadingState<AddressEntity>(message: 'Adding address...'));
    final result = await addressUseCase.saveAddress(address);
    result.fold(
      (failure) {
        emit(
          ErrorState<AddressEntity>(
            errorMessage: failure.failureMessage,
            errorCode: 'add_address_failed',
            isRetryable: false,
          ),
        );
      },
      (address) {
        // Emit success notification
        emit(
          const SuccessState<AddressEntity>(
            successMessage: 'Address added successfully',
          ),
        );
      },
    );
  }

  void loadAddresses(String userId) async {
    emit(
      const LoadingState<List<AddressEntity>>(message: 'Loading addresses...'),
    );

    final result = await addressUseCase.getUserAddresses(userId);
    result.fold(
      (failure) {
        emit(
          ErrorState<List<AddressEntity>>(
            errorMessage: failure.failureMessage,
            errorCode: 'load_addresses_failed',
            isRetryable: true,
          ),
        );
      },
      (addresses) {
        emit(LoadedState<List<AddressEntity>>(data: addresses));
      },
    );
  }

  void updateAddress(AddressEntity address) async {
    emit(const LoadingState<AddressEntity>(message: 'Updating address...'));
    final result = await addressUseCase.updateAddress(address);
    result.fold(
      (failure) {
        emit(
          ErrorState<AddressEntity>(
            errorMessage: failure.failureMessage,
            errorCode: 'update_address_failed',
            isRetryable: false,
          ),
        );
      },
      (address) {
        // Emit success notification
        emit(
          const SuccessState<AddressEntity>(
            successMessage: 'Address updated successfully',
          ),
        );
      },
    );
  }

  void deleteAddress(AddressEntity address) async {
    emit(const LoadingState<void>(message: 'Deleting address...'));
    final result = await addressUseCase.deleteAddress(address.id!);
    result.fold(
      (failure) {
        emit(
          ErrorState<void>(
            errorMessage: failure.failureMessage,
            errorCode: 'delete_address_failed',
            isRetryable: false,
          ),
        );
      },
      (_) {
        // Emit success notification
        emit(
          const SuccessState<void>(
            successMessage: 'Address deleted successfully',
          ),
        );
      },
    );
  }
}
