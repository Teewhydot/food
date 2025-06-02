import 'package:floor/floor.dart';
import 'package:food/food/core/services/floor_db_service/constants.dart';

import '../../../../features/home/domain/entities/recent_keyword.dart';

@dao
abstract class RecentKeywordsDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertKeyword(RecentKeyword keyword);

  @delete
  Future<void> deleteKeyword(RecentKeyword keyword);

  @Query('SELECT * FROM ${FloorDbConstants.keywordTableName}')
  Future<List<RecentKeyword>> getAllRecentKeywords();

  @Query('DELETE FROM ${FloorDbConstants.keywordTableName}')
  Future<void> clearRecentKeywords();
}
