import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';

// Very basic test to verify state management works
class BasicCubit extends Cubit<BaseState<String>> {
  BasicCubit() : super(const InitialState<String>());

  void loadData() => emit(const LoadedState<String>(data: 'Test Data'));
  void loadError() => emit(const ErrorState<String>(errorMessage: 'Test Error'));
  void loadEmpty() => emit(const EmptyState<String>());
}

void main() {
  group('Basic Functionality Tests', () {
    test('should create and emit states correctly', () async {
      final cubit = BasicCubit();
      final states = <BaseState<String>>[];
      
      // Listen to state changes
      final subscription = cubit.stream.listen(states.add);
      
      // Test initial state
      expect(cubit.state, isA<InitialState<String>>());
      expect(cubit.state.isLoading, false);
      expect(cubit.state.isError, false);
      expect(cubit.state.hasData, false);
      
      // Test loaded state
      cubit.loadData();
      await Future.delayed(const Duration(milliseconds: 10));
      
      expect(cubit.state, isA<LoadedState<String>>());
      expect(cubit.state.hasData, true);
      expect(cubit.state.data, 'Test Data');
      expect(cubit.state.isError, false);
      
      // Test error state
      cubit.loadError();
      await Future.delayed(const Duration(milliseconds: 10));
      
      expect(cubit.state, isA<ErrorState<String>>());
      expect(cubit.state.isError, true);
      expect(cubit.state.errorMessage, 'Test Error');
      expect(cubit.state.hasData, false);
      
      // Test empty state
      cubit.loadEmpty();
      await Future.delayed(const Duration(milliseconds: 10));
      
      expect(cubit.state, isA<EmptyState<String>>());
      expect(cubit.state.hasData, false);
      expect(cubit.state.isError, false);
      
      // Verify all states were emitted
      expect(states.length, 3);
      expect(states[0], isA<LoadedState<String>>());
      expect(states[1], isA<ErrorState<String>>());
      expect(states[2], isA<EmptyState<String>>());
      
      subscription.cancel();
      await cubit.close();
    });
    
    test('should handle state properties correctly', () {
      // Test state type checking
      const initialState = InitialState<String>();
      const loadingState = LoadingState<String>(message: 'Loading...');
      const loadedState = LoadedState<String>(data: 'Data');
      const errorState = ErrorState<String>(errorMessage: 'Error');
      const emptyState = EmptyState<String>();
      
      // Test property getters
      expect(initialState.isLoading, false);
      expect(loadingState.isLoading, true);
      expect(loadedState.hasData, true);
      expect(errorState.isError, true);
      expect(emptyState.hasData, false);
      
      // Test data access
      expect(loadedState.data, 'Data');
      expect(errorState.errorMessage, 'Error');
      expect(loadingState.message, 'Loading...');
      
      // Test null safety
      expect(initialState.data, null);
      expect(initialState.errorMessage, null);
      expect(emptyState.data, null);
    });
    
    test('should handle async state variants', () {
      final now = DateTime.now();
      final asyncLoadedState = AsyncLoadedState<String>(
        data: 'Async Data',
        lastUpdated: now,
        isRefreshing: false,
        isFromCache: true,
      );
      
      expect(asyncLoadedState.data, 'Async Data');
      expect(asyncLoadedState.lastUpdated, now);
      expect(asyncLoadedState.isRefreshing, false);
      expect(asyncLoadedState.isFromCache, true);
      expect(asyncLoadedState.hasData, true);
      
      final refreshingState = AsyncLoadedState<String>(
        data: 'Refreshing Data',
        lastUpdated: now,
        isRefreshing: true,
      );
      
      expect(refreshingState.isRefreshing, true);
      expect(refreshingState.hasData, true);
      expect(refreshingState.isLoading, false); // Important: not loading while refreshing
    });
    
    test('should handle success state correctly', () {
      const successState = SuccessState<String>(successMessage: 'Success!');
      
      expect(successState.isSuccess, true);
      expect(successState.successMessage, 'Success!');
      expect(successState.isError, false);
      expect(successState.isLoading, false);
    });
    
    test('should handle state equality correctly', () {
      const state1 = LoadedState<String>(data: 'Same Data');
      const state2 = LoadedState<String>(data: 'Same Data');
      const state3 = LoadedState<String>(data: 'Different Data');
      
      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });
}