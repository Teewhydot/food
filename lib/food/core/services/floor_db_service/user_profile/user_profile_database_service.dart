import 'package:food/food/core/services/floor_db_service/app_database.dart';
import 'package:food/food/features/home/domain/entities/profile.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:food/food/core/services/platform_database_path_service.dart';

class UserProfileDatabaseService {
  static final UserProfileDatabaseService _instance =
      UserProfileDatabaseService._internal();
  // path provider p
  AppDatabase? _database;
  factory UserProfileDatabaseService() => _instance;
  UserProfileDatabaseService._internal();

  Future<AppDatabase> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<AppDatabase> _initDatabase() async {
    final String dbPath;
    if (kIsWeb) {
      dbPath = PlatformDatabasePathService.getDbPath('user_profile.db');
    } else {
      final documentsDir = await getApplicationDocumentsDirectory();
      dbPath = p.join(documentsDir.path, 'user_profile.db');
    }
    return await $FloorAppDatabase.databaseBuilder(dbPath).build();
  }

  Future<void> insertUserProfile(UserProfileEntity userProfile) async {
    final db = await database;
    await db.userProfileDao.saveUserProfile(userProfile);
  }

  Future<UserProfileEntity?> getUserProfile() async {
    final db = await database;
    final profiles = await db.userProfileDao.getUserProfile();
    return profiles.isNotEmpty ? profiles.first : null;
  }

  Future<void> updateUserProfile(UserProfileEntity userProfile) async {
    final db = await database;
    await db.userProfileDao.updateUserProfile(userProfile);
  }

  Future<void> deleteUserProfile() async {
    final db = await database;
    await db.userProfileDao.deleteUserProfile();
  }
}
