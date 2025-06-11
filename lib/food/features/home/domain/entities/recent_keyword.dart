import 'package:floor/floor.dart';

import '../../../../core/services/floor_db_service/constants.dart';

@Entity(tableName: FloorDbConstants.keywordTableName)
class RecentKeywordEntity {
  @primaryKey
  final String keyword;

  RecentKeywordEntity(this.keyword);
}
