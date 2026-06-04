// ignore_for_file: depend_on_referenced_packages

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:service_bridge/service_bridge.dart';

/// Full integration example using the service_bridge umbrella package.
///
/// This demonstrates combining Firebase, Sentry, and AppsFlyer providers
/// in a single application with ServiceBridge.
Future<void> main() async {
  await SentryFlutter.init(
    (options) => options
      ..dsn = 'https://your-dsn@sentry.io/project'
      ..tracesSampleRate = 1.0,
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase and create all providers
      final firebase = await FirebaseProviderBundle.initialize(
        // options: DefaultFirebaseOptions.currentPlatform,
        remoteConfigDefaults: {'feature_new_ui': false},
      );

      // Create AppsFlyer analytics provider
      final appsFlyerAnalytics = AppsFlyerAnalyticsProvider(
        appsFlyerOptions: AppsFlyerOptions(afDevKey: 'YOUR_DEV_KEY', appId: 'YOUR_APP_ID'),
      );

      // Initialize ServiceBridge with all providers
      await ServiceBridge.initialize(
        ServiceBridgeConfig(
          crashReporters: [firebase.crashReporter, SentryCrashReporter()],
          defaultCrashProviders: {SBProvider.firebase, SBProvider.sentry},
          analyticsProviders: [firebase.analyticsProvider, appsFlyerAnalytics],
          defaultAnalyticsProviders: {SBProvider.firebase, SBProvider.appsflyer},
          gmsRemoteConfig: firebase.remoteConfigProvider,
          hmsRemoteConfig: HuaweiRemoteConfigProvider(),
          pushProviders: [firebase.pushProvider],
          defaultPushProviders: {SBProvider.firebase},
          loggerProviders: [firebase.loggerProvider, SentryLoggerProvider()],
          defaultLogProviders: {SBProvider.firebaseLogger, SBProvider.sentryLogger},
        ),
      );

      // Wrap app with error handler
      ServiceBridgeErrorHandler.runGuarded(() {
        runApp(const MyApp());
      });
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sb = ServiceBridge.instance;

    return MaterialApp(
      navigatorObservers: [ServiceBridgeNavigatorObserver(analyticsManager: sb.analytics)],
      home: Scaffold(
        appBar: AppBar(title: const Text('Service Bridge Full Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Analytics event sent to both Firebase and AppsFlyer
                  await sb.analytics.logEvent('purchase', parameters: {'item_id': 'sku_001', 'price': 29.99});
                },
                child: const Text('Log Analytics Event'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Crash reported to both Firebase Crashlytics and Sentry
                  try {
                    throw Exception('Test crash');
                  } catch (e, st) {
                    await sb.crash.reportError(e, st);
                  }
                },
                child: const Text('Report Crash'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Remote config (auto-routed to Firebase or Huawei)
                  await sb.remoteConfig.fetchAndActivate();
                  final enabled = sb.remoteConfig.getBool('feature_new_ui');
                  debugPrint('Feature enabled: $enabled');
                },
                child: const Text('Fetch Remote Config'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
