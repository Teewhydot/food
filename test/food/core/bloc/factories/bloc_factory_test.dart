import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food/food/core/bloc/base/base_state.dart';
import 'package:food/food/core/bloc/factories/bloc_factory.dart';

// Test BLoC for factory testing
class TestBloc extends Cubit<BaseState<String>> {
  TestBloc() : super(const InitialState<String>());

  void loadData() {
    emit(const LoadingState<String>());
    Future.delayed(const Duration(milliseconds: 50), () {
      emit(const LoadedState<String>('Test Data'));
    });
  }
}

// Test factory implementation
class TestBlocFactory extends BlocFactory<TestBloc> {
  @override
  String get factoryName => 'TestBlocFactory';

  @override
  TestBloc createBloc() {
    return TestBloc();
  }

  @override
  Future<void> prepareDependencies() async {
    // Simulate dependency preparation
    await Future.delayed(const Duration(milliseconds: 10));
  }

  @override
  Future<void> cleanup() async {
    // Simulate cleanup
    await Future.delayed(const Duration(milliseconds: 10));
  }

  @override
  bool shouldRecreate(TestBloc? currentBloc) {
    return currentBloc == null || currentBloc.isClosed;
  }
}

// Factory that fails during creation
class FailingBlocFactory extends BlocFactory<TestBloc> {
  @override
  String get factoryName => 'FailingBlocFactory';

  @override
  TestBloc createBloc() {
    throw Exception('Factory creation failed');
  }

  @override
  Future<void> prepareDependencies() async {
    throw Exception('Dependency preparation failed');
  }

  @override
  Future<void> cleanup() async {
    // Cleanup should not fail
  }

  @override
  bool shouldRecreate(TestBloc? currentBloc) {
    return true;
  }
}

// Factory with expensive operations
class ExpensiveBlocFactory extends BlocFactory<TestBloc> {
  @override
  String get factoryName => 'ExpensiveBlocFactory';

