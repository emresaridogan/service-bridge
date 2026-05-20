import 'package:service_bridge/src/contracts/base_service_provider.dart';
import 'package:service_bridge/src/core/enums.dart';

/// Contract for crash reporting providers.
///
/// Implementations: FirebaseCrashReporter, SentryCrashReporter
abstract class CrashReporter extends BaseServiceProvider {
  /// Report an error with its stack trace.
  Future<void> reportError(Object error, StackTrace stackTrace, {Map<String, dynamic>? extras, SeverityLevel? level});

  /// Report a text message as a non-fatal event.
  Future<void> reportMessage(String message, {SeverityLevel level = SeverityLevel.info, Map<String, dynamic>? extras});

  /// Associate a user ID with subsequent crash reports.
  Future<void> setUserId(String userId);

  /// Set a custom key-value pair attached to crash reports.
  Future<void> setCustomKey(String key, dynamic value);

  /// Record a breadcrumb for debugging context.
  Future<void> recordBreadcrumb(String message, {String? category, Map<String, dynamic>? data});
}
