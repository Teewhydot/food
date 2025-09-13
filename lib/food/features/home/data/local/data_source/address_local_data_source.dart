import '../../../../../core/services/floor_db_service/address/address_database_service.dart';
import '../../../domain/entities/address.dart';

abstract class AddressLocalDataSource {
  Future<void> saveAddress(AddressEntity address);
  Future<void> updateAddress(AddressEntity address);
  Future<void> deleteAddress(AddressEntity address);
  Future<List<AddressEntity>> loadAddresses();
}

class FloorDbLocalImplementation extends AddressLocalDataSource {
  final db = AddressDatabaseService();

  @override
  Future<void> deleteAddress(AddressEntity address) async {
    await (await db.database).addressDao.deleteAddress(address);
    // Reload addresses to get updated list
    loadAddresses();
  }

  @override
  Future<void> saveAddress(AddressEntity address) async {
    return (await db.database).addressDao.insertAddress(address);
  }

  @override
  Future<void> updateAddress(AddressEntity address) async {
    return (await db.database).addressDao.updateAddress(address);
  }

  @override
  Future<List<AddressEntity>> loadAddresses() async {
    return (await db.database).addressDao.getAddresses();
  }
}
