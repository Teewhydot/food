import 'dart:async';
import 'package:meta/meta.dart';

import '../base/base_state.dart';
import '../../../core/utils/logger.dart';

/// Pagination information
@immutable
class PaginationInfo {
  final int currentPage;
  final int pageSize;
  final int? totalItems;
  final int? totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final bool isLoadingNextPage;

  const PaginationInfo({
    required this.currentPage,
    required this.pageSize,
    this.totalItems,
    this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.isLoadingNextPage = false,
  });

  PaginationInfo copyWith({
    int? currentPage,
    int? pageSize,
    int? totalItems,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
    bool? isLoadingNextPage,
  }) {
    return PaginationInfo(
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
    );
  }

  @override
  String toString() => 'PaginationInfo(page: $currentPage, size: $pageSize, hasNext: $hasNextPage)';
}

/// Mixin that provides pagination functionality to BLoCs/Cubits
/// Handles loading more data, page management, and pagination state
mixin PaginationBlocMixin<T, State extends BaseState> {
  /// Current pagination information
  PaginationInfo? _paginationInfo;
  
  /// Whether pagination is enabled
  bool get paginationEnabled => true;

  /// Default page size
  int get defaultPageSize => 20;

  /// Whether to reset pagination on refresh
  bool get resetPaginationOnRefresh => true;

  /// Current pagination info
  PaginationInfo? get paginationInfo => _paginationInfo;

  /// Whether there are more pages to load
  bool get hasNextPage => _paginationInfo?.hasNextPage ?? false;

  /// Whether currently loading next page
  bool get isLoadingNextPage => _paginationInfo?.isLoadingNextPage ?? false;

  /// Current page number (1-based)
  int get currentPage => _paginationInfo?.currentPage ?? 1;

  /// Initialize pagination
  @protected
  void initializePagination({int? pageSize}) {
    _paginationInfo = PaginationInfo(
      currentPage: 1,
      pageSize: pageSize ?? defaultPageSize,
      hasNextPage: true,
      hasPreviousPage: false,
    );
    Logger.logBasic('Pagination initialized with page size: ${_paginationInfo!.pageSize}');
  }

  /// Load next page of data
  @protected
  Future<void> loadNextPage() async {
    if (!paginationEnabled || !hasNextPage || isLoadingNextPage) {
      Logger.logWarning('Cannot load next page - conditions not met');
      return;
    }

    _paginationInfo = _paginationInfo!.copyWith(isLoadingNextPage: true);
    
    try {
      Logger.logBasic('Loading page ${currentPage + 1}');
      
      final result = await onLoadPage(
        page: currentPage + 1,
        pageSize: _paginationInfo!.pageSize,
      );
      
      await onPageLoaded(result, currentPage + 1);
      
      Logger.logBasic('Page ${currentPage + 1} loaded successfully');
    } catch (e, stackTrace) {
      Logger.logError('Failed to load page ${currentPage + 1}: $e');
      await onPageLoadError(e, stackTrace, currentPage + 1);
    } finally {
      _paginationInfo = _paginationInfo!.copyWith(isLoadingNextPage: false);
    }
  }

  /// Load first page (or reload from beginning)
  @protected
  Future<void> loadFirstPage({int? pageSize}) async {
    if (!paginationEnabled) return;

    _paginationInfo = PaginationInfo(
      currentPage: 1,
      pageSize: pageSize ?? _paginationInfo?.pageSize ?? defaultPageSize,
      hasNextPage: true,
      hasPreviousPage: false,
    );

    try {
      Logger.logBasic('Loading first page');
      
      final result = await onLoadPage(
        page: 1,
        pageSize: _paginationInfo!.pageSize,
      );
      
      await onPageLoaded(result, 1);
      
      Logger.logBasic('First page loaded successfully');
    } catch (e, stackTrace) {
      Logger.logError('Failed to load first page: $e');
      await onPageLoadError(e, stackTrace, 1);
    }
  }

  /// Update pagination info after successful page load
  @protected
  void updatePaginationInfo({
    int? totalItems,
    int? totalPages,
    bool? hasNextPage,
    int? loadedPage,
  }) {
    if (_paginationInfo == null) return;

    final currentPageNum = loadedPage ?? _paginationInfo!.currentPage;
    final calculatedTotalPages = totalPages ?? 
        (totalItems != null ? (totalItems / _paginationInfo!.pageSize).ceil() : null);
    
    final calculatedHasNext = hasNextPage ?? 
        (calculatedTotalPages != null ? currentPageNum < calculatedTotalPages : true);

    _paginationInfo = _paginationInfo!.copyWith(
      currentPage: currentPageNum,
      totalItems: totalItems ?? _paginationInfo!.totalItems,
      totalPages: calculatedTotalPages,
      hasNextPage: calculatedHasNext,
      hasPreviousPage: currentPageNum > 1,
      isLoadingNextPage: false,
    );

    Logger.logBasic('Pagination updated: $_paginationInfo');
  }

  /// Reset pagination to initial state
  @protected
  void resetPagination() {
    _paginationInfo = null;
    Logger.logBasic('Pagination reset');
  }

  /// Check if we should load more data based on scroll position
  @protected
  bool shouldLoadMore(double scrollPosition, double maxScrollExtent) {
    if (!hasNextPage || isLoadingNextPage) return false;
    
    // Load more when user is 80% through the current content
    const threshold = 0.8;
    return scrollPosition >= maxScrollExtent * threshold;
  }

  /// Override this method to implement page loading logic
  @protected
  Future<PaginatedResult<T>> onLoadPage({
    required int page,
    required int pageSize,
  });

  /// Called when a page is successfully loaded
  @protected
  Future<void> onPageLoaded(PaginatedResult<T> result, int pageNumber);

  /// Called when page loading fails
  @protected
  Future<void> onPageLoadError(Object error, StackTrace stackTrace, int pageNumber) async {
    // Default implementation - subclasses can override
    Logger.logError('Page $pageNumber load failed: $error');
  }
}

/// Result from paginated API calls
@immutable
class PaginatedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int? totalItems;
  final int? totalPages;
  final bool hasNextPage;

  const PaginatedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    this.totalItems,
    this.totalPages,
    required this.hasNextPage,
  });

  @override
  String toString() => 
      'PaginatedResult(items: ${items.length}, page: $page, hasNext: $hasNextPage)';
}