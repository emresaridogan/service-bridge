import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:service_bridge_core/src/core/enums.dart';
import 'package:service_bridge_core/src/core/sb_logger.dart';
import 'package:service_bridge_core/src/core/service_bridge.dart';

/// Sets up comprehensive error handling that routes all uncaught errors
/// to [ServiceBridge.instance.crash].
///
/// Handles three error channels:
/// - **FlutterError.onError**: Framework errors (build, layout, painting)
/// - **PlatformDispatcher.instance.onError**: Async errors outside Flutter
/// - **Zone guard**: Catches errors missed by the above (zone-level safety net)
///
/// Deduplicates errors to prevent the same error being reported twice
/// when both FlutterError and PlatformDispatcher fire for the same exception.
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await ServiceBridge.initialize(config);
///
///   ServiceBridgeErrorHandler.setup();
///   runApp(MyApp());
/// }
/// ```
///
/// Or use the zone-based runner for maximum coverage:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await ServiceBridge.initialize(config);
///
///   ServiceBridgeErrorHandler.runGuarded(() {
///     runApp(MyApp());
///   });
/// }
/// ```
final class ServiceBridgeErrorHandler {
  ServiceBridgeErrorHandler._();

  static int _lastErrorHash = 0;
  static DateTime _lastErrorTime = DateTime(0);

  /// Set up FlutterError and PlatformDispatcher error handlers.
  ///
  /// Call this after [ServiceBridge.initialize].
  static void setup() {
    FlutterError.onError = _handleFlutterError;
    PlatformDispatcher.instance.onError = _handlePlatformError;
    SBLogger.info('Error handlers registered');
  }

  /// Run [body] inside a guarded zone that catches all uncaught errors.
  ///
  /// Also sets up FlutterError and PlatformDispatcher handlers.
  /// Use this instead of [setup] + `runApp()` for maximum coverage.
  static void runGuarded(VoidCallback body) {
    setup();
    runZonedGuarded(body, (error, stack) {
      // Zone-level catch — last resort for errors missed by Flutter/Platform handlers.
      _reportIfNotDuplicate(error, stack, source: 'Zone');
    });
  }

  static void _handleFlutterError(FlutterErrorDetails details) {
    // FlutterError.onError fires for framework errors (build, layout, etc.)
    _reportIfNotDuplicate(details.exception, details.stack ?? StackTrace.current, source: 'FlutterError');
  }

  static bool _handlePlatformError(Object error, StackTrace stack) {
    // PlatformDispatcher fires for async errors outside Flutter framework
    _reportIfNotDuplicate(error, stack, source: 'PlatformDispatcher');
    return true;
  }

  /// Reports the error only if it's not a duplicate of the last reported error.
  ///
  /// Two errors are considered duplicates if they have the same hash and
  /// occur within 500ms of each other.
  static void _reportIfNotDuplicate(Object error, StackTrace stack, {required String source}) {
    final now = DateTime.now();
    final errorHash = Object.hash(error.runtimeType, error.toString());

    // Skip if same error reported within 500ms (duplicate from another handler)
    if (errorHash == _lastErrorHash && now.difference(_lastErrorTime).inMilliseconds < 500) {
      SBLogger.info('Duplicate error suppressed from $source');
      return;
    }

    _lastErrorHash = errorHash;
    _lastErrorTime = now;

    if (!ServiceBridge.isInitialized) {
      SBLogger.error('ServiceBridge not initialized — error lost', error, stack);
      return;
    }

    ServiceBridge.instance.crash.reportError(error, stack, level: SeverityLevel.fatal, extras: {'sb_error_source': source});
  }
}
