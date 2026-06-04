// ignore_for_file: depend_on_referenced_packages

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/material.dart';
import 'package:service_bridge_appsflyer/service_bridge_appsflyer.dart';

/// Example demonstrating how to use service_bridge_appsflyer.
///
/// Replace 'YOUR_DEV_KEY' and 'YOUR_APP_ID' with your actual AppsFlyer credentials.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create the AppsFlyer analytics provider
  final appsFlyerAnalytics = AppsFlyerAnalyticsProvider(
    appsFlyerOptions: AppsFlyerOptions(afDevKey: 'YOUR_DEV_KEY', appId: 'YOUR_APP_ID', showDebug: true),
  );

  // Initialize to get the SDK instance
  await appsFlyerAnalytics.initialize();
  final sdk = appsFlyerAnalytics.sdk!;

  // Create deep link and user tracking providers using the shared SDK
  final appsFlyerDeepLink = AppsFlyerDeepLinkProvider(sdk: sdk);
  final appsFlyerUserTracker = AppsFlyerUserTracker(sdk: sdk);

  await ServiceBridge.initialize(
    ServiceBridgeConfig(
      analyticsProviders: [appsFlyerAnalytics],
      defaultAnalyticsProviders: {SBProvider.appsflyer},
      deepLinkProviders: [appsFlyerDeepLink],
      defaultDeepLinkProviders: {SBProvider.appsflyer},
      userTrackers: [appsFlyerUserTracker],
      defaultUserTrackingProviders: {SBProvider.appsflyer},
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Listen for deep links
    ServiceBridge.instance.deepLink.onDeepLink.listen((uri) {
      debugPrint('Deep link received: $uri');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('AppsFlyer Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await ServiceBridge.instance.analytics.logEvent(
                    'purchase',
                    parameters: {'revenue': 29.99, 'currency': 'USD', 'item_id': 'sku_001'},
                  );
                },
                child: const Text('Log Purchase Event'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ServiceBridge.instance.userTracking.identifyUser('user_123', attributes: {'plan': 'premium'});
                },
                child: const Text('Identify User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
