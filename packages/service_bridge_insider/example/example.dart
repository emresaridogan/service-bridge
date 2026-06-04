// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:service_bridge_insider/service_bridge_insider.dart';

/// Example demonstrating how to use service_bridge_insider.
///
/// Note: This package currently contains stub implementations.
/// Method bodies will be connected when the Insider SDK is available.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceBridge.initialize(
    ServiceBridgeConfig(
      analyticsProviders: [InsiderAnalyticsProvider()],
      defaultAnalyticsProviders: {SBProvider.insider},
      pushProviders: [InsiderPushProvider()],
      defaultPushProviders: {SBProvider.insider},
      userTrackers: [InsiderUserTracker()],
      defaultUserTrackingProviders: {SBProvider.insider},
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Insider Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await ServiceBridge.instance.analytics.logEvent('product_viewed', parameters: {'product_id': '123'});
                },
                child: const Text('Log Event'),
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
