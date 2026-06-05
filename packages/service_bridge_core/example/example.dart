// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:service_bridge_core/service_bridge_core.dart';
import 'package:service_bridge_core/testing.dart';

/// This example demonstrates how to initialize and use ServiceBridge
/// with mock providers for illustration purposes.
///
/// In a real application, you would use concrete provider implementations
/// from packages like service_bridge_firebase, service_bridge_sentry, etc.
void main() {
  // Wrap your app with the error handler for comprehensive crash capture
  ServiceBridgeErrorHandler.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize ServiceBridge with your providers
    await ServiceBridge.initialize(
      ServiceBridgeConfig(
        // Crash reporting — reports are broadcast to all providers
        crashReporters: [MockCrashReporter()],
        defaultCrashProviders: {SBProvider.firebase},

        // Analytics — events are fanned out to all providers
        analyticsProviders: [MockAnalyticsProvider()],
        defaultAnalyticsProviders: {SBProvider.firebase},
        // Remote Config — routes to single provider based on GMS/HMS
        gmsRemoteConfig: MockRemoteConfigProvider(),

        // Push notifications
        pushProviders: [MockPushNotificationProvider()],
        defaultPushProviders: {SBProvider.firebase},

        // Logging
        loggerProviders: [MockLoggerProvider()],
        defaultLogProviders: {SBProvider.firebase},

        // Deep links
        deepLinkProviders: [MockDeepLinkProvider()],
        defaultDeepLinkProviders: {SBProvider.appsflyer},

        // User tracking
        userTrackers: [MockUserTracker()],
        defaultUserTrackingProviders: {SBProvider.insider},
      ),
    );

    runApp(const ExampleApp());
  });
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Add the navigator observer for automatic screen view logging
      navigatorObservers: [ServiceBridgeNavigatorObserver(analyticsManager: ServiceBridge.instance.analytics)],
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service Bridge Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: () => _logAnalyticsEvent(), child: const Text('Log Analytics Event')),
            ElevatedButton(onPressed: () => _reportCrash(), child: const Text('Report Crash')),
            ElevatedButton(onPressed: () => _logMessage(), child: const Text('Log Message')),
            ElevatedButton(onPressed: () => _identifyUser(), child: const Text('Identify User')),
          ],
        ),
      ),
    );
  }

  Future<void> _logAnalyticsEvent() async {
    final sb = ServiceBridge.instance;

    // Log to all default analytics providers
    await sb.analytics.logEvent('button_click', parameters: {'button': 'purchase'});

    // Log only to Firebase
    await sb.analytics.logEvent('debug_event', only: {SBProvider.firebase});

    // Log to all except AppsFlyer
    await sb.analytics.logEvent('screen_action', exclude: {SBProvider.appsflyer});
  }

  Future<void> _reportCrash() async {
    final sb = ServiceBridge.instance;

    try {
      throw Exception('Something went wrong');
    } catch (e, st) {
      await sb.crash.reportError(e, st);
    }
  }

  Future<void> _logMessage() async {
    final sb = ServiceBridge.instance;

    await sb.log.info('User opened home page');
    await sb.log.warning('Cache miss', extras: {'key': 'user_profile'});
    await sb.log.error('API request failed');
  }

  Future<void> _identifyUser() async {
    final sb = ServiceBridge.instance;

    await sb.userTracking.identifyUser('user_123', attributes: {'plan': 'premium', 'region': 'TR'});
  }
}
