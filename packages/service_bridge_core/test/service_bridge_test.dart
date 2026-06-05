import 'package:service_bridge_core/service_bridge_core.dart';
import 'package:service_bridge_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ServiceBridge', () {
    tearDown(() async {
      if (ServiceBridge.isInitialized) {
        await ServiceBridge.dispose();
      }
    });

    test('throws when accessing instance before initialize', () {
      expect(() => ServiceBridge.instance, throwsA(isA<StateError>()));
    });

    test('initialize creates singleton', () async {
      await ServiceBridge.initialize(const ServiceBridgeConfig());

      expect(ServiceBridge.isInitialized, isTrue);
      expect(ServiceBridge.instance, isNotNull);
    });

    test('throws when initializing twice', () async {
      await ServiceBridge.initialize(const ServiceBridgeConfig());

      expect(() => ServiceBridge.initialize(const ServiceBridgeConfig()), throwsA(isA<StateError>()));
    });

    test('dispose resets singleton', () async {
      await ServiceBridge.initialize(const ServiceBridgeConfig());
      await ServiceBridge.dispose();

      expect(ServiceBridge.isInitialized, isFalse);
    });

    test('initializes all providers', () async {
      final crash = MockCrashReporter();
      final analytics = MockAnalyticsProvider();
      final logger = MockLoggerProvider();

      await ServiceBridge.initialize(
        ServiceBridgeConfig(crashReporters: [crash], analyticsProviders: [analytics], loggerProviders: [logger]),
      );

      expect(crash.isInitialized, isTrue);
      expect(analytics.isInitialized, isTrue);
      expect(logger.isInitialized, isTrue);
    });

    test('dispose disposes all providers', () async {
      final crash = MockCrashReporter();
      final analytics = MockAnalyticsProvider();

      await ServiceBridge.initialize(ServiceBridgeConfig(crashReporters: [crash], analyticsProviders: [analytics]));

      await ServiceBridge.dispose();

      expect(crash.isInitialized, isFalse);
      expect(analytics.isInitialized, isFalse);
    });

    test('provides access to all managers', () async {
      await ServiceBridge.initialize(const ServiceBridgeConfig());

      final sm = ServiceBridge.instance;
      expect(sm.crash, isNotNull);
      expect(sm.analytics, isNotNull);
      expect(sm.remoteConfig, isNotNull);
      expect(sm.pushNotification, isNotNull);
      expect(sm.log, isNotNull);
      expect(sm.deepLink, isNotNull);
      expect(sm.userTracking, isNotNull);
      expect(sm.platform, isNotNull);
    });

    test('end-to-end: crash reporting through ServiceBridge', () async {
      final crash = _EnumMockCrashReporter(SBProvider.firebase);

      await ServiceBridge.initialize(
        ServiceBridgeConfig(crashReporters: [crash], defaultCrashProviders: {SBProvider.firebase}),
      );

      await ServiceBridge.instance.crash.reportError(Exception('test'), StackTrace.current, only: {SBProvider.firebase});

      expect(crash.reports, hasLength(1));
    });
  });
}

class _EnumMockCrashReporter extends MockCrashReporter {
  _EnumMockCrashReporter(this._provider);

  final SBProvider _provider;

  @override
  String get providerId => _provider.id;
}
