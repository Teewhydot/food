import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/bloc/mixins/cacheable_bloc_mixin.dart';

// Test implementation of CacheableBlocMixin
class TestCacheableCubit extends Cubit<BaseState<String>> with CacheableBlocMixin<String> {
  TestCacheableCubit() : super(const InitialState<String>());

  @override
  String get cacheKey => 'test_cache_key';

  @override
  Duration get cacheDuration => const Duration(minutes: 5);

  Future<String> fetchData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 'Fresh Data ${DateTime.now().millisecondsSinceEpoch}';
  }

  void loadDataWithCache() async {
    emit(const LoadingState<String>());
    
    try {
      final data = await loadWithCache(
        fetchData: fetchData,
        fallbackData: () => 'Fallback Data',
      );
      
      emit(LoadedState<String>(data, isFromCache: await hasValidCache()));
    } catch (e) {
      emit(ErrorState<String>(e.toString()));
    }
  }

  void loadDataForcingRefresh() async {
    emit(const LoadingState<String>());
    
    try {
      final data = await loadWithCache(
        fetchData: fetchData,
        forceRefresh: true,
      );
      
      emit(LoadedState<String>(data, isFromCache: false));
    } catch (e) {
      emit(ErrorState<String>(e.toString()));
    }
  }

  void clearTestCache() async {
    await clearCache();
  }
}

void main() {
  group('CacheableBlocMixin Tests', () {
    late TestCacheableCubit cubit;

    setUp(() {
      cubit = TestCacheableCubit();
    });

    tearDown(() {
      cubit.close();
    });

    group('Cache Operations', () {
      test('should cache data correctly', () async {
        // First load - should fetch fresh data
        cubit.loadDataWithCache();
        await Future.delayed(const Duration(milliseconds: 200));
        
        final firstState = cubit.state;
        expect(firstState, isA<LoadedState<String>>());
        expect((firstState as LoadedState<String>).isFromCache, false);
        
        // Second load - should use cached data
        cubit.loadDataWithCache();
        await Future.delayed(const Duration(milliseconds: 200));
        
        final secondState = cubit.state;
        expect(secondState, isA<LoadedState<String>>());
        expect((secondState as LoadedState<String>).isFromCache, true);
        expect(secondState.data, equals(firstState.data));
      });

      test('should force refresh when requested', () async {
        // First load
        cubit.loadDataWithCache();
        await Future.delayed(const Duration(milliseconds: 200));
        final firstData = (cubit.state as LoadedState<String>).data;
        
        // Force refresh
        cubit.loadDataForcingRefresh();
        await Future.delayed(const Duration(milliseconds: 200));
        final secondData = (cubit.state as LoadedState<String>).data;
        
        expect(firstData, isNot(equals(secondData)));
        expect((cubit.state as LoadedState<String>).isFromCache, false);
      });

      test('should handle cache expiration', () async {
        // Create a cubit with very short cache duration
        final shortCacheCubit = TestShortCacheCubit();
        
        // First load
        shortCacheCubit.loadDataWithCache();
        await Future.delayed(const Duration(milliseconds: 200));
        final firstData = (shortCacheCubit.state as LoadedState<String>).data;
        
        // Wait for cache to expire
        await Future.delayed(const Duration(milliseconds: 150));
        
        // Second load should fetch fresh data
        shortCacheCubit.loadDataWithCache();
        await Future.delayed(const Duration(milliseconds: 200));
        final secondData = (shortCacheCubit.state as LoadedState<String>).data;
        
        expect(firstData, isNot(equals(secondData)));
        expect((shortCacheCubit.state as LoadedState<String>).isFromCache, false);
        
        shortCacheCubit.close();
      });

      test('should clear cache correctly', () async {
        // Load data first
        cubit.loadDataWithCache();
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Verify cache exists
        expect(await cubit.hasValidCache(), true);
        
        // Clear cache
        await cubit.clearTestCache();
        
        // Verify cache is cleared
        expect(await cubit.hasValidCache(), false);
      });

      test('should use fallback data when fetch fails', () async {
        final failingCubit = TestFailingCacheableCubit();
        
        failingCubit.loadDataWithFallback();
        await Future.delayed(const Duration(milliseconds: 200));
        
        final state = failingCubit.state;
        expect(state, isA<LoadedState<String>>());
        expect((state as LoadedState<String>).data, 'Fallback Data');
        
        failingCubit.close();
      });

      test('should handle cache key generation', () {
        expect(cubit.cacheKey, 'test_cache_key');
        expect(cubit.cacheDuration, const Duration(minutes: 5));
      });

      test('should validate cache correctly', () async {
        // No cache initially
        expect(await cubit.hasValidCache(), false);
        
        // Load data to create cache
        cubit.loadDataWithCache();
        await Future.delayed(const Duration(milliseconds: 200));
        
        // Should have valid cache now
        expect(await cubit.hasValidCache(), true);
      });
    });

    group('Cache States', () {
      test('should emit correct states during cache flow', () async {
        final states = <BaseState<String>>[];
        final subscription = cubit.stream.listen(states.add);
        
        cubit.loadDataWithCache();
        await Future.delayed(const Duration(milliseconds: 200));
        
        expect(states.length, 2);
        expect(states[0], isA<LoadingState<String>>());
        expect(states[1], isA<LoadedState<String>>());
        expect((states[1] as LoadedState<String>).isFromCache, false);
        
        // Load again to test cache
        states.clear();
        cubit.loadDataWithCache();
        await Future.delayed(const Duration(milliseconds: 200));
        
        expect(states.length, 2);
        expect(states[0], isA<LoadingState<String>>());
        expect(states[1], isA<LoadedState<String>>());
        expect((states[1] as LoadedState<String>).isFromCache, true);
        
        subscription.cancel();
      });
    });

    group('Error Handling', () {
      test('should handle fetch errors gracefully', () async {
        final failingCubit = TestFailingCacheableCubit();
        
        failingCubit.loadDataWithoutFallback();
        await Future.delayed(const Duration(milliseconds: 200));
        
        expect(failingCubit.state, isA<ErrorState<String>>());
        expect((failingCubit.state as ErrorState<String>).errorMessage, 
               contains('Fetch failed'));
        
        failingCubit.close();
      });
    });
  });
}

