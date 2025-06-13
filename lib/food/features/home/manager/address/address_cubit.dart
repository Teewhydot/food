import 'package:bloc/bloc.dart';
import 'package:food/food/core/services/floor_db_service/address/address_database_service.dart';
import 'package:food/food/features/home/domain/entities/address.dart';
import 'package:meta/meta.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit() : super(AddressInitial());
  int? userId;
  final db = AddressDatabaseService();

  void addAddress(AddressEntity address) async {
    emit(AddressLoading());
    try {
      await (await db.database).addressDao.insertAddress(address);
      emit(AddressAdded(address: address));
    } catch (e) {
      emit(AddressError(errorMessage: e.toString()));
    }
  }

  void loadAddresses() async {
    emit(AddressLoading());
    try {
      final addresses = await (await db.database).addressDao.getAddresses();
      emit(AddressLoaded(addresses: addresses));
    } catch (e) {
      emit(AddressError(errorMessage: e.toString()));
    }
  }

  void updateAddress(AddressEntity address) async {
    emit(AddressLoading());
    try {
      await (await db.database).addressDao.insertAddress(address);
      emit(AddressUpdated(address: address));
      // loadAddresses();
    } catch (e) {
      emit(AddressError(errorMessage: e.toString()));
    }
  }

  void deleteAddress(AddressEntity address) async {
    emit(AddressLoading());
    try {
      await (await db.database).addressDao.deleteAddress(address);
      emit(AddressDeleted(message: "Address deleted successfully"));
      // loadAddresses();
    } catch (e) {
      emit(AddressError(errorMessage: e.toString()));
    }
  }
}
