import 'package:service_bridge/service_bridge.dart';
import 'package:service_bridge/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrashManager', () {
    late MockCrashReporter firebaseCrash;
    late MockCrashReporter sentryCrash;
    late CrashManager manager;

    setUp(() {
      firebaseCrash = MockCrashReporter();
      sentryCrash = MockCrashReporter();
    });

    Future<void> initProviders({Set<String> defaults = const {'mock_crash_1', 'mock_crash_2'}}) async {
      firebaseCrash = _NamedMockCrashReporter('mock_crash_1');
      sentryCrash = _NamedMockCrashReporter('mock_crash_2');
      await firebaseCrash.initialize();
      await sentryCrash.initialize();
      manager = CrashManager(providers: [firebaseCrash, sentryCrash], defaultProviderIds: defaults);
    }

    test('reportError dispatches to all default providers', () async {
      await initProviders();

      final error = Exception('test');
      final stack = StackTrace.current;
      await manager.reportError(error, stack);

      expect(firebaseCrash.reports, hasLength(1));
      expect(sentryCrash.reports, hasLength(1));
    });

    test('reportError with only filters to specified providers', () async {
      await initProviders();

      await manager.reportError(Exception('test'), StackTrace.current, only: {'mock_crash_1'});

      expect(firebaseCrash.reports, hasLength(1));
      expect(sentryCrash.reports, isEmpty);
    });

    test('reportError with exclude removes specified providers', () async {
      await initProviders();

      await manager.reportError(Exception('test'), StackTrace.current, exclude: {'mock_crash_2'});

      expect(firebaseCrash.reports, hasLength(1));
      expect(sentryCrash.reports, isEmpty);
    });

    test('skips uninitialized providers', () async {
      firebaseCrash = _NamedMockCrashReporter('mock_crash_1');
      sentryCrash = _NamedMockCrashReporter('mock_crash_2');
      await firebaseCrash.initialize();
      // sentryCrash NOT initialized

      manager = CrashManager(providers: [firebaseCrash, sentryCrash], defaultProviderIds: {'mock_crash_1', 'mock_crash_2'});

      await manager.reportError(Exception('test'), StackTrace.current);

      expect(firebaseCrash.reports, hasLength(1));
      expect(sentryCrash.reports, isEmpty);
    });
  });

  group('AnalyticsManager', () {
    late _NamedMockAnalyticsProvider provider1;
    late _NamedMockAnalyticsProvider provider2;
    late AnalyticsManager manager;

    setUp(() async {
      provider1 = _NamedMockAnalyticsProvider('analytics_1');
      provider2 = _NamedMockAnalyticsProvider('analytics_2');
      await provider1.initialize();
      await provider2.initialize();
      manager = AnalyticsManager(providers: [provider1, provider2], defaultProviderIds: {'analytics_1', 'analytics_2'});
    });

    test('logEvent dispatches to all default providers', () async {
      await manager.logEvent('purchase', parameters: {'item': 'boat'});

      expect(provider1.events, hasLength(1));
      expect(provider1.events.first.name, 'purchase');
      expect(provider2.events, hasLength(1));
    });

    test('logEvent with only filters correctly', () async {
      await manager.logEvent('click', only: {'analytics_1'});

      expect(provider1.events, hasLength(1));
      expect(provider2.events, isEmpty);
    });

    test('logScreenView dispatches to all providers', () async {
      await manager.logScreenView('HomeScreen');

      expect(provider1.screenViews, contains('HomeScreen'));
      expect(provider2.screenViews, contains('HomeScreen'));
    });
  });

  group('LogManager', () {
    late _NamedMockLoggerProvider logger1;
    late _NamedMockLoggerProvider logger2;
    late LogManager manager;

    setUp(() async {
      logger1 = _NamedMockLoggerProvider('logger_1');
      logger2 = _NamedMockLoggerProvider('logger_2');
      await logger1.initialize();
      await logger2.initialize();
      manager = LogManager(providers: [logger1, logger2], defaultProviderIds: {'logger_1', 'logger_2'});
    });

    test('error dispatches to all providers', () async {
      await manager.error('Payment failed');

      expect(logger1.logs, hasLength(1));
      expect(logger1.logs.first.level, LogLevel.error);
      expect(logger2.logs, hasLength(1));
    });

    test('debug dispatches to all providers', () async {
      await manager.debug('Debug message');

      expect(logger1.logs.first.level, LogLevel.debug);
    });

    test('exclude works for log calls', () async {
      await manager.info('test', exclude: {'logger_2'});

      expect(logger1.logs, hasLength(1));
      expect(logger2.logs, isEmpty);
    });
  });

  group('UserTrackingManager', () {
    late _NamedMockUserTracker tracker1;
    late _NamedMockUserTracker tracker2;
    late UserTrackingManager manager;

    setUp(() async {
      tracker1 = _NamedMockUserTracker('tracker_1');
      tracker2 = _NamedMockUserTracker('tracker_2');
      await tracker1.initialize();
      await tracker2.initialize();
      manager = UserTrackingManager(providers: [tracker1, tracker2], defaultProviderIds: {'tracker_1', 'tracker_2'});
    });

    test('identifyUser dispatches to all providers', () async {
      await manager.identifyUser('user-123');

      expect(tracker1.lastUserId, 'user-123');
      expect(tracker2.lastUserId, 'user-123');
    });

    test('logout dispatches to all providers', () async {
      await manager.identifyUser('user-123');
      await manager.logout();

      expect(tracker1.lastUserId, isNull);
      expect(tracker2.lastUserId, isNull);
    });

    test('trackEvent with only', () async {
      await manager.trackEvent('purchase', parameters: {'amount': 100}, only: {'tracker_1'});

      expect(tracker1.events, hasLength(1));
      expect(tracker2.events, isEmpty);
    });
  });

  group('ProviderResolver', () {
    late List<_NamedMockCrashReporter> providers;

    setUp(() async {
      providers = [_NamedMockCrashReporter('a'), _NamedMockCrashReporter('b'), _NamedMockCrashReporter('c')];
      for (final p in providers) {
        await p.initialize();
      }
    });

    test('returns all defaults when no override', () {
      final result = ProviderResolver.resolve(providers, defaultProviderIds: {'a', 'b', 'c'});
      expect(result, hasLength(3));
    });

    test('only filters to specified IDs', () {
      final result = ProviderResolver.resolve(providers, defaultProviderIds: {'a', 'b', 'c'}, only: {'a'});
      expect(result, hasLength(1));
      expect(result.first.providerId, 'a');
    });

    test('exclude removes specified IDs', () {
      final result = ProviderResolver.resolve(providers, defaultProviderIds: {'a', 'b', 'c'}, exclude: {'c'});
      expect(result, hasLength(2));
      expect(result.map((p) => p.providerId), containsAll(['a', 'b']));
    });

    test('filters out uninitialized providers', () async {
      await providers[1].dispose(); // b is now uninitialized

      final result = ProviderResolver.resolve(providers, defaultProviderIds: {'a', 'b', 'c'});
      expect(result, hasLength(2));
      expect(result.map((p) => p.providerId), isNot(contains('b')));
    });

    test('only takes precedence over defaults', () {
      final result = ProviderResolver.resolve(providers, defaultProviderIds: {'a'}, only: {'b', 'c'});
      expect(result, hasLength(2));
      expect(result.map((p) => p.providerId), containsAll(['b', 'c']));
    });
  });

  group('RemoteConfigManager', () {
    late MockRemoteConfigProvider gmsProvider;
    late MockRemoteConfigProvider hmsProvider;

    setUp(() async {
      gmsProvider = MockRemoteConfigProvider();
      hmsProvider = MockRemoteConfigProvider();
      await gmsProvider.initialize();
      await hmsProvider.initialize();
    });

    test('uses GMS provider by default on non-Huawei', () async {
      final detector = PlatformDetector(platformOverride: PlatformType.gms);
      final manager = RemoteConfigManager(platformDetector: detector, gmsProvider: gmsProvider, hmsProvider: hmsProvider);

      gmsProvider.values['feature_x'] = true;

      final result = await manager.getBool('feature_x');
      expect(result, isTrue);
      expect(manager.activeProvider?.providerId, gmsProvider.providerId);
    });

    test('uses HMS provider on Huawei devices', () async {
      final detector = PlatformDetector(platformOverride: PlatformType.hms);
      final manager = RemoteConfigManager(platformDetector: detector, gmsProvider: gmsProvider, hmsProvider: hmsProvider);

      hmsProvider.values['feature_x'] = 'huawei_value';

      final result = await manager.getString('feature_x');
      expect(result, 'huawei_value');
    });

    test('returns default when no provider available', () async {
      final detector = PlatformDetector(platformOverride: PlatformType.gms);
      final manager = RemoteConfigManager(platformDetector: detector);

      final result = await manager.getString('key', defaultValue: 'fallback');
      expect(result, 'fallback');
    });
  });
}

// -- Named mock variants for testing with custom providerIds --

class _NamedMockCrashReporter extends MockCrashReporter {
  _NamedMockCrashReporter(this._id);
  final String _id;

  @override
  String get providerId => _id;
}

class _NamedMockAnalyticsProvider extends MockAnalyticsProvider {
  _NamedMockAnalyticsProvider(this._id);
  final String _id;

  @override
  String get providerId => _id;
}

class _NamedMockLoggerProvider extends MockLoggerProvider {
  _NamedMockLoggerProvider(this._id);
  final String _id;

  @override
  String get providerId => _id;
}

class _NamedMockUserTracker extends MockUserTracker {
  _NamedMockUserTracker(this._id);
  final String _id;

  @override
  String get providerId => _id;
}
