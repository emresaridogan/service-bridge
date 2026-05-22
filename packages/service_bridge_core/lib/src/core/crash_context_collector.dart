import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:service_bridge_core/src/core/enums.dart';
import 'package:service_bridge_core/src/core/sb_logger.dart';

/// Collects device, platform, and runtime context for crash reports.
///
/// Caches static device info after first collection to avoid repeated
/// platform channel calls.
///
/// Usage in [CrashManager]:
/// ```dart
/// final context = await CrashContextCollector.instance.collect();
/// // {device_brand: Samsung, device_model: SM-G998, os_version: 14, ...}
/// ```
class CrashContextCollector {
  /// Creates a [CrashContextCollector].
  ///
  /// [deviceInfoPlugin] can be injected for testing.
  CrashContextCollector({DeviceInfoPlugin? deviceInfoPlugin, Connectivity? connectivity})
    : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin(),
      _connectivity = connectivity ?? Connectivity();

  static CrashContextCollector? _instance;

  /// The singleton instance. Created on first access.
  static CrashContextCollector get instance => _instance ??= CrashContextCollector();

  /// Replace the singleton (useful for testing).
  @visibleForTesting
  static set instance(CrashContextCollector value) => _instance = value;

  /// Reset the singleton instance.
  @visibleForTesting
  static void reset() => _instance = null;

  final DeviceInfoPlugin _deviceInfoPlugin;
  final Connectivity _connectivity;
  Map<String, dynamic>? _cachedDeviceInfo;
  Map<String, dynamic>? _cachedAppInfo;
  PlatformType? _platformType;

  /// Set the detected platform type. Called by [ServiceBridge] during init.
  void setPlatformType(PlatformType type) => _platformType = type;

  /// Collect all available context for a crash report.
  ///
  /// Static device/app info is cached after first call.
  /// Dynamic info (connectivity, timestamp) is collected fresh each time.
  Future<Map<String, dynamic>> collect() async {
    final context = <String, dynamic>{};

    // Static device info (cached)
    _cachedDeviceInfo ??= await _collectDeviceInfo();
    context.addAll(_cachedDeviceInfo!);

    // Static app info (cached)
    _cachedAppInfo ??= await _collectAppInfo();
    context.addAll(_cachedAppInfo!);

    // Dynamic runtime info (fresh each call)
    context.addAll(_collectRuntimeInfo());

    // Dynamic connectivity info (fresh each call)
    context.addAll(await _collectConnectivityInfo());

    return context;
  }

  Future<Map<String, dynamic>> _collectDeviceInfo() async {
    final info = <String, dynamic>{};

    try {
      if (Platform.isAndroid) {
        final android = await _deviceInfoPlugin.androidInfo;
        info['sb_os'] = 'Android';
        info['sb_os_version'] = android.version.release;
        info['sb_sdk_int'] = android.version.sdkInt;
        info['sb_device_brand'] = android.brand;
        info['sb_device_manufacturer'] = android.manufacturer;
        info['sb_device_model'] = android.model;
        info['sb_device'] = android.device;
        info['sb_hardware'] = android.hardware;
        info['sb_product'] = android.product;
        info['sb_is_physical'] = android.isPhysicalDevice;
        info['sb_android_id'] = android.id;
        info['sb_fingerprint'] = android.fingerprint;
        info['sb_platform_type'] = _platformType?.name ?? _detectPlatformFromBrand(android.brand);
      } else if (Platform.isIOS) {
        final ios = await _deviceInfoPlugin.iosInfo;
        info['sb_os'] = 'iOS';
        info['sb_os_version'] = ios.systemVersion;
        info['sb_device_model'] = ios.utsname.machine;
        info['sb_device_name'] = ios.name;
        info['sb_device_brand'] = 'Apple';
        info['sb_is_physical'] = ios.isPhysicalDevice;
        info['sb_system_name'] = ios.systemName;
        info['sb_platform_type'] = 'gms';
      }
    } on Exception catch (e) {
      SBLogger.warning('Failed to collect device info: $e');
    }

    return info;
  }

  Map<String, dynamic> _collectRuntimeInfo() {
    return {
      'sb_app_mode': kReleaseMode
          ? 'release'
          : kProfileMode
          ? 'profile'
          : 'debug',
      'sb_dart_version': Platform.version.split(' ').first,
      'sb_locale': Platform.localeName,
      'sb_timestamp': DateTime.now().toUtc().toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> _collectAppInfo() async {
    final info = <String, dynamic>{};
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      info['sb_app_name'] = packageInfo.appName;
      info['sb_app_version'] = packageInfo.version;
      info['sb_build_number'] = packageInfo.buildNumber;
      info['sb_package_name'] = packageInfo.packageName;
    } on Exception catch (e) {
      SBLogger.warning('Failed to collect app info: $e');
    }
    return info;
  }

  Future<Map<String, dynamic>> _collectConnectivityInfo() async {
    final info = <String, dynamic>{};
    try {
      final results = await _connectivity.checkConnectivity();
      final types = results.map(_connectivityName).toList();
      info['sb_connectivity'] = types.join(', ');
      info['sb_has_wifi'] = results.contains(ConnectivityResult.wifi);
      info['sb_has_mobile'] = results.contains(ConnectivityResult.mobile);
      info['sb_has_vpn'] = results.contains(ConnectivityResult.vpn);
      info['sb_is_offline'] = results.contains(ConnectivityResult.none);
    } on Exception catch (e) {
      SBLogger.warning('Failed to collect connectivity info: $e');
      info['sb_connectivity'] = 'unknown';
    }
    return info;
  }

  String _connectivityName(ConnectivityResult result) {
    return switch (result) {
      ConnectivityResult.wifi => 'wifi',
      ConnectivityResult.mobile => 'mobile',
      ConnectivityResult.ethernet => 'ethernet',
      ConnectivityResult.vpn => 'vpn',
      ConnectivityResult.bluetooth => 'bluetooth',
      ConnectivityResult.none => 'none',
      ConnectivityResult.other => 'other',
      _ => 'other',
    };
  }

  String _detectPlatformFromBrand(String brand) {
    final lower = brand.toLowerCase();
    if (lower == 'huawei' || lower == 'honor') return 'hms';
    return 'gms';
  }
}
