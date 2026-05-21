import 'dart:async';

import 'package:service_bridge_core/service_bridge_core.dart';

// -- Mock Base --

/// Base mock implementation for testing.
mixin MockServiceProviderMixin implements BaseServiceProvider {
  bool _initialized = false;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }
}

// -- Mock CrashReporter --

/// Mock crash reporter for testing.
class MockCrashReporter with MockServiceProviderMixin implements CrashReporter {
  /// Recorded errors for verification.
  final List<MockCrashReport> reports = [];

  /// Recorded breadcrumbs for verification.
  final List<String> breadcrumbs = [];

  @override
  String get providerId => 'mock_crash';

  @override
  Future<void> reportError(Object error, StackTrace stackTrace, {Map<String, dynamic>? extras, SeverityLevel? level}) async {
    reports.add(MockCrashReport(error: error, stackTrace: stackTrace, extras: extras, level: level));
  }

  @override
  Future<void> reportMessage(String message, {SeverityLevel level = SeverityLevel.info, Map<String, dynamic>? extras}) async {
    reports.add(MockCrashReport(error: message, level: level, extras: extras));
  }

  @override
  Future<void> setUserId(String userId) async {}

  @override
  Future<void> setCustomKey(String key, dynamic value) async {}

  @override
  Future<void> recordBreadcrumb(String message, {String? category, Map<String, dynamic>? data}) async {
    breadcrumbs.add(message);
  }
}

/// Recorded crash report data.
class MockCrashReport {
  /// Creates a [MockCrashReport].
  MockCrashReport({required this.error, this.stackTrace, this.extras, this.level});

  /// The error object.
  final Object error;

  /// The stack trace.
  final StackTrace? stackTrace;

  /// Extra data.
  final Map<String, dynamic>? extras;

  /// Severity level.
  final SeverityLevel? level;
}

// -- Mock AnalyticsProvider --

/// Mock analytics provider for testing.
class MockAnalyticsProvider with MockServiceProviderMixin implements AnalyticsProvider {
  /// Recorded events for verification.
  final List<MockAnalyticsEvent> events = [];

  /// Recorded screen views for verification.
  final List<String> screenViews = [];

  @override
  String get providerId => 'mock_analytics';

  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    events.add(MockAnalyticsEvent(name: name, parameters: parameters));
  }

  @override
  Future<void> setUserId(String userId) async {}

  @override
  Future<void> setUserProperty({required String name, required String value}) async {}

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    screenViews.add(screenName);
  }

  @override
  Future<void> resetAnalyticsData() async {
    events.clear();
    screenViews.clear();
  }
}

/// Recorded analytics event data.
class MockAnalyticsEvent {
  /// Creates a [MockAnalyticsEvent].
  MockAnalyticsEvent({required this.name, this.parameters});

  /// Event name.
  final String name;

  /// Event parameters.
  final Map<String, dynamic>? parameters;
}

// -- Mock RemoteConfigProvider --

/// Mock remote config provider for testing.
class MockRemoteConfigProvider with MockServiceProviderMixin implements RemoteConfigProvider {
  /// Values to return from get methods.
  final Map<String, dynamic> values = {};

  @override
  String get providerId => 'mock_remote_config';

  @override
  Future<bool> fetchAndActivate() async => true;

  @override
  String getString(String key, {String defaultValue = ''}) => (values[key] as String?) ?? defaultValue;

  @override
  bool getBool(String key, {bool defaultValue = false}) => (values[key] as bool?) ?? defaultValue;

  @override
  int getInt(String key, {int defaultValue = 0}) => (values[key] as int?) ?? defaultValue;

  @override
  double getDouble(String key, {double defaultValue = 0.0}) => (values[key] as double?) ?? defaultValue;

  @override
  Map<String, dynamic> getAll() => Map.unmodifiable(values);

  @override
  Future<void> setMinimumFetchInterval(Duration interval) async {}
}

// -- Mock LoggerProvider --

/// Mock logger provider for testing.
class MockLoggerProvider with MockServiceProviderMixin implements LoggerProvider {
  /// Recorded log entries for verification.
  final List<MockLogEntry> logs = [];

