import '../base/base_state.dart';

/// Helper class to assist with migration from old state classes to BaseState
class MigrationHelper {
  /// Convert common state patterns to BaseState
  static BaseState<T> convertToBaseState<T>({
    required dynamic oldState,
    T? data,
  }) {
    final stateName = oldState.runtimeType.toString().toLowerCase();

    if (stateName.contains('initial')) {
      return InitialState<T>();
    } else if (stateName.contains('loading')) {
      return LoadingState<T>(
        message: _extractMessage(oldState),
      );
    } else if (stateName.contains('loaded') || stateName.contains('success')) {
      if (data != null) {
        return LoadedState<T>(
          data: data,
          lastUpdated: DateTime.now(),
        );
      } else {
        return SuccessState<T>(
          successMessage: _extractMessage(oldState) ?? 'Operation successful',
        );
      }
    } else if (stateName.contains('error') || stateName.contains('failure')) {
      return ErrorState<T>(
        errorMessage: _extractMessage(oldState) ?? 'An error occurred',
        isRetryable: true,
      );
    } else if (stateName.contains('empty')) {
      return EmptyState<T>(
        message: _extractMessage(oldState),
      );
    }

    // Default to initial state if pattern not recognized
    return InitialState<T>();
  }

  /// Extract message from old state if available
  static String? _extractMessage(dynamic state) {
    try {
      // Try common property names
      if (_hasProperty(state, 'message')) {
        return state.message;
      }
      if (_hasProperty(state, 'errorMessage')) {
        return state.errorMessage;
      }
      if (_hasProperty(state, 'successMessage')) {
        return state.successMessage;
      }
    } catch (_) {
      // Ignore if property doesn't exist
    }
    return null;
  }

  /// Check if object has a property
  static bool _hasProperty(dynamic object, String propertyName) {
    try {
      final mirror = object.runtimeType.toString();
      return mirror.contains(propertyName);
    } catch (_) {
      return false;
    }
  }

  /// Map event handler patterns
  static void mapEventHandlerPattern({
    required String oldPattern,
    required String newPattern,
  }) {
    // This is a documentation helper for migration patterns
    print('Migration Pattern: $oldPattern -> $newPattern');
  }

  /// Common migration patterns documentation
  static const migrationPatterns = '''
  Common Migration Patterns:
  
  1. State Classes:
     - FoodInitial -> InitialState<FoodEntity>
     - FoodLoading -> LoadingState<FoodEntity>
     - FoodLoaded(food) -> LoadedState<FoodEntity>(data: food)
     - FoodsLoaded(foods) -> LoadedState<List<FoodEntity>>(data: foods)
     - FoodError(msg) -> ErrorState<FoodEntity>(errorMessage: msg)
     
  2. BLoC Event Handlers:
     Old:
     ```dart
     emit(FoodLoading());
     final result = await useCase.getData();
     result.fold(
       (failure) => emit(FoodError(failure.message)),
       (data) => emit(FoodLoaded(data)),
     );
     ```
     
     New:
     ```dart
     emit(LoadingState<FoodEntity>());
     final result = await useCase.getData();
     result.fold(
       (failure) => emit(ErrorState<FoodEntity>(
         errorMessage: failure.message,
         isRetryable: true,
       )),
       (data) => emit(LoadedState<FoodEntity>(
         data: data,
         lastUpdated: DateTime.now(),
       )),
     );
     ```
     
  3. Screen Implementation:
     Old:
     ```dart
     BlocManager<FoodBloc, FoodState>(
       bloc: foodBloc,
       builder: (context, state) {
         if (state is FoodLoading) return LoadingWidget();
         if (state is FoodLoaded) return ContentWidget(state.food);
         if (state is FoodError) return ErrorWidget(state.message);
         return Container();
       },
     )
     ```
     
     New:
     ```dart
     SimplifiedEnhancedBlocManager<FoodBloc, BaseState<FoodEntity>>(
       bloc: foodBloc,
       showLoadingIndicator: true,
       builder: (context, state) {
         if (state.hasData) {
           return ContentWidget(state.data!);
         } else if (state is EmptyState) {
           return EmptyWidget();
         }
         return Container();
       },
       onError: (context, state) {
         // Error handling
       },
     )
     ```
  ''';
}

/// Extension to help with state type checking during migration
extension StateTypeChecking on dynamic {
  bool get isInitialState => runtimeType.toString().contains('Initial');
  bool get isLoadingState => runtimeType.toString().contains('Loading');
  bool get isLoadedState => runtimeType.toString().contains('Loaded');
  bool get isErrorState => runtimeType.toString().contains('Error') || 
                           runtimeType.toString().contains('Failure');
  bool get isSuccessState => runtimeType.toString().contains('Success');
}