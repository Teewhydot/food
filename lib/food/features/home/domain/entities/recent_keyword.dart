import 'package:floor/floor.dart';

import '../../../../core/services/floor_db_service/constants.dart';

@Entity(tableName: FloorDbConstants.keywordTableName)
class RecentKeyword {
  @primaryKey
  final String keyword;

  RecentKeyword(this.keyword);
}
