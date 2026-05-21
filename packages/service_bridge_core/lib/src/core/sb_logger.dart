import 'package:flutter/foundation.dart';

/// Internal debug logger for ServiceBridge.
///
/// All output is prefixed with `[ServiceBridge]` and only prints
/// in debug mode (`kDebugMode`).
@internal
final class SBLogger {
  const SBLogger._();

  static const _tag = 'ServiceBridge';

  /// Logs an informational message.
  static void info(String message) {
    if (kDebugMode) debugPrint('[$_tag] $message');
  }

  /// Logs a warning message.
  static void warning(String message) {
    if (kDebugMode) debugPrint('[$_tag] ⚠️ $message');
  }

  /// Logs an error message with optional error and stack trace.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$_tag] ❌ $message');
      if (error != null) debugPrint('[$_tag]    Error: $error');
      if (stackTrace != null) debugPrint('[$_tag]    Stack: $stackTrace');
    }
  }
}
