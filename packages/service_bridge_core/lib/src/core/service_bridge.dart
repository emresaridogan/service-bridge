import 'package:service_bridge_core/src/contracts/base_service_provider.dart';
import 'package:service_bridge_core/src/core/crash_context_collector.dart';
import 'package:service_bridge_core/src/core/enums.dart';
import 'package:service_bridge_core/src/core/platform_detector.dart';
import 'package:service_bridge_core/src/core/sb_logger.dart';
import 'package:service_bridge_core/src/core/service_bridge_config.dart';
import 'package:service_bridge_core/src/managers/analytics_manager.dart';
import 'package:service_bridge_core/src/managers/crash_manager.dart';
import 'package:service_bridge_core/src/managers/deep_link_manager.dart';
import 'package:service_bridge_core/src/managers/log_manager.dart';
import 'package:service_bridge_core/src/managers/push_notification_manager.dart';
import 'package:service_bridge_core/src/managers/remote_config_manager.dart';
import 'package:service_bridge_core/src/managers/user_tracking_manager.dart';

/// Central orchestrator for all third-party service providers.
///
/// Provides unified access to crash reporting, analytics, remote config,
/// push notifications, logging, deep linking, and user tracking through
/// category-specific managers.
///
/// ```dart
/// // Initialize once at app startup
/// await ServiceBridge.initialize(
///   ServiceBridgeConfig(
///     crashReporters: [
///       FirebaseCrashReporter(),
///       SentryCrashReporter(dsn: '...'),
///     ],
///     defaultCrashProviders: {SBProvider.firebase, SBProvider.sentry},
///     // ...
///   ),
/// );
///
/// // Use throughout the app
/// ServiceBridge.instance.crash.reportError(error, stackTrace);
/// ServiceBridge.instance.analytics.logEvent('purchase');
/// ```
class ServiceBridge {
  ServiceBridge._({
    required this.crash,
    required this.analytics,
    required this.remoteConfig,
    required this.pushNotification,
    required this.log,
    required this.deepLink,
    required this.userTracking,
    required this.platform,
  });

  static ServiceBridge? _instance;

  /// The singleton instance. Throws if [initialize] has not been called.
  static ServiceBridge get instance {
    if (_instance == null) {
      throw StateError(
        'ServiceBridge has not been initialized. '
        'Call ServiceBridge.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Whether the service bridge has been initialized.
  static bool get isInitialized => _instance != null;

  /// Crash reporting manager.
  final CrashManager crash;

  /// Analytics manager.
  final AnalyticsManager analytics;

  /// Remote config manager with automatic GMS/HMS routing.
  final RemoteConfigManager remoteConfig;

  /// Push notification manager.
  final PushNotificationManager pushNotification;

  /// Logging manager.
  final LogManager log;

  /// Deep link manager.
  final DeepLinkManager deepLink;

  /// User tracking / attribution manager.
  final UserTrackingManager userTracking;

  /// Platform detector for GMS/HMS differentiation.
  final PlatformDetector platform;

  /// Initialize the service bridge with the given configuration.
  ///
  /// This will:
  /// 1. Create the [PlatformDetector] and detect the platform
  /// 2. Initialize all registered providers
  /// 3. Create category managers
  /// 4. Set up the singleton instance
  ///
  /// Should be called once at app startup, before any service calls.
  static Future<void> initialize(ServiceBridgeConfig config) async {
    if (_instance != null) {
      throw StateError(
        'ServiceBridge has already been initialized. '
        'Call dispose() before re-initializing.',
      );
    }

    // 1. Platform detection
    final platformDetector = PlatformDetector(platformOverride: config.platformOverride);
    final detectedPlatform = await platformDetector.detect();
    SBLogger.info('Platform detected: ${detectedPlatform.name}');

    // Share detected platform with context collector
    CrashContextCollector.instance.setPlatformType(detectedPlatform);

    // 2. Collect all unique providers and initialize them
    final allProviders = <BaseServiceProvider>{
      ...config.crashReporters,
      ...config.analyticsProviders,
      if (config.gmsRemoteConfig != null) config.gmsRemoteConfig!,
      if (config.hmsRemoteConfig != null) config.hmsRemoteConfig!,
      ...config.pushProviders,
      ...config.loggerProviders,
      ...config.deepLinkProviders,
      ...config.userTrackers,
    };

    // 3. Validate: Firebase-dependent providers cannot be used on HMS
    if (detectedPlatform == PlatformType.hms) {
      final incompatible = allProviders.where((p) {
        return SBProvider.values.any((sp) => sp.isFirebaseDependent && sp.id == p.providerId);
      }).toList();

      if (incompatible.isNotEmpty) {
        final names = incompatible.map((p) => '${p.runtimeType} [${p.providerId}]').join(', ');
        throw StateError(
          'Firebase-dependent providers cannot be used on HMS (Huawei) '
          'devices: $names. Use platform-aware initialization to exclude '
          'Firebase providers on HMS.',
        );
      }
    }

    SBLogger.info('Initializing ${allProviders.length} provider(s)...');
    for (final provider in allProviders) {
      if (provider.isInitialized) {
        SBLogger.info('  ↷ ${provider.runtimeType} [${provider.providerId}] already initialized, skipping');
        continue;
      }
      try {
        await provider.initialize();
        SBLogger.info('  ✓ ${provider.runtimeType} [${provider.providerId}] initialized');
      } on Exception catch (e, st) {
        SBLogger.error('  ✗ ${provider.runtimeType} [${provider.providerId}] failed to initialize', e, st);
      }
    }

    // 3. Create managers
    _instance = ServiceBridge._(
      crash: CrashManager(providers: config.crashReporters, defaultProviders: config.defaultCrashProviders),
      analytics: AnalyticsManager(providers: config.analyticsProviders, defaultProviders: config.defaultAnalyticsProviders),
      remoteConfig: RemoteConfigManager(
        platformDetector: platformDetector,
        gmsProvider: config.gmsRemoteConfig,
        hmsProvider: config.hmsRemoteConfig,
      ),
      pushNotification: PushNotificationManager(providers: config.pushProviders, defaultProviders: config.defaultPushProviders),
      log: LogManager(providers: config.loggerProviders, defaultProviders: config.defaultLogProviders),
      deepLink: DeepLinkManager(providers: config.deepLinkProviders, defaultProviders: config.defaultDeepLinkProviders),
      userTracking: UserTrackingManager(providers: config.userTrackers, defaultProviders: config.defaultUserTrackingProviders),
      platform: platformDetector,
    );

    SBLogger.info('ServiceBridge initialized successfully');
  }

  /// Dispose all providers and reset the singleton.
  static Future<void> dispose() async {
    if (_instance == null) return;

    SBLogger.info('Disposing ServiceBridge...');

    final allProviders = <BaseServiceProvider>{
      ..._instance!.crash.providers,
      ..._instance!.analytics.providers,
      if (_instance!.remoteConfig.gmsProvider != null) _instance!.remoteConfig.gmsProvider!,
      if (_instance!.remoteConfig.hmsProvider != null) _instance!.remoteConfig.hmsProvider!,
      ..._instance!.pushNotification.providers,
      ..._instance!.log.providers,
      ..._instance!.deepLink.providers,
      ..._instance!.userTracking.providers,
    };

    await Future.wait(allProviders.map((p) => p.dispose()));

    _instance = null;
    SBLogger.info('ServiceBridge disposed');
  }
}
