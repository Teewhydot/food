part of 'recent_keywords_cubit.dart';

// Commented out - migrated to BaseState<List<RecentKeywordEntity>> system
// @immutable
// sealed class RecentKeywordsState {}
// 
// final class RecentKeywordsInitial extends RecentKeywordsState {}
// 
// final class RecentKeywordsLoading extends RecentKeywordsState {}
// 
// final class RecentKeywordsLoaded extends RecentKeywordsState {
//   final List<RecentKeywordEntity> keywords;
// 
//   RecentKeywordsLoaded(this.keywords);
// }
// 
// final class RecentKeywordsAdded extends RecentKeywordsState {
//   final RecentKeywordEntity keyword;
// 
//   RecentKeywordsAdded(this.keyword);
// }
// 
// final class RecentKeywordsCleared extends RecentKeywordsState {
//   final String message;
// 
//   RecentKeywordsCleared(this.message);
// }
// 
// final class RecentKeywordsDeleted extends RecentKeywordsState {}
// 
// final class RecentKeywordsError extends RecentKeywordsState
//     implements AppErrorState {
//   @override
//   final String errorMessage;
// 
//   RecentKeywordsError(this.errorMessage);
// }
