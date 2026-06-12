import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:service_bridge_core/service_bridge_core.dart';

/// Firebase Crashlytics implementation of [CrashReporter].
class FirebaseCrashReporter implements CrashReporter {
  /// Creates a [FirebaseCrashReporter].
  FirebaseCrashReporter({FirebaseCrashlytics? crashlytics}) : _crashlytics = crashlytics;

  FirebaseCrashlytics? _crashlytics;
  bool _initialized = false;

  @override
  String get providerId => SBProvider.firebase.id;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _crashlytics ??= FirebaseCrashlytics.instance;
    await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  Future<void> reportError(Object error, StackTrace stackTrace, {Map<String, dynamic>? extras, SeverityLevel? level}) async {
    if (extras != null) {
      for (final entry in extras.entries) {
        await _crashlytics!.setCustomKey(entry.key, entry.value.toString());
      }
    }
    await _crashlytics!.recordError(error, stackTrace, fatal: level == SeverityLevel.fatal);
  }

  @override
  Future<void> reportMessage(String message, {SeverityLevel level = SeverityLevel.info, Map<String, dynamic>? extras}) async {
    await _crashlytics!.log(message);
  }

  @override
  Future<void> setUserId(String userId) async {
    await _crashlytics!.setUserIdentifier(userId);
  }

  @override
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics!.setCustomKey(key, value.toString());
  }

  @override
  Future<void> recordBreadcrumb(String message, {String? category, Map<String, dynamic>? data}) async {
    final logMessage = category != null ? '[$category] $message' : message;
    await _crashlytics!.log(logMessage);
  }
}