// Test cubit with short cache duration
class TestShortCacheCubit extends Cubit<BaseState<String>> with CacheableBlocMixin<String> {
  TestShortCacheCubit() : super(const InitialState<String>());

  @override
  String get cacheKey => 'short_cache_key';

  @override
  Duration get cacheDuration => const Duration(milliseconds: 100);

  Future<String> fetchData() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return 'Data ${DateTime.now().millisecondsSinceEpoch}';
  }

  void loadDataWithCache() async {
    emit(const LoadingState<String>());
    
    try {
      final data = await loadWithCache(fetchData: fetchData);
      emit(LoadedState<String>(data, isFromCache: await hasValidCache()));
    } catch (e) {
      emit(ErrorState<String>(e.toString()));
    }
  }
}

// Test cubit that fails to fetch data
class TestFailingCacheableCubit extends Cubit<BaseState<String>> with CacheableBlocMixin<String> {
  TestFailingCacheableCubit() : super(const InitialState<String>());

  @override
  String get cacheKey => 'failing_cache_key';

  @override
  Duration get cacheDuration => const Duration(minutes: 5);

  Future<String> fetchData() async {
    await Future.delayed(const Duration(milliseconds: 50));
    throw Exception('Fetch failed');
  }

  void loadDataWithFallback() async {
    emit(const LoadingState<String>());
    
    try {
      final data = await loadWithCache(
        fetchData: fetchData,
        fallbackData: () => 'Fallback Data',
      );
      emit(LoadedState<String>(data));
    } catch (e) {
      emit(ErrorState<String>(e.toString()));
    }
  }

  void loadDataWithoutFallback() async {
    emit(const LoadingState<String>());
    
    try {
      final data = await loadWithCache(fetchData: fetchData);
      emit(LoadedState<String>(data));
    } catch (e) {
      emit(ErrorState<String>(e.toString()));
    }
  }
}