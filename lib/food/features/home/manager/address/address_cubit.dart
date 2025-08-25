import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/services/floor_db_service/address/address_database_service.dart';
import 'package:food/food/features/home/domain/entities/address.dart';

// part 'address_state.dart'; // Commented out - using BaseState now

/// Migrated AddressCubit to use BaseState<dynamic>
/// Handles both AddressEntity and List<AddressEntity>
class AddressCubit extends BaseCubit<BaseState<dynamic>> {
  AddressCubit() : super(const InitialState<dynamic>());
  final db = AddressDatabaseService();

  void addAddress(AddressEntity address) async {
    emit(const LoadingState<AddressEntity>(message: 'Adding address...'));
    await Future.delayed(const Duration(seconds: 5));
    try {
      await (await db.database).addressDao.insertAddress(address);
      
      // Emit success notification
      emit(
        const SuccessState<AddressEntity>(
          successMessage: 'Address added successfully',
        ),
      );
      
      // Reload addresses to get updated list
      loadAddresses();
    } catch (e) {
      emit(
        ErrorState<AddressEntity>(
          errorMessage: e.toString(),
          errorCode: 'add_address_failed',
          isRetryable: true,
        ),
      );
    }
  }

  void loadAddresses() async {
    emit(const LoadingState<List<AddressEntity>>(message: 'Loading addresses...'));
    try {
      final addresses = await (await db.database).addressDao.getAddresses();
      
      if (addresses.isEmpty) {
        emit(const EmptyState<List<AddressEntity>>(message: 'No addresses found'));
      } else {
        emit(
          LoadedState<List<AddressEntity>>(
            data: addresses,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      emit(
        ErrorState<List<AddressEntity>>(
          errorMessage: e.toString(),
          errorCode: 'load_addresses_failed',
          isRetryable: true,
        ),
      );
    }
  }

  void updateAddress(AddressEntity address) async {
    emit(const LoadingState<AddressEntity>(message: 'Updating address...'));
    try {
      await (await db.database).addressDao.insertAddress(address);
      
      // Emit success notification
      emit(
        const SuccessState<AddressEntity>(
          successMessage: 'Address updated successfully',
        ),
      );
      
      // Reload addresses to get updated list
      loadAddresses();
    } catch (e) {
      emit(
        ErrorState<AddressEntity>(
          errorMessage: e.toString(),
          errorCode: 'update_address_failed',
          isRetryable: true,
        ),
      );
    }
  }

  void deleteAddress(AddressEntity address) async {
    emit(const LoadingState<void>(message: 'Deleting address...'));
    try {
      await (await db.database).addressDao.deleteAddress(address);
      
      // Emit success notification
      emit(
        const SuccessState<void>(
          successMessage: 'Address deleted successfully',
        ),
      );
      
      // Reload addresses to get updated list
      loadAddresses();
    } catch (e) {
      emit(
        ErrorState<void>(
          errorMessage: e.toString(),
          errorCode: 'delete_address_failed',
          isRetryable: true,
        ),
      );
    }
  }
}
