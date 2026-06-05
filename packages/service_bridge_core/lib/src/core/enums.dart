/// Severity level for crash reports and logs.
enum SeverityLevel {
  /// Debug-level severity.
  debug,

  /// Informational severity.
  info,

  /// Warning-level severity.
  warning,

  /// Error-level severity.
  error,

  /// Fatal/critical severity.
  fatal,
}

/// Log level for logger providers.
enum LogLevel {
  /// Verbose/trace level.
  verbose,

  /// Debug level.
  debug,

  /// Informational level.
  info,

  /// Warning level.
  warning,

  /// Error level.
  error,

  /// Fatal level — app cannot continue.
  fatal,
}

/// Platform type for GMS/HMS differentiation.
enum PlatformType {
  /// Google Mobile Services (default for most Android devices and iOS).
  gms,

  /// Huawei Mobile Services (for Huawei/Honor devices without GMS).
  hms,
}

/// Built-in provider identifiers for use in [ServiceBridgeConfig] and
/// manager `only`/`exclude` parameters.
///
/// Use [id] to get the underlying string value when needed.
///
/// Custom providers not listed here should pass their own string ID directly.
enum SBProvider {
  // -- Firebase --

  /// Firebase Crashlytics, Analytics, Remote Config and Push.
  firebase('firebase'),

  /// Firebase Crashlytics-based logger.
  firebaseLogger('firebase_logger'),

  // -- Sentry --

  /// Sentry crash reporter.
  sentry('sentry'),

  /// Sentry breadcrumb/event logger.
  sentryLogger('sentry_logger'),

  // -- AppsFlyer --

  /// AppsFlyer analytics, deep links and user tracking.
  appsflyer('appsflyer'),

  // -- Insider --

  /// Insider analytics, push and user tracking.
  insider('insider'),

  // -- Huawei --

  /// Huawei Push Kit and Remote Config.
  huawei('huawei');

  const SBProvider(this.id);

  /// The underlying string identifier matched against [BaseServiceProvider.providerId].
  final String id;

  static final Map<String, SBProvider> _byId = {for (final provider in SBProvider.values) provider.id: provider};

  /// Resolves an [SBProvider] from a raw provider identifier.
  static SBProvider? fromId(String id) => _byId[id];

  /// Providers that require Google Mobile Services (Firebase).
  static const _firebaseDependentProviders = {firebase, firebaseLogger};

  /// Whether this provider requires Google Mobile Services.
  ///
  /// Firebase-dependent providers cannot be used on HMS (Huawei) devices.
  bool get isFirebaseDependent => _firebaseDependentProviders.contains(this);
}
