import 'package:service_bridge/src/contracts/analytics_provider.dart';
import 'package:service_bridge/src/contracts/crash_reporter.dart';
import 'package:service_bridge/src/contracts/deep_link_provider.dart';
import 'package:service_bridge/src/contracts/logger_provider.dart';
import 'package:service_bridge/src/contracts/push_notification_provider.dart';
import 'package:service_bridge/src/contracts/remote_config_provider.dart';
import 'package:service_bridge/src/contracts/user_tracker.dart';
import 'package:service_bridge/src/core/enums.dart';

/// Configuration for `ServiceBridge`.
///
/// Defines which providers are registered for each service
/// category and which ones are active by default.
class ServiceBridgeConfig {
  /// Creates a [ServiceBridgeConfig].
  const ServiceBridgeConfig({
    this.crashReporters = const [],
    this.defaultCrashProviders = const {},
    this.analyticsProviders = const [],
    this.defaultAnalyticsProviders = const {},
    this.gmsRemoteConfig,
    this.hmsRemoteConfig,
    this.pushProviders = const [],
    this.defaultPushProviders = const {},
    this.loggerProviders = const [],
    this.defaultLogProviders = const {},
    this.deepLinkProviders = const [],
    this.defaultDeepLinkProviders = const {},
    this.userTrackers = const [],
    this.defaultUserTrackingProviders = const {},
    this.platformOverride,
  });

  // -- Crash Reporting --

  /// All registered crash reporters.
  final List<CrashReporter> crashReporters;

  /// Providers that are active by default for crash reporting.
  final Set<SBProvider> defaultCrashProviders;

  // -- Analytics --

  /// All registered analytics providers.
  final List<AnalyticsProvider> analyticsProviders;

  /// Providers that are active by default for analytics.
  final Set<SBProvider> defaultAnalyticsProviders;

  // -- Remote Config --

  /// Remote config provider for GMS devices (e.g., Firebase Remote Config).
  final RemoteConfigProvider? gmsRemoteConfig;

  /// Remote config provider for HMS devices (e.g., Huawei Remote Config).
  final RemoteConfigProvider? hmsRemoteConfig;

  // -- Push Notifications --

  /// All registered push notification providers.
  final List<PushNotificationProvider> pushProviders;

  /// Providers that are active by default for push notifications.
  final Set<SBProvider> defaultPushProviders;

  // -- Logging --

  /// All registered logger providers.
  final List<LoggerProvider> loggerProviders;

  /// Providers that are active by default for logging.
  final Set<SBProvider> defaultLogProviders;

  // -- Deep Linking --

  /// All registered deep link providers.
  final List<DeepLinkProvider> deepLinkProviders;

  /// Providers that are active by default for deep linking.
  final Set<SBProvider> defaultDeepLinkProviders;

  // -- User Tracking --

  /// All registered user tracking providers.
  final List<UserTracker> userTrackers;

  /// Providers that are active by default for user tracking.
  final Set<SBProvider> defaultUserTrackingProviders;

  // -- Platform --

  /// Force a specific platform type instead of runtime detection.
  /// Useful for build-time flavor differentiation.
  final PlatformType? platformOverride;
}
