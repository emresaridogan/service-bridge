// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:service_bridge_firebase/service_bridge_firebase.dart';

/// Example demonstrating how to use service_bridge_firebase
/// with FirebaseProviderBundle for quick setup.
///
/// Make sure you have completed the Firebase setup for your project:
/// 1. Run `flutterfire configure`
/// 2. Add the generated `firebase_options.dart` to your project
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and create all providers at once
  final firebase = await FirebaseProviderBundle.initialize(
    // options: DefaultFirebaseOptions.currentPlatform,
    remoteConfigDefaults: {'feature_new_ui': false, 'max_retry_count': 3, 'welcome_message': 'Hello!'},
    remoteConfigMinimumFetchInterval: const Duration(minutes: 5),
  );

  // Configure ServiceBridge with Firebase providers
  await ServiceBridge.initialize(
    ServiceBridgeConfig(
      // Crash reporting via Crashlytics
      crashReporters: [firebase.crashReporter],
      defaultCrashProviders: {SBProvider.firebase},

      // Analytics via Firebase Analytics
      analyticsProviders: [firebase.analyticsProvider],
      defaultAnalyticsProviders: {SBProvider.firebase},

      // Remote Config (GMS devices use Firebase)
      gmsRemoteConfig: firebase.remoteConfigProvider,

      // Push notifications via FCM
      pushProviders: [firebase.pushProvider],
      defaultPushProviders: {SBProvider.firebase},

      // Logging via Crashlytics logs
      loggerProviders: [firebase.loggerProvider],
      defaultLogProviders: {SBProvider.firebaseLogger},
    ),
  );

  // Set up global error handling
  ServiceBridgeErrorHandler.runGuarded(() {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sb = ServiceBridge.instance;

    return MaterialApp(
      navigatorObservers: [ServiceBridgeNavigatorObserver(analyticsManager: sb.analytics)],
      home: Scaffold(
        appBar: AppBar(title: const Text('Firebase Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Log an analytics event
                  await sb.analytics.logEvent('button_pressed', parameters: {'button_name': 'example'});
                },
                child: const Text('Log Event'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Fetch remote config
                  await sb.remoteConfig.fetchAndActivate();
                  final message = sb.remoteConfig.getString('welcome_message');
                  debugPrint('Remote Config: $message');
                },
                child: const Text('Fetch Remote Config'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Get push notification token
                  final token = await sb.pushNotification.getToken();
                  debugPrint('FCM Token: $token');
                },
                child: const Text('Get FCM Token'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
