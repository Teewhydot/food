import 'dart:async';
import 'package:meta/meta.dart';

import '../base/base_state.dart';
import '../../../core/utils/logger.dart';

/// Mixin that provides pull-to-refresh functionality to BLoCs/Cubits
/// Handles refresh logic and prevents multiple simultaneous refreshes
mixin RefreshableBlocMixin<State extends BaseState> {
  /// Whether a refresh operation is currently in progress
  bool _isRefreshing = false;
  
  /// Minimum time between refresh operations to prevent spam
  Duration get refreshCooldown => const Duration(seconds: 2);
  
  /// Last refresh timestamp
  DateTime? _lastRefreshTime;

  /// Timer for automatic refresh
  Timer? _autoRefreshTimer;

  /// Whether this BLoC supports pull-to-refresh
  bool get supportsRefresh => true;

  /// Whether auto-refresh is enabled
  bool get autoRefreshEnabled => false;

  /// Auto-refresh interval
  Duration get autoRefreshInterval => const Duration(minutes: 5);

  /// Whether a refresh operation is currently in progress
  bool get isRefreshing => _isRefreshing;

  /// Whether refresh is available (not in cooldown)
  bool get canRefresh {
    if (!supportsRefresh || _isRefreshing) return false;
    
    if (_lastRefreshTime == null) return true;
    
    return DateTime.now().difference(_lastRefreshTime!) >= refreshCooldown;
  }

  /// Time remaining in refresh cooldown
  Duration? get refreshCooldownRemaining {
    if (_lastRefreshTime == null || canRefresh) return null;
    
    final elapsed = DateTime.now().difference(_lastRefreshTime!);
    return refreshCooldown - elapsed;
  }

  /// Perform refresh operation
  @protected
  Future<void> performRefresh() async {
    if (!canRefresh) {
      Logger.logWarning('Refresh blocked - ${_isRefreshing ? 'already refreshing' : 'in cooldown'}');
      return;
    }

    _isRefreshing = true;
    _lastRefreshTime = DateTime.now();
    
    try {
      Logger.logBasic('Starting refresh operation');
      await onRefresh();
      Logger.logBasic('Refresh operation completed');
    } catch (e, stackTrace) {
      Logger.logError('Refresh operation failed: $e');
      await onRefreshError(e, stackTrace);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Override this method to implement refresh logic
  @protected
  Future<void> onRefresh();

  /// Called when refresh operation fails
  @protected
  Future<void> onRefreshError(Object error, StackTrace stackTrace) async {
    // Default implementation - subclasses can override
    Logger.logError('Refresh failed: $error');
  }

  /// Start auto-refresh timer
  @protected
  void startAutoRefresh() {
    if (!autoRefreshEnabled || !supportsRefresh) return;

    stopAutoRefresh(); // Stop existing timer
    
    _autoRefreshTimer = Timer.periodic(autoRefreshInterval, (timer) {
      if (canRefresh) {
        performRefresh();
      }
    });
    
    Logger.logBasic('Auto-refresh started with interval: $autoRefreshInterval');
  }

  /// Stop auto-refresh timer
  @protected
  void stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
    Logger.logBasic('Auto-refresh stopped');
  }

  /// Force refresh (ignores cooldown)
  @protected
  Future<void> forceRefresh() async {
    if (!supportsRefresh) return;

    _isRefreshing = true;
    _lastRefreshTime = DateTime.now();
    
    try {
      Logger.logBasic('Starting forced refresh operation');
      await onRefresh();
      Logger.logBasic('Forced refresh operation completed');
    } catch (e, stackTrace) {
      Logger.logError('Forced refresh operation failed: $e');
      await onRefreshError(e, stackTrace);
    } finally {
      _isRefreshing = false;
    }
  }

  /// Clean up resources
  @protected
  void disposeRefreshable() {
    stopAutoRefresh();
  }
}