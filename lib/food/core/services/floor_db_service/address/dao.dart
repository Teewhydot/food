import 'package:floor/floor.dart';
import 'package:food/food/features/home/domain/entities/address.dart';

@dao
abstract class AddressDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertAddress(AddressEntity address);

  @Query('SELECT * FROM addresses WHERE userId = :userId')
  Future<List<AddressEntity>> getAddressesForUser(int userId);

  @delete
  Future<void> deleteAddress(AddressEntity address);

  @Query('DELETE FROM addresses WHERE userId = :userId')
  Future<void> deleteAllAddressesForUser(int userId);
}
