import 'package:floor/floor.dart';
import 'package:food/food/core/services/floor_db_service/constants.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';

@dao
abstract class UserProfileDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> saveUserProfile(UserProfileEntity userProfile);

  @Update(onConflict: OnConflictStrategy.replace)
  Future<void> updateUserProfile(UserProfileEntity userProfile);

  @Query('SELECT * FROM ${FloorDbConstants.userProfileTableName}')
  Future<List<UserProfileEntity>> getUserProfile();

  @Query('DELETE FROM ${FloorDbConstants.userProfileTableName}')
  Future<void> deleteUserProfile();
}
