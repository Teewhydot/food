import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/logger.dart';

/// Factory interface for creating BLoCs
abstract class BlocFactory<T extends BlocBase> {
  /// Create a new instance of the BLoC
  T create();

  /// Optional: Prepare dependencies before creation
  Future<void> prepareDependencies() async {}

  /// Optional: Clean up after BLoC disposal
  Future<void> cleanup() async {}

  /// Factory name for debugging
  String get factoryName => T.toString();
}

/// Generic factory implementation that uses GetIt for dependency resolution
class DefaultBlocFactory<T extends BlocBase> implements BlocFactory<T> {
  final T Function() _creator;
  final String? _factoryName;

  const DefaultBlocFactory(this._creator, {String? factoryName}) 
      : _factoryName = factoryName;

  @override
  T create() {
    try {
      final bloc = _creator();
      Logger.logBasic('Created BLoC: ${bloc.runtimeType}');
      return bloc;
    } catch (e) {
      Logger.logError('Failed to create BLoC: $T');
      rethrow;
    }
  }

  @override
  Future<void> prepareDependencies() async {}

  @override
  Future<void> cleanup() async {}

  @override
  String get factoryName => _factoryName ?? T.toString();
}

/// Factory for singleton BLoCs (shared across the app)
class SingletonBlocFactory<T extends BlocBase> implements BlocFactory<T> {
  final T Function() _creator;
  final String? _factoryName;
  T? _instance;

  SingletonBlocFactory(this._creator, {String? factoryName}) 
      : _factoryName = factoryName;

  @override
  T create() {
    _instance ??= _creator();
    Logger.logBasic('Retrieved singleton BLoC: ${_instance.runtimeType}');
    return _instance!;
  }

  @override
  Future<void> prepareDependencies() async {}

  @override
  Future<void> cleanup() async {
    await disposeSingleton();
  }

  @override
  String get factoryName => _factoryName ?? T.toString();

  /// Dispose the singleton instance
  Future<void> disposeSingleton() async {
    if (_instance != null) {
      await _instance!.close();
      _instance = null;
      Logger.logBasic('Disposed singleton BLoC: $T');
    }
  }
}

/// Factory for scoped BLoCs (tied to specific feature modules)
class ScopedBlocFactory<T extends BlocBase> implements BlocFactory<T> {
  final T Function() _creator;
  final String _scope;
  final String? _factoryName;
  final Map<String, T> _scopedInstances = {};

  ScopedBlocFactory(
    this._creator, 
    this._scope, {
    String? factoryName,
  }) : _factoryName = factoryName;

  @override
  T create() {
    _scopedInstances[_scope] ??= _creator();
    Logger.logBasic('Retrieved scoped BLoC ($_scope): ${_scopedInstances[_scope].runtimeType}');
    return _scopedInstances[_scope]!;
  }

  @override
  Future<void> prepareDependencies() async {}

  @override
  Future<void> cleanup() async {
    await disposeAllScopes();
  }

  @override
  String get factoryName => _factoryName ?? '$T($_scope)';

  /// Dispose scoped instance
  Future<void> disposeScope(String scope) async {
    final instance = _scopedInstances.remove(scope);
    if (instance != null) {
      await instance.close();
      Logger.logBasic('Disposed scoped BLoC ($scope): $T');
    }
  }

  /// Dispose all scoped instances
  Future<void> disposeAllScopes() async {
    for (final entry in _scopedInstances.entries) {
      await entry.value.close();
      Logger.logBasic('Disposed scoped BLoC (${entry.key}): $T');
    }
    _scopedInstances.clear();
  }
}

/// Factory for lazy-loaded BLoCs
class LazyBlocFactory<T extends BlocBase> implements BlocFactory<T> {
  final Future<T> Function() _asyncCreator;
  final String? _factoryName;
  Future<T>? _creationFuture;

  LazyBlocFactory(this._asyncCreator, {String? factoryName}) 
      : _factoryName = factoryName;

  @override
  T create() {
    throw UnsupportedError('Use createAsync() for lazy BLoCs');
  }

  @override
  Future<void> prepareDependencies() async {}

  @override
  Future<void> cleanup() async {
    if (_creationFuture != null) {
      final bloc = await _creationFuture!;
      await bloc.close();
      _creationFuture = null;
    }
  }

  /// Asynchronously create the BLoC
  Future<T> createAsync() async {
    _creationFuture ??= _asyncCreator();
    final bloc = await _creationFuture!;
    Logger.logBasic('Created lazy BLoC: ${bloc.runtimeType}');
    return bloc;
  }

