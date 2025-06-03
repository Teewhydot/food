import 'package:bloc/bloc.dart';
import 'package:food/food/features/home/domain/entities/recent_keyword.dart';
import 'package:meta/meta.dart';

import '../../../../core/services/floor_db_service/recent_keywords/recent_keywords_database_service.dart';

part 'recent_keywords_state.dart';

class RecentKeywordsCubit extends Cubit<RecentKeywordsState> {
  RecentKeywordsCubit() : super(RecentKeywordsInitial());

  final db = RecentKeywordsDatabaseService();
  void addKeyword(String keyword) async {
    emit(RecentKeywordsLoading());
    try {
      final recentKeyword = RecentKeyword(keyword);
      await (await db.database).recentsKeywordsDao.insertKeyword(recentKeyword);
      emit(RecentKeywordsAdded(recentKeyword));
      loadRecentKeywords();
    } catch (e) {
      emit(RecentKeywordsError(e.toString()));
    }
  }

  void loadRecentKeywords() async {
    emit(RecentKeywordsLoading());
    try {
      final keywords =
          await (await db.database).recentsKeywordsDao.getAllRecentKeywords();
      emit(RecentKeywordsLoaded(keywords));
    } catch (e) {
      emit(RecentKeywordsError(e.toString()));
    }
  }

  void clearKeywords() async {
    emit(RecentKeywordsLoading());
    try {
      await (await db.database).recentsKeywordsDao.clearRecentKeywords();
      emit(RecentKeywordsCleared("All recent keywords cleared successfully"));
    } catch (e) {
      emit(RecentKeywordsError(e.toString()));
    }
  }
}
