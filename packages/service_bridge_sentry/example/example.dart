// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:service_bridge_sentry/service_bridge_sentry.dart';

/// Example demonstrating how to use service_bridge_sentry.
///
/// Sentry must be initialized via SentryFlutter.init() before
/// ServiceBridge providers can be used.
Future<void> main() async {
  await SentryFlutter.init(
    (options) => options
      ..dsn = 'https://your-dsn@sentry.io/project'
      ..tracesSampleRate = 1.0,
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      await ServiceBridge.initialize(
        ServiceBridgeConfig(
          crashReporters: [SentryCrashReporter()],
          defaultCrashProviders: {SBProvider.sentry},
          loggerProviders: [SentryLoggerProvider()],
          defaultLogProviders: {SBProvider.sentryLogger},
        ),
      );

      runApp(const MyApp());
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Sentry Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  try {
                    throw Exception('Test error for Sentry');
                  } catch (e, st) {
                    await ServiceBridge.instance.crash.reportError(e, st, extras: {'screen': 'home'});
                  }
                },
                child: const Text('Report Error'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ServiceBridge.instance.crash.reportMessage('Test message', level: SeverityLevel.warning);
                },
                child: const Text('Report Message'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ServiceBridge.instance.log.info('User action logged');
                  await ServiceBridge.instance.log.warning('Slow response');
                },
                child: const Text('Log Messages'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
