import 'package:floor/floor.dart';
import 'package:food/food/core/services/floor_db_service/constants.dart';
import 'package:food/food/features/home/domain/entities/address.dart';

@dao
abstract class AddressDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAddress(AddressEntity address);

  @Query('SELECT * FROM ${FloorDbConstants.addressTableName}')
  Future<List<AddressEntity>> getAddresses();

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateAddress(AddressEntity updatedAddress);

  @delete
  Future<void> deleteAddress(AddressEntity address);

  @Query('DELETE FROM ${FloorDbConstants.addressTableName}')
  Future<void> deleteAllAddresses();
}
