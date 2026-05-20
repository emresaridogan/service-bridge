import 'package:service_bridge/src/contracts/remote_config_provider.dart';
import 'package:service_bridge/src/core/enums.dart';
import 'package:service_bridge/src/core/platform_detector.dart';

/// Manages remote config with automatic GMS/HMS routing.
///
/// Unlike other managers, this does NOT broadcast to multiple providers.
/// Instead, it routes to the appropriate provider based on [PlatformDetector]:
/// - GMS device → [gmsProvider] (e.g., Firebase Remote Config)
/// - HMS device → [hmsProvider] (e.g., Huawei Remote Config)
///
/// If the primary provider fails, it falls back to the other.
class RemoteConfigManager {
  /// Creates a [RemoteConfigManager].
  RemoteConfigManager({required PlatformDetector platformDetector, this.gmsProvider, this.hmsProvider})
    : _platformDetector = platformDetector;

  final PlatformDetector _platformDetector;

  /// Provider for Google Mobile Services devices.
  final RemoteConfigProvider? gmsProvider;

  /// Provider for Huawei Mobile Services devices.
  final RemoteConfigProvider? hmsProvider;

  RemoteConfigProvider? _activeProvider;

  /// The currently active provider based on platform detection.
  RemoteConfigProvider? get activeProvider => _activeProvider;

  /// Resolve and cache the active provider based on device platform.
  Future<RemoteConfigProvider?> _resolveProvider() async {
    if (_activeProvider != null) return _activeProvider;

    final platform = await _platformDetector.detect();

    if (platform == PlatformType.hms && hmsProvider != null) {
      _activeProvider = hmsProvider;
    } else if (gmsProvider != null) {
      _activeProvider = gmsProvider;
    } else {
      _activeProvider = hmsProvider;
    }

    return _activeProvider;
  }

  /// Get the fallback provider (the one NOT currently active).
  RemoteConfigProvider? get _fallbackProvider {
    if (_activeProvider == gmsProvider) return hmsProvider;
    if (_activeProvider == hmsProvider) return gmsProvider;
    return null;
  }

  /// Fetch and activate remote config values.
  Future<bool> fetchAndActivate() async {
    final provider = await _resolveProvider();
    if (provider == null) return false;

    try {
      return await provider.fetchAndActivate();
    } catch (_) {
      final fallback = _fallbackProvider;
      if (fallback != null && fallback.isInitialized) {
        return fallback.fetchAndActivate();
      }
      rethrow;
    }
  }

  /// Get a string value by key.
  Future<String> getString(String key, {String defaultValue = ''}) async {
    final provider = await _resolveProvider();
    if (provider == null) return defaultValue;
    return provider.getString(key, defaultValue: defaultValue);
  }

  /// Get a boolean value by key.
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    final provider = await _resolveProvider();
    if (provider == null) return defaultValue;
    return provider.getBool(key, defaultValue: defaultValue);
  }

  /// Get an integer value by key.
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    final provider = await _resolveProvider();
    if (provider == null) return defaultValue;
    return provider.getInt(key, defaultValue: defaultValue);
  }

  /// Get a double value by key.
  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    final provider = await _resolveProvider();
    if (provider == null) return defaultValue;
    return provider.getDouble(key, defaultValue: defaultValue);
  }

  /// Get all remote config values.
  Future<Map<String, dynamic>> getAll() async {
    final provider = await _resolveProvider();
    if (provider == null) return {};
    return provider.getAll();
  }

  /// Set the minimum fetch interval.
  Future<void> setMinimumFetchInterval(Duration interval) async {
    final provider = await _resolveProvider();
    if (provider == null) return;
    await provider.setMinimumFetchInterval(interval);
  }
}
