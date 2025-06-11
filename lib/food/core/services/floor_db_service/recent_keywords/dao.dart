import 'package:floor/floor.dart';
import 'package:food/food/core/services/floor_db_service/constants.dart';

import '../../../../features/home/domain/entities/recent_keyword.dart';

@dao
abstract class RecentKeywordsDao {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertKeyword(RecentKeywordEntity keyword);

  @delete
  Future<void> deleteKeyword(RecentKeywordEntity keyword);

  @Query('SELECT * FROM ${FloorDbConstants.keywordTableName}')
  Future<List<RecentKeywordEntity>> getAllRecentKeywords();

  @Query('DELETE FROM ${FloorDbConstants.keywordTableName}')
  Future<void> clearRecentKeywords();
}
