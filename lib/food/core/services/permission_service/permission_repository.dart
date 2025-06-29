import 'package:permission_handler/permission_handler.dart';

import '../../utils/logger.dart';
import '../floor_db_service/permission/entities/permission_entity.dart';
import '../floor_db_service/user_profile/user_profile_database_service.dart';

/// A repository to handle permission persistence
class PermissionRepository {
  static final PermissionRepository _instance =
      PermissionRepository._internal();
  factory PermissionRepository() => _instance;
  PermissionRepository._internal();
  final db = UserProfileDatabaseService();

  /// Get permission status from database
  Future<bool?> getPermissionStatus(Permission permission) async {
    try {
      final permissionEntity = await (await db.database).permissionDao
          .getPermissionByName(permission.toString());

      return permissionEntity?.isGranted;
    } catch (e) {
      Logger.logError('Error getting permission status: $e');
      return null;
    }
  }

  /// Save permission status to database
  Future<bool> savePermissionStatus(
    Permission permission,
    bool isGranted,
  ) async {
    try {
      final permissionEntity = PermissionEntity(
        permissionName: permission.toString(),
        isGranted: isGranted,
        lastUpdated: DateTime.now().toIso8601String(),
      );

      final existingPermission = await (await db.database).permissionDao
          .getPermissionByName(permission.toString());

      if (existingPermission != null) {
        await (await db.database).permissionDao.updatePermission(
          permissionEntity,
        );
      } else {
        await (await db.database).permissionDao.insertPermission(
          permissionEntity,
        );
      }

      Logger.logSuccess(
        'Permission status saved: ${permission.toString()} - $isGranted',
      );
      return true;
    } catch (e) {
      Logger.logError('Error saving permission status: $e');
      return false;
    }
  }

  /// Get all saved permissions
  Future<List<PermissionEntity>> getAllPermissions() async {
    try {
      return await (await db.database).permissionDao.getAllPermissions();
    } catch (e) {
      Logger.logError('Error getting all permissions: $e');
      return [];
    }
  }
}
