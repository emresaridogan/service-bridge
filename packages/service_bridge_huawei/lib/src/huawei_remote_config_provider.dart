import 'package:service_bridge_core/service_bridge_core.dart';

/// Huawei AGConnect Remote Config implementation of [RemoteConfigProvider].
///
/// Used on Huawei/Honor devices without GMS as a replacement for
/// Firebase Remote Config.
/// Replace placeholder calls with actual Huawei AGConnect SDK methods.
class HuaweiRemoteConfigProvider implements RemoteConfigProvider {
  /// Creates a [HuaweiRemoteConfigProvider].
  ///
  /// [defaults] are the default values before remote config is fetched.
  HuaweiRemoteConfigProvider({Map<String, dynamic>? defaults}) : _defaults = defaults ?? const {};

  final Map<String, dynamic> _defaults;
  final Map<String, dynamic> _values = {};
  bool _initialized = false;

  @override
  String get providerId => SBProvider.huawei.id;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    // TODO: Initialize AGConnect Remote Config
    // final config = AGConnectConfig.instance;
    // config.applyDefault(_defaults);
    _values.addAll(_defaults);
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  Future<bool> fetchAndActivate() async {
    // TODO: final config = AGConnectConfig.instance;
    // await config.fetch();
    // await config.apply(config.loadLastFetched());
    // _values.addAll(config.getMergedAll());
    return true;
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    return (_values[key] as String?) ?? defaultValue;
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    return (_values[key] as bool?) ?? defaultValue;
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    return (_values[key] as int?) ?? defaultValue;
  }

  @override
  double getDouble(String key, {double defaultValue = 0.0}) {
    return (_values[key] as double?) ?? defaultValue;
  }

  @override
  Map<String, dynamic> getAll() => Map.unmodifiable(_values);

  @override
  Future<void> setMinimumFetchInterval(Duration interval) async {
    // TODO: AGConnectConfig.instance.setFetchInterval(interval);
  }
}
