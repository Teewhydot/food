import '../base/base_state.dart';

/// Utility class for state operations and transformations
class StateUtils {
  StateUtils._(); // Private constructor to prevent instantiation

  /// Combine multiple states into a single state
  /// Returns the "worst" state (Error > Loading > Success > Initial)
  static BaseState combineStates(List<BaseState> states) {
    if (states.isEmpty) return const InitialState();

    // Check for errors first
    for (final state in states) {
      if (state.isError) return state;
    }

    // Check for loading states
    for (final state in states) {
      if (state.isLoading) return state;
    }

    // Check for success states
    for (final state in states) {
      if (state.isSuccess) return state;
    }

    // Return first state if no special conditions met
    return states.first;
  }

  /// Check if all states are loaded
  static bool allStatesLoaded(List<BaseState> states) {
    return states.every((state) => state.hasData || state.isSuccess);
  }

  /// Check if any state is loading
  static bool anyStateLoading(List<BaseState> states) {
    return states.any((state) => state.isLoading);
  }

  /// Check if any state has error
  static bool anyStateHasError(List<BaseState> states) {
    return states.any((state) => state.isError);
  }

  /// Get all error messages from states
  static List<String> getAllErrorMessages(List<BaseState> states) {
    return states
        .where((state) => state.isError)
        .map((state) => state.errorMessage!)
        .toList();
  }

  /// Get all success messages from states
  static List<String> getAllSuccessMessages(List<BaseState> states) {
    return states
        .where((state) => state.isSuccess)
        .map((state) => state.successMessage!)
        .toList();
  }

  /// Transform a state to another type
  static BaseState<R> transformState<T, R>(
    BaseState<T> state,
    R Function(T data)? transformer,
  ) {
    if (state is LoadedState<T> && transformer != null && state.data != null) {
      return LoadedState<R>(
        data: transformer(state.data as T),
        lastUpdated: state.lastUpdated,
        isFromCache: state.isFromCache,
      );
    }

    if (state is AsyncLoadedState<T> && transformer != null && state.data != null) {
      return AsyncLoadedState<R>(
        data: transformer(state.data as T),
        lastUpdated: state.lastUpdated,
        isFromCache: state.isFromCache,
        isRefreshing: state.isRefreshing,
        operationId: state.operationId,
      );
    }

    // For non-data states, return equivalent state for new type
    if (state is InitialState) return InitialState<R>();
    if (state is LoadingState<T>) {
      return LoadingState<R>(
        message: state.message,
        progress: state.progress,
      );
    }
    if (state is ErrorState<T>) {
      return ErrorState<R>(
        errorMessage: state.errorMessage,
        exception: state.exception,
        stackTrace: state.stackTrace,
        errorCode: state.errorCode,
        isRetryable: state.isRetryable,
      );
    }
    if (state is SuccessState<T>) {
      return SuccessState<R>(
        successMessage: state.successMessage,
        metadata: state.metadata,
      );
    }
    if (state is EmptyState<T>) {
      return EmptyState<R>(message: state.message);
    }

    // Default fallback
    return InitialState<R>();
  }

  /// Check if state represents fresh data (not from cache)
  static bool isFreshData(BaseState state) {
    if (state is LoadedState) {
      return !state.isFromCache;
    }
    if (state is AsyncLoadedState) {
      return !state.isFromCache;
    }
    return false;
  }

  /// Check if state data is stale (older than given duration)
  static bool isDataStale(BaseState state, Duration maxAge) {
    DateTime? lastUpdated;

    if (state is LoadedState) {
      lastUpdated = state.lastUpdated;
    } else if (state is AsyncLoadedState) {
      lastUpdated = state.lastUpdated;
    }

    if (lastUpdated == null) return true;

    return DateTime.now().difference(lastUpdated) > maxAge;
  }

  /// Get the age of data in a state
  static Duration? getDataAge(BaseState state) {
    DateTime? lastUpdated;

    if (state is LoadedState) {
      lastUpdated = state.lastUpdated;
    } else if (state is AsyncLoadedState) {
      lastUpdated = state.lastUpdated;
    }

    if (lastUpdated == null) return null;

    return DateTime.now().difference(lastUpdated);
  }

  /// Create a loading state with data (for refresh scenarios)
  static AsyncLoadingState<T> createRefreshingState<T>(
    T existingData, {
    String? message,
    String? operationId,
  }) {
    return AsyncLoadingState<T>(
      data: existingData,
      message: message,
      isRefreshing: true,
      operationId: operationId,
    );
  }

  /// Create an error state with data (for scenarios where data exists but operation failed)
  static AsyncErrorState<T> createErrorWithDataState<T>(
    T existingData,
    String errorMessage, {
    Exception? exception,
    String? errorCode,
    bool isRetryable = true,
    String? operationId,
  }) {
    return AsyncErrorState<T>(
      data: existingData,
      errorMessage: errorMessage,
      exception: exception,
      errorCode: errorCode,
      isRetryable: isRetryable,
      operationId: operationId,
    );
  }

  /// Create a loaded state from data
  static LoadedState<T> createLoadedState<T>(
    T data, {
    bool isFromCache = false,
    DateTime? lastUpdated,
  }) {
    return LoadedState<T>(
      data: data,
      isFromCache: isFromCache,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// Create an async loaded state from data
  static AsyncLoadedState<T> createAsyncLoadedState<T>(
    T data, {
    bool isFromCache = false,
    DateTime? lastUpdated,
    String? operationId,
  }) {
    return AsyncLoadedState<T>(
      data: data,
      isFromCache: isFromCache,
      lastUpdated: lastUpdated ?? DateTime.now(),
      operationId: operationId,
    );
  }
}