import 'package:food/food/core/services/floor_db_service/app_database.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:food/food/core/services/platform_database_path_service.dart';

class PermissionDatabaseService {
  static final PermissionDatabaseService _instance =
      PermissionDatabaseService._internal();
  // path provider p
  AppDatabase? _database;
  factory PermissionDatabaseService() => _instance;
  PermissionDatabaseService._internal();

  Future<AppDatabase> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<AppDatabase> _initDatabase() async {
    final String dbPath;
    if (kIsWeb) {
      dbPath = PlatformDatabasePathService.getDbPath('granted_permissions.db');
    } else {
      final documentsDir = await getApplicationDocumentsDirectory();
      dbPath = p.join(documentsDir.path, 'granted_permissions.db');
    }
    return await $FloorAppDatabase.databaseBuilder(dbPath).build();
  }
}
