import 'package:flutter_test/flutter_test.dart';
import 'package:food/food/core/bloc/base/base_state.dart';

void main() {
  group('BaseState Tests', () {
    group('InitialState', () {
      test('should have correct properties', () {
        const state = InitialState<String>();
        
        expect(state is InitialState, true);
        expect(state.isLoading, false);
        expect(state.isError, false);
        expect(state.isSuccess, false);
        expect(state.hasData, false);
        expect(state.data, null);
        expect(state.errorMessage, null);
        expect(state.successMessage, null);
      });
    });

    group('LoadingState', () {
      test('should have correct properties without message', () {
        const state = LoadingState<String>();
        
        expect(state is InitialState, false);
        expect(state.isLoading, true);
        expect(state.isError, false);
        expect(state.isSuccess, false);
        expect(state.hasData, false);
        expect(state.data, null);
        expect(state.message, null);
      });

      test('should have correct properties with message', () {
        const state = LoadingState<String>(message: 'Loading data...');
        
        expect(state.isLoading, true);
        expect(state.message, 'Loading data...');
      });
    });

    group('LoadedState', () {
      test('should have correct properties with data', () {
        const testData = 'Test Data';
        const state = LoadedState<String>(data: testData);
        
        expect(state is InitialState, false);
        expect(state.isLoading, false);
        expect(state.isError, false);
        expect(state.isSuccess, false); // LoadedState is not SuccessState
        expect(state.hasData, true);
        expect(state.data, testData);
        expect(state.successMessage, null);
        expect(state.isFromCache, false);
      });

      test('should handle cache flag correctly', () {
        const state = LoadedState<String>(data: 'Test', isFromCache: true);
        
        expect(state.isFromCache, true);
        expect(state.hasData, true);
      });

      test('should handle lastUpdated correctly', () {
        final now = DateTime.now();
        final state = LoadedState<String>(
          data: 'Test',
          lastUpdated: now,
        );
        
        expect(state.lastUpdated, now);
      });
    });

    group('ErrorState', () {
      test('should have correct properties', () {
        const state = ErrorState<String>(errorMessage: 'Network error occurred');
        
        expect(state is InitialState, false);
        expect(state.isLoading, false);
        expect(state.isError, true);
        expect(state.isSuccess, false);
        expect(state.hasData, false);
        expect(state.data, null);
        expect(state.errorMessage, 'Network error occurred');
        expect(state.isRetryable, true);
      });

      test('should handle retry flag correctly', () {
        const state = ErrorState<String>(
          errorMessage: 'Error',
          isRetryable: false,
        );
        
        expect(state.isRetryable, false);
      });

      test('should handle error code correctly', () {
        const state = ErrorState<String>(
          errorMessage: 'Error',
          errorCode: 'NETWORK_ERROR',
        );
        
        expect(state.errorCode, 'NETWORK_ERROR');
      });
    });

    group('EmptyState', () {
      test('should have correct properties', () {
        const state = EmptyState<String>();
        
        expect(state is InitialState, false);
        expect(state.isLoading, false);
        expect(state.isError, false);
        expect(state.isSuccess, false); // EmptyState is not SuccessState
        expect(state.hasData, false);
        expect(state.data, null);
        expect(state.message, null);
      });

      test('should handle message correctly', () {
        const state = EmptyState<String>(message: 'No data available');
        
        expect(state.message, 'No data available');
      });
    });

    group('State Transitions', () {
      test('should transition from Initial to Loading to Loaded', () {
        final states = <BaseState<String>>[];
        
        states.add(const InitialState<String>());
        expect(states.last is InitialState, true);
        
        states.add(const LoadingState<String>());
        expect(states.last.isLoading, true);
        
        states.add(const LoadedState<String>(data: 'Success'));
        expect(states.last.hasData, true);
        expect(states.last.data, 'Success');
      });

      test('should handle error recovery flow', () {
        final states = <BaseState<String>>[];
        
        states.add(const ErrorState<String>(errorMessage: 'Network error'));
        expect(states.last.isError, true);
        
        states.add(const LoadingState<String>(message: 'Retrying...'));
        expect(states.last.isLoading, true);
        
        states.add(const LoadedState<String>(data: 'Success after retry'));
        expect(states.last.hasData, true);
      });
    });

    group('State Equality', () {
      test('should consider identical states as equal', () {
        const state1 = LoadedState<String>(data: 'Test');
        const state2 = LoadedState<String>(data: 'Test');
        
        expect(state1, equals(state2));
      });

      test('should consider different states as not equal', () {
        const state1 = LoadedState<String>(data: 'Test1');
        const state2 = LoadedState<String>(data: 'Test2');
        
        expect(state1, isNot(equals(state2)));
      });

      test('should consider different state types as not equal', () {
        const state1 = LoadingState<String>();
        const state2 = InitialState<String>();
        
        expect(state1, isNot(equals(state2)));
      });
    });
  });

  group('DataState Tests', () {
    group('AsyncLoadedState', () {
      test('should have correct properties', () {
        final now = DateTime.now();
        final state = AsyncLoadedState<String>(
          data: 'Test Data',
          lastUpdated: now,
          isRefreshing: false,
        );
        
        expect(state.data, 'Test Data');
        expect(state.lastUpdated, now);
        expect(state.isRefreshing, false);
        expect(state.isFromCache, false);
      });

      test('should handle cache flag correctly', () {
        final state = AsyncLoadedState<String>(
          data: 'Test Data',
          lastUpdated: DateTime.now(),
          isFromCache: true,
        );
        
        expect(state.isFromCache, true);
      });

      test('should handle refreshing state correctly', () {
        final state = AsyncLoadedState<String>(
          data: 'Test Data',
          lastUpdated: DateTime.now(),
          isRefreshing: true,
        );
        
        expect(state.isRefreshing, true);
        expect(state.hasData, true);
        expect(state.isLoading, false); // Important: not loading while refreshing
      });
    });
  });

  group('State Pattern Matching', () {
    test('should match states correctly using type checking', () {
      String matchState(BaseState<String> state) {
        if (state is InitialState<String>) return 'initial';
        if (state is LoadingState<String>) return 'loading';
        if (state is LoadedState<String>) return 'loaded';
        if (state is ErrorState<String>) return 'error';
        if (state is EmptyState<String>) return 'empty';
        return 'unknown';
      }

      expect(matchState(const InitialState<String>()), 'initial');
      expect(matchState(const LoadingState<String>()), 'loading');
      expect(matchState(const LoadedState<String>(data: 'data')), 'loaded');
      expect(matchState(const ErrorState<String>(errorMessage: 'error')), 'error');
      expect(matchState(const EmptyState<String>()), 'empty');
    });

    test('should access state-specific properties safely', () {
      const BaseState<String> state = LoadedState<String>(
        data: 'Test',
        isFromCache: true,
      );

      if (state is LoadedState<String>) {
        expect(state.isFromCache, true);
        expect(state.data, 'Test');
      } else {
        fail('State should be LoadedState');
      }
    });
  });
}