  @override
  String get providerId => 'mock_logger';

  @override
  Future<void> log(LogLevel level, String message, {Map<String, dynamic>? extras, Object? error, StackTrace? stackTrace}) async {
    logs.add(MockLogEntry(level: level, message: message, extras: extras, error: error));
  }

  @override
  Future<void> debug(String message, {Map<String, dynamic>? extras}) => log(LogLevel.debug, message, extras: extras);

  @override
  Future<void> info(String message, {Map<String, dynamic>? extras}) => log(LogLevel.info, message, extras: extras);

  @override
  Future<void> warning(String message, {Map<String, dynamic>? extras}) => log(LogLevel.warning, message, extras: extras);

  @override
  Future<void> error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extras}) =>
      log(LogLevel.error, message, extras: extras, error: error, stackTrace: stackTrace);
}

/// Recorded log entry data.
class MockLogEntry {
  /// Creates a [MockLogEntry].
  MockLogEntry({required this.level, required this.message, this.extras, this.error});

  /// Log level.
  final LogLevel level;

  /// Log message.
  final String message;

  /// Extra data.
  final Map<String, dynamic>? extras;

  /// Associated error.
  final Object? error;
}

// -- Mock PushNotificationProvider --

/// Mock push notification provider for testing.
class MockPushNotificationProvider with MockServiceProviderMixin implements PushNotificationProvider {
  /// The token to return from [getToken].
  String? mockToken = 'mock-push-token';

  final StreamController<String> _tokenController = StreamController<String>.broadcast();
  final StreamController<NotificationMessage> _messageController = StreamController<NotificationMessage>.broadcast();
  final StreamController<NotificationMessage> _messageOpenedController = StreamController<NotificationMessage>.broadcast();

  @override
  String get providerId => 'mock_push';

  @override
  Future<String?> getToken() async => mockToken;

  @override
  Stream<String> get onTokenRefresh => _tokenController.stream;

  @override
  Stream<NotificationMessage> get onMessageReceived => _messageController.stream;

  @override
  Stream<NotificationMessage> get onMessageOpenedApp => _messageOpenedController.stream;

  @override
  Future<void> subscribeToTopic(String topic) async {}

  @override
  Future<void> unsubscribeFromTopic(String topic) async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> dispose() async {
    await _tokenController.close();
    await _messageController.close();
    await _messageOpenedController.close();
    await super.dispose();
  }
}

// -- Mock DeepLinkProvider --

/// Mock deep link provider for testing.
class MockDeepLinkProvider with MockServiceProviderMixin implements DeepLinkProvider {
  /// The initial link to return.
  Uri? mockInitialLink;

  final StreamController<Uri> _deepLinkController = StreamController<Uri>.broadcast();

  @override
  String get providerId => 'mock_deep_link';

  @override
  Future<Uri?> getInitialLink() async => mockInitialLink;

  @override
  Stream<Uri> get onDeepLink => _deepLinkController.stream;

  @override
  Future<Uri> createDeepLink(DeepLinkParams params) async => params.link;

  @override
  Future<void> dispose() async {
    await _deepLinkController.close();
    await super.dispose();
  }
}

// -- Mock UserTracker --

/// Mock user tracker for testing.
class MockUserTracker with MockServiceProviderMixin implements UserTracker {
  /// Recorded events for verification.
  final List<MockAnalyticsEvent> events = [];

  /// Last identified user ID.
  String? lastUserId;

  @override
  String get providerId => 'mock_user_tracker';

  @override
  Future<void> identifyUser(String userId, {Map<String, dynamic>? attributes}) async {
    lastUserId = userId;
  }

  @override
  Future<void> setUserAttribute(String key, dynamic value) async {}

  @override
  Future<void> trackEvent(String event, {Map<String, dynamic>? parameters}) async {
    events.add(MockAnalyticsEvent(name: event, parameters: parameters));
  }

  @override
  Future<void> logout() async {
    lastUserId = null;
  }
}
