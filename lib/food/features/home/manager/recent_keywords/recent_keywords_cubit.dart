import 'package:food/food/core/bloc/base/base_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/features/home/domain/entities/recent_keyword.dart';

import '../../../../core/services/floor_db_service/recent_keywords/recent_keywords_database_service.dart';

// part 'recent_keywords_state.dart'; // Commented out - using BaseState now

/// Migrated RecentKeywordsCubit to use BaseState<dynamic>
class RecentKeywordsCubit extends BaseCubit<BaseState<dynamic>> {
  RecentKeywordsCubit() : super(const InitialState<dynamic>());

  final db = RecentKeywordsDatabaseService();
  void addKeyword(String keyword) async {
    emit(const LoadingState<RecentKeywordEntity>(message: 'Adding keyword...'));
    try {
      final recentKeyword = RecentKeywordEntity(keyword);
      await (await db.database).recentsKeywordsDao.insertKeyword(recentKeyword);
      
      // Emit success notification
      emit(
        SuccessState<RecentKeywordEntity>(
          successMessage: 'Keyword "$keyword" added successfully',
        ),
      );
      
      // Reload keywords to get updated list
      loadRecentKeywords();
    } catch (e) {
      emit(
        ErrorState<RecentKeywordEntity>(
          errorMessage: e.toString(),
          errorCode: 'add_keyword_failed',
          isRetryable: true,
        ),
      );
    }
  }

  void loadRecentKeywords() async {
    emit(const LoadingState<List<RecentKeywordEntity>>(message: 'Loading recent keywords...'));
    try {
      final keywords =
          await (await db.database).recentsKeywordsDao.getAllRecentKeywords();
      
      if (keywords.isEmpty) {
        emit(const EmptyState<List<RecentKeywordEntity>>(message: 'No recent keywords'));
      } else {
        emit(
          LoadedState<List<RecentKeywordEntity>>(
            data: keywords,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      emit(
        ErrorState<List<RecentKeywordEntity>>(
          errorMessage: e.toString(),
          errorCode: 'load_keywords_failed',
          isRetryable: true,
        ),
      );
    }
  }

  void clearKeywords() async {
    emit(const LoadingState<void>(message: 'Clearing keywords...'));
    try {
      await (await db.database).recentsKeywordsDao.clearRecentKeywords();
      
      // Emit success notification
      emit(
        const SuccessState<void>(
          successMessage: 'All recent keywords cleared successfully',
        ),
      );
      
      // Reset to empty state
      emit(const EmptyState<List<RecentKeywordEntity>>(message: 'No recent keywords'));
    } catch (e) {
      emit(
        ErrorState<void>(
          errorMessage: e.toString(),
          errorCode: 'clear_keywords_failed',
          isRetryable: true,
        ),
      );
    }
  }
}
