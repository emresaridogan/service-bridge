import 'package:service_bridge/src/contracts/base_service_provider.dart';

/// Contract for remote config providers.
///
/// Unlike other contracts, remote config does NOT broadcast to multiple
/// providers. Instead, `RemoteConfigManager` uses `PlatformDetector` to
/// route to the appropriate provider (GMS → Firebase, HMS → Huawei).
///
/// Implementations: FirebaseRemoteConfigProvider, HuaweiRemoteConfigProvider
abstract class RemoteConfigProvider extends BaseServiceProvider {
  /// Fetch remote config values from the server and activate them.
  Future<bool> fetchAndActivate();

  /// Get a string value by key.
  String getString(String key, {String defaultValue = ''});

  /// Get a boolean value by key.
  bool getBool(String key, {bool defaultValue = false});

  /// Get an integer value by key.
  int getInt(String key, {int defaultValue = 0});

  /// Get a double value by key.
  double getDouble(String key, {double defaultValue = 0.0});

  /// Get all remote config values as a map.
  Map<String, dynamic> getAll();

  /// Set the minimum fetch interval between remote config fetches.
  Future<void> setMinimumFetchInterval(Duration interval);
}
