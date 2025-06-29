import 'package:floor/floor.dart';

import 'entities/permission_entity.dart';

/// DAO for permission operations
@dao
abstract class PermissionDao {
  @Query('SELECT * FROM PermissionEntity WHERE permissionName = :name')
  Future<PermissionEntity?> getPermissionByName(String name);

  @Query('SELECT * FROM PermissionEntity')
  Future<List<PermissionEntity>> getAllPermissions();

  @insert
  Future<void> insertPermission(PermissionEntity permission);

  @update
  Future<void> updatePermission(PermissionEntity permission);

  @Query('DELETE FROM PermissionEntity WHERE permissionName = :name')
  Future<void> deletePermission(String name);
}
