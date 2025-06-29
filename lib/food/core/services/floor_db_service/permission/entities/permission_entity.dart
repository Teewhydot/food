import 'package:floor/floor.dart';

/// Entity to represent permission state in the database
@entity
class PermissionEntity {
  @primaryKey
  final String permissionName;
  final bool isGranted;
  final String lastUpdated;

  PermissionEntity({
    required this.permissionName,
    required this.isGranted,
    required this.lastUpdated,
  });
}