  @override
  String get factoryName => _factoryName ?? 'Lazy$T';
}

/// Manager for all BLoC factories
class BlocFactoryManager {
  static final BlocFactoryManager _instance = BlocFactoryManager._internal();
  factory BlocFactoryManager() => _instance;
  BlocFactoryManager._internal();

  final Map<Type, BlocFactory> _factories = {};
  final Map<String, BlocFactory> _namedFactories = {};

  /// Register a factory for a BLoC type
  void registerFactory<T extends BlocBase>(BlocFactory<T> factory) {
    _factories[T] = factory;
    Logger.logBasic('Registered factory for ${factory.factoryName}');
  }

  /// Register a named factory
  void registerNamedFactory(String name, BlocFactory factory) {
    _namedFactories[name] = factory;
    Logger.logBasic('Registered named factory: $name');
  }

  /// Get factory for a BLoC type
  BlocFactory<T>? getFactory<T extends BlocBase>() {
    return _factories[T] as BlocFactory<T>?;
  }

  /// Get named factory
  BlocFactory? getNamedFactory(String name) {
    return _namedFactories[name];
  }

  /// Create BLoC using registered factory
  T create<T extends BlocBase>() {
    final factory = getFactory<T>();
    if (factory == null) {
      throw StateError('No factory registered for type $T');
    }
    return factory.create();
  }

  /// Create BLoC using named factory
  BlocBase createNamed(String name) {
    final factory = getNamedFactory(name);
    if (factory == null) {
      throw StateError('No factory registered with name: $name');
    }
    return factory.create();
  }

  /// Dispose all singleton factories
  Future<void> disposeAllSingletons() async {
    for (final factory in _factories.values) {
      if (factory is SingletonBlocFactory) {
        await factory.disposeSingleton();
      }
    }
    
    for (final factory in _namedFactories.values) {
      if (factory is SingletonBlocFactory) {
        await factory.disposeSingleton();
      }
    }
    
    Logger.logBasic('Disposed all singleton BLoCs');
  }

  /// Clear all factories
  void clearFactories() {
    _factories.clear();
    _namedFactories.clear();
    Logger.logBasic('Cleared all BLoC factories');
  }

  /// Get all registered factory names
  List<String> getRegisteredFactories() {
    final typeFactories = _factories.entries.map((e) => e.key.toString());
    final namedFactories = _namedFactories.keys;
    return [...typeFactories, ...namedFactories];
  }
}

/// Convenience functions for creating BlocProviders
class BlocProviderFactory {
  /// Create BlocProvider using factory
  static BlocProvider<T> factory<T extends BlocBase<S>, S>(
    BlocFactory<T> factory, {
    Widget? child,
    bool lazy = true,
  }) {
    return BlocProvider<T>(
      create: (_) => factory.create(),
      lazy: lazy,
      child: child,
    );
  }

  /// Create BlocProvider using registered factory
  static BlocProvider<T> fromRegistry<T extends BlocBase<S>, S>({
    Widget? child,
    bool lazy = true,
  }) {
    return BlocProvider<T>(
      create: (_) => BlocFactoryManager().create<T>(),
      lazy: lazy,
      child: child,
    );
  }
}

/// Builder for creating multiple BlocProviders
class MultiBlocProviderBuilder {
  final List<BlocProvider> _providers = [];

  /// Add provider using factory
  MultiBlocProviderBuilder addFactory<T extends BlocBase<S>, S>(
    BlocFactory<T> factory, {
    bool lazy = true,
  }) {
    _providers.add(BlocProviderFactory.factory(factory, lazy: lazy));
    return this;
  }

  /// Add provider using registered factory
  MultiBlocProviderBuilder addFromRegistry<T extends BlocBase<S>, S>({
    bool lazy = true,
  }) {
    _providers.add(BlocProviderFactory.fromRegistry<T, S>(lazy: lazy));
    return this;
  }

  /// Add custom provider
  MultiBlocProviderBuilder addProvider(BlocProvider provider) {
    _providers.add(provider);
    return this;
  }

  /// Build MultiBlocProvider
  MultiBlocProvider build({required Widget child}) {
    return MultiBlocProvider(
      providers: _providers,
      child: child,
    );
  }

  /// Get list of providers
  List<BlocProvider> get providers => List.unmodifiable(_providers);
}