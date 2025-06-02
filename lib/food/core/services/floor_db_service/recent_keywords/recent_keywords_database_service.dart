import 'package:food/food/core/services/floor_db_service/recent_keywords/recent_keywords_database.dart';
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
}
