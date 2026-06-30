import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:service_bridge_firebase/src/firebase_analytics_provider.dart';
import 'package:service_bridge_firebase/src/firebase_crash_reporter.dart';
import 'package:service_bridge_firebase/src/firebase_logger_provider.dart';
import 'package:service_bridge_firebase/src/firebase_push_provider.dart';
import 'package:service_bridge_firebase/src/firebase_remote_config_provider.dart';

/// Convenience class that creates all Firebase provider instances at once.
///
/// Use [FirebaseProviderBundle.initialize] to initialize Firebase Core
/// and create all providers in one step:
///
/// ```dart
/// final bundle = await FirebaseProviderBundle.initialize(
///   remoteConfigDefaults: {'feature_x': false},
/// );
///
/// await ServiceBridge.initialize(
///   ServiceBridgeConfig(
///     crashReporters: [bundle.crashReporter],
///     analyticsProviders: [bundle.analyticsProvider],
///     gmsRemoteConfig: bundle.remoteConfigProvider,
///     pushProviders: [bundle.pushProvider],
///     loggerProviders: [bundle.loggerProvider],
///   ),
/// );
/// ```
class FirebaseProviderBundle {
  /// Creates a [FirebaseProviderBundle] with all Firebase providers.
  ///
  /// Assumes [Firebase.initializeApp] has already been called.
  /// Prefer [FirebaseProviderBundle.initialize] which handles this
  /// automatically.
  FirebaseProviderBundle({
    Map<String, dynamic>? remoteConfigDefaults,
    Duration remoteConfigFetchTimeout = const Duration(seconds: 10),
    Duration remoteConfigMinimumFetchInterval = const Duration(seconds: 10),
    String? environment,
  }) : crashReporter = FirebaseCrashReporter(environment: environment),
       analyticsProvider = FirebaseAnalyticsProvider(),
       remoteConfigProvider = FirebaseRemoteConfigProvider(
         defaults: remoteConfigDefaults,
         fetchTimeout: remoteConfigFetchTimeout,
         minimumFetchInterval: remoteConfigMinimumFetchInterval,
       ),
       pushProvider = FirebasePushProvider(),
       loggerProvider = FirebaseLoggerProvider();

  /// Initializes Firebase Core and creates all Firebase providers.
  ///
  /// Pass [options] to customize the [Firebase.initializeApp] call
  /// (e.g. when using `DefaultFirebaseOptions`).
  static Future<FirebaseProviderBundle> initialize({
    FirebaseOptions? options,
    Map<String, dynamic>? remoteConfigDefaults,
    Duration remoteConfigFetchTimeout = const Duration(seconds: 10),
    Duration remoteConfigMinimumFetchInterval = const Duration(seconds: 10),
    String? environment,
  }) async {
    if (kDebugMode) debugPrint('[ServiceBridge] Initializing Firebase...');
    await Firebase.initializeApp(options: options);
    if (kDebugMode) debugPrint('[ServiceBridge] Firebase Core initialized');

    return FirebaseProviderBundle(
      remoteConfigDefaults: remoteConfigDefaults,
      remoteConfigFetchTimeout: remoteConfigFetchTimeout,
      remoteConfigMinimumFetchInterval: remoteConfigMinimumFetchInterval,
      environment: environment,
    );
  }

  /// Firebase Crashlytics crash reporter.
  final FirebaseCrashReporter crashReporter;

  /// Firebase Analytics provider.
  final FirebaseAnalyticsProvider analyticsProvider;

  /// Firebase Remote Config provider.
  final FirebaseRemoteConfigProvider remoteConfigProvider;

  /// Firebase Cloud Messaging push provider.
  final FirebasePushProvider pushProvider;

  /// Firebase Crashlytics-based logger.
  final FirebaseLoggerProvider loggerProvider;
}
