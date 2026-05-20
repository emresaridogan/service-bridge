import 'package:service_bridge/service_bridge.dart';
import 'package:service_bridge/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServiceManager', () {
    tearDown(() async {
      if (ServiceManager.isInitialized) {
        await ServiceManager.dispose();
      }
    });

    test('throws when accessing instance before initialize', () {
      expect(() => ServiceManager.instance, throwsA(isA<StateError>()));
    });

    test('initialize creates singleton', () async {
      await ServiceManager.initialize(const ServiceManagerConfig());

      expect(ServiceManager.isInitialized, isTrue);
      expect(ServiceManager.instance, isNotNull);
    });

    test('throws when initializing twice', () async {
      await ServiceManager.initialize(const ServiceManagerConfig());

      expect(() => ServiceManager.initialize(const ServiceManagerConfig()), throwsA(isA<StateError>()));
    });

    test('dispose resets singleton', () async {
      await ServiceManager.initialize(const ServiceManagerConfig());
      await ServiceManager.dispose();

      expect(ServiceManager.isInitialized, isFalse);
    });

    test('initializes all providers', () async {
      final crash = MockCrashReporter();
      final analytics = MockAnalyticsProvider();
      final logger = MockLoggerProvider();

      await ServiceManager.initialize(
        ServiceManagerConfig(crashReporters: [crash], analyticsProviders: [analytics], loggerProviders: [logger]),
      );

      expect(crash.isInitialized, isTrue);
      expect(analytics.isInitialized, isTrue);
      expect(logger.isInitialized, isTrue);
    });

    test('dispose disposes all providers', () async {
      final crash = MockCrashReporter();
      final analytics = MockAnalyticsProvider();

      await ServiceManager.initialize(ServiceManagerConfig(crashReporters: [crash], analyticsProviders: [analytics]));

      await ServiceManager.dispose();

      expect(crash.isInitialized, isFalse);
      expect(analytics.isInitialized, isFalse);
    });

    test('provides access to all managers', () async {
      await ServiceManager.initialize(const ServiceManagerConfig());

      final sm = ServiceManager.instance;
      expect(sm.crash, isNotNull);
      expect(sm.analytics, isNotNull);
      expect(sm.remoteConfig, isNotNull);
      expect(sm.pushNotification, isNotNull);
      expect(sm.log, isNotNull);
      expect(sm.deepLink, isNotNull);
      expect(sm.userTracking, isNotNull);
      expect(sm.platform, isNotNull);
    });

    test('end-to-end: crash reporting through ServiceManager', () async {
      final crash = MockCrashReporter();

      await ServiceManager.initialize(ServiceManagerConfig(crashReporters: [crash], defaultCrashProviders: {'mock_crash'}));

      await ServiceManager.instance.crash.reportError(Exception('test'), StackTrace.current);

      expect(crash.reports, hasLength(1));
    });
  });
}
