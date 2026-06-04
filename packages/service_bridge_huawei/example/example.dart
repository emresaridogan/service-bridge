// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:service_bridge_huawei/service_bridge_huawei.dart';

/// Example demonstrating how to use service_bridge_huawei.
///
/// Note: This package currently contains stub implementations.
/// HMS SDK dependencies need to be enabled for full functionality.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ServiceBridge.initialize(
    ServiceBridgeConfig(
      hmsRemoteConfig: HuaweiRemoteConfigProvider(defaults: {'feature_flag': false, 'banner_text': 'Welcome'}),
      pushProviders: [HuaweiPushProvider()],
      defaultPushProviders: {SBProvider.huawei},
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
        appBar: AppBar(title: const Text('Huawei HMS Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await ServiceBridge.instance.remoteConfig.fetchAndActivate();
                  final value = ServiceBridge.instance.remoteConfig.getString('banner_text');
                  debugPrint('Remote Config value: $value');
                },
                child: const Text('Fetch Remote Config'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final token = await ServiceBridge.instance.pushNotification.getToken();
                  debugPrint('HMS Push Token: $token');
                },
                child: const Text('Get Push Token'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
