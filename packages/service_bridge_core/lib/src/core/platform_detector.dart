import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:service_bridge_core/src/core/enums.dart';
import 'package:service_bridge_core/src/core/sb_logger.dart';

/// Detects whether the device uses GMS or HMS.
///
/// Uses a hybrid approach:
/// - **Runtime**: Checks device brand via `device_info_plus`
/// - **Build-time fallback**: Uses `platformOverride` if provided
class PlatformDetector {
  /// Creates a [PlatformDetector].
  ///
  /// `platformOverride` can be set from build config to
  /// force GMS or HMS.
  /// `deviceInfoPlugin` can be injected for testing.
  PlatformDetector({PlatformType? platformOverride, DeviceInfoPlugin? deviceInfoPlugin})
    : _platformOverride = platformOverride,
      _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  final PlatformType? _platformOverride;
  final DeviceInfoPlugin _deviceInfoPlugin;
  PlatformType? _detectedPlatform;

  /// Returns the detected [PlatformType].
  ///
  /// Priority:
  /// 1. Cached result from previous detection
  /// 2. Build-time override
  /// 3. Runtime detection via device brand
  Future<PlatformType> detect() async {
    if (_detectedPlatform != null) return _detectedPlatform!;

    if (_platformOverride != null) {
      _detectedPlatform = _platformOverride;
      SBLogger.info('Platform override: ${_detectedPlatform!.name}');
      return _detectedPlatform!;
    }

    _detectedPlatform = await _runtimeDetect();
    return _detectedPlatform!;
  }

  /// Returns the cached platform type. Returns `null` if [detect] has not
  /// been called yet.
  PlatformType? get currentPlatform => _detectedPlatform;

  /// Whether the current device uses Huawei Mobile Services.
  Future<bool> get isHms async => await detect() == PlatformType.hms;

  /// Whether the current device uses Google Mobile Services.
  Future<bool> get isGms async => await detect() == PlatformType.gms;

  Future<PlatformType> _runtimeDetect() async {
    if (!Platform.isAndroid) return PlatformType.gms;

    try {
      final androidInfo = await _deviceInfoPlugin.androidInfo;
      final brand = androidInfo.brand.toLowerCase();
      final manufacturer = androidInfo.manufacturer.toLowerCase();

      if (_isHuaweiBrand(brand) || _isHuaweiBrand(manufacturer)) {
        return PlatformType.hms;
      }
    } on Exception catch (e) {
      SBLogger.warning('Device info unavailable, falling back to GMS: $e');
      // Fall back to GMS if device info cannot be retrieved.
    }

    return PlatformType.gms;
  }

  bool _isHuaweiBrand(String value) => value == 'huawei' || value == 'honor';
}
