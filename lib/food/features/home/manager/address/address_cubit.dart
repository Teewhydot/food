import 'package:bloc/bloc.dart';
import 'package:food/food/core/services/floor_db_service/address/address_database_service.dart';
import 'package:food/food/features/home/domain/entities/address.dart';
import 'package:meta/meta.dart';

import '../../../../core/bloc/app_state.dart';

part 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  AddressCubit() : super(AddressInitial());
  final db = AddressDatabaseService();

  void addAddress(AddressEntity address) async {
    emit(AddressLoading());
    await Future.delayed(const Duration(seconds: 5));
    try {
      await (await db.database).addressDao.insertAddress(address);
      emit(AddressAdded(address: address));
      loadAddresses();
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  void loadAddresses() async {
    emit(AddressLoading());
    try {
      final addresses = await (await db.database).addressDao.getAddresses();
      emit(AddressLoaded(addresses: addresses));
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  void updateAddress(AddressEntity address) async {
    emit(AddressLoading());
    try {
      await (await db.database).addressDao.insertAddress(address);
      emit(AddressUpdated(address: address));
      loadAddresses();
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }

  void deleteAddress(AddressEntity address) async {
    emit(AddressLoading());
    try {
      await (await db.database).addressDao.deleteAddress(address);
      emit(AddressDeleted());
      loadAddresses();
    } catch (e) {
      emit(AddressError(e.toString()));
    }
  }
}