  @override
  TestBloc createBloc() {
    // Simulate expensive creation
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsedMilliseconds < 20) {
      // Busy wait to simulate work
    }
    return TestBloc();
  }

  @override
  Future<void> prepareDependencies() async {
    await Future.delayed(const Duration(milliseconds: 30));
  }

  @override
  Future<void> cleanup() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  group('BlocFactory Tests', () {
    late TestBlocFactory factory;

    setUp(() {
      factory = TestBlocFactory();
    });

    group('Basic Factory Operations', () {
      test('should have correct factory name', () {
        expect(factory.factoryName, 'TestBlocFactory');
      });

      test('should create BLoC instance correctly', () async {
        await factory.prepareDependencies();
        final bloc = factory.createBloc();
        
        expect(bloc, isA<TestBloc>());
        expect(bloc.state, isA<InitialState<String>>());
        expect(bloc.isClosed, false);
        
        await bloc.close();
      });

      test('should handle dependencies preparation', () async {
        final stopwatch = Stopwatch()..start();
        await factory.prepareDependencies();
        stopwatch.stop();
        
        // Should take at least 10ms as defined in test implementation
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(9));
      });

      test('should handle cleanup correctly', () async {
        final stopwatch = Stopwatch()..start();
        await factory.cleanup();
        stopwatch.stop();
        
        // Should take at least 10ms as defined in test implementation
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(9));
      });

      test('should determine recreation necessity correctly', () {
        final activeBloc = TestBloc();
        expect(factory.shouldRecreate(activeBloc), false);
        
        activeBloc.close();
        expect(factory.shouldRecreate(activeBloc), true);
        
        expect(factory.shouldRecreate(null), true);
      });
    });

    group('Factory Error Handling', () {
      test('should handle creation failures gracefully', () async {
        final failingFactory = FailingBlocFactory();
        
        expect(() => failingFactory.createBloc(), throwsException);
      });

      test('should handle dependency preparation failures', () async {
        final failingFactory = FailingBlocFactory();
        
        expect(() => failingFactory.prepareDependencies(), throwsException);
      });

      test('should handle cleanup failures gracefully', () async {
        final failingFactory = FailingBlocFactory();
        
        // Cleanup should not throw in this implementation
        await expectLater(failingFactory.cleanup(), completes);
      });
    });

    group('BlocProviderFactory Integration', () {
      testWidgets('should create BLoC provider correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProviderFactory.create<TestBloc>(
                factory: factory,
                child: BlocBuilder<TestBloc, BaseState<String>>(
                  builder: (context, state) {
                    return Text('State: ${state.runtimeType}');
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.text('State: InitialState<String>'), findsOneWidget);
      });

      testWidgets('should provide BLoC to widget tree', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProviderFactory.create<TestBloc>(
                factory: factory,
                child: Builder(
                  builder: (context) {
                    final bloc = BlocProvider.of<TestBloc>(context);
                    return Column(
                      children: [
                        Text('BLoC Type: ${bloc.runtimeType}'),
                        ElevatedButton(
                          onPressed: () => bloc.loadData(),
                          child: const Text('Load Data'),
                        ),
                        BlocBuilder<TestBloc, BaseState<String>>(
                          builder: (context, state) {
                            if (state.isLoading) return const Text('Loading...');
                            if (state.hasData) return Text('Data: ${state.data}');
                            return const Text('No Data');
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.text('BLoC Type: TestBloc'), findsOneWidget);
        expect(find.text('No Data'), findsOneWidget);

        // Trigger data loading
        await tester.tap(find.text('Load Data'));
        await tester.pump();

        expect(find.text('Loading...'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Data: Test Data'), findsOneWidget);
      });

      testWidgets('should handle multiple providers', (tester) async {
        final secondFactory = TestBlocFactory();
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProviderFactory.create<TestBloc>(
                factory: factory,
                child: BlocProviderFactory.create<TestBloc>(
                  factory: secondFactory,
                  child: Builder(
                    builder: (context) {
                      final providers = context.read<TestBloc>();
                      return Text('Nested Providers: ${providers.runtimeType}');
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Nested Providers: TestBloc'), findsOneWidget);
      });
    });

    group('Factory Performance', () {
      test('should handle expensive factory operations', () async {
        final expensiveFactory = ExpensiveBlocFactory();
        
        final stopwatch = Stopwatch()..start();
        
        await expensiveFactory.prepareDependencies();
        final bloc = expensiveFactory.createBloc();
        await expensiveFactory.cleanup();
        
        stopwatch.stop();
        
        expect(bloc, isA<TestBloc>());
        // Should take at least 60ms (30ms prep + 20ms create + 10ms cleanup)
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(50));
        
        await bloc.close();
      });

      test('should handle concurrent factory operations', () async {
        final factories = List.generate(10, (_) => TestBlocFactory());
        
        final stopwatch = Stopwatch()..start();
        
        // Prepare all dependencies concurrently
        await Future.wait(factories.map((f) => f.prepareDependencies()));
        
        // Create all BLoCs
        final blocs = factories.map((f) => f.createBloc()).toList();
        
        // Cleanup all
        await Future.wait(factories.map((f) => f.cleanup()));
        
        stopwatch.stop();
        
        expect(blocs.length, 10);
        expect(blocs.every((b) => b is TestBloc), true);
        expect(blocs.every((b) => !b.isClosed), true);
        
        // Should be reasonably fast with concurrent operations
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
        
        // Cleanup
        await Future.wait(blocs.map((b) => b.close()));
      });
    });

    group('Factory State Management', () {
      test('should maintain factory state across operations', () async {
        var prepareCount = 0;
        var cleanupCount = 0;
        
        final statefulFactory = StatefulTestBlocFactory(
          onPrepare: () => prepareCount++,
          onCleanup: () => cleanupCount++,
        );
        
        // First cycle
        await statefulFactory.prepareDependencies();
        final bloc1 = statefulFactory.createBloc();
        await statefulFactory.cleanup();
        
        expect(prepareCount, 1);
        expect(cleanupCount, 1);
        
        // Second cycle
        await statefulFactory.prepareDependencies();
        final bloc2 = statefulFactory.createBloc();
        await statefulFactory.cleanup();
        
        expect(prepareCount, 2);
        expect(cleanupCount, 2);
        
        expect(bloc1, isNot(same(bloc2)));
        
        await bloc1.close();
        await bloc2.close();
      });

      test('should handle factory recreation logic', () {
        final activeBloc = TestBloc();
        
        expect(factory.shouldRecreate(activeBloc), false);
        
        // Simulate BLoC processing
        activeBloc.loadData();
        expect(factory.shouldRecreate(activeBloc), false);
        
        // Close BLoC
        activeBloc.close();
        expect(factory.shouldRecreate(activeBloc), true);
      });
    });
  });
}

// Helper factory for testing stateful operations
class StatefulTestBlocFactory extends BlocFactory<TestBloc> {
  final VoidCallback? onPrepare;
  final VoidCallback? onCleanup;
  
  StatefulTestBlocFactory({this.onPrepare, this.onCleanup});

  @override
  String get factoryName => 'StatefulTestBlocFactory';

  @override
  TestBloc createBloc() => TestBloc();

  @override
  Future<void> prepareDependencies() async {
    await Future.delayed(const Duration(milliseconds: 5));
    onPrepare?.call();
  }

  @override
  Future<void> cleanup() async {
    await Future.delayed(const Duration(milliseconds: 5));
    onCleanup?.call();
  }
}