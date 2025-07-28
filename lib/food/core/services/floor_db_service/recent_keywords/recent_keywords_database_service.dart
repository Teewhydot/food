import 'package:food/food/core/services/floor_db_service/app_database.dart';
import 'package:food/food/features/home/domain/entities/recent_keyword.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class RecentKeywordsDatabaseService {
  static final RecentKeywordsDatabaseService _instance =
      RecentKeywordsDatabaseService._internal();
  // path provider p
  AppDatabase? _database;
  factory RecentKeywordsDatabaseService() => _instance;
  RecentKeywordsDatabaseService._internal();

  Future<AppDatabase> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<AppDatabase> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDir.path, 'recents_database.db');
    return await $FloorAppDatabase.databaseBuilder(dbPath).build();
  }

  Future<void> insertKeyword(RecentKeywordEntity keyword) async {
    final db = await database;
    await db.recentsKeywordsDao.insertKeyword(keyword);
  }

  Future<void> deleteKeyword(RecentKeywordEntity keyword) async {
    final db = await database;
    await db.recentsKeywordsDao.deleteKeyword(keyword);
  }

  Future<List<RecentKeywordEntity>> getAllRecentKeywords() async {
    final db = await database;
    return await db.recentsKeywordsDao.getAllRecentKeywords();
  }

  Future<void> clearRecentKeywords() async {
    final db = await database;
    await db.recentsKeywordsDao.clearRecentKeywords();
  }
}
