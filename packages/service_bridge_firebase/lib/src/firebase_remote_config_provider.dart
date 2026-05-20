import 'package:service_bridge/service_bridge.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Firebase Remote Config implementation of [RemoteConfigProvider].
class FirebaseRemoteConfigProvider implements RemoteConfigProvider {
  /// Creates a [FirebaseRemoteConfigProvider].
  ///
  /// [defaults] are the default values before remote config is fetched.
  /// [fetchTimeout] is the timeout for fetching remote config.
  /// [minimumFetchInterval] is the minimum time between fetches.
  FirebaseRemoteConfigProvider({
    FirebaseRemoteConfig? remoteConfig,
    Map<String, dynamic>? defaults,
    Duration fetchTimeout = const Duration(seconds: 10),
    Duration minimumFetchInterval = const Duration(hours: 1),
  }) : _remoteConfig = remoteConfig,
       _defaults = defaults ?? const {},
       _fetchTimeout = fetchTimeout,
       _minimumFetchInterval = minimumFetchInterval;

  FirebaseRemoteConfig? _remoteConfig;
  final Map<String, dynamic> _defaults;
  final Duration _fetchTimeout;
  Duration _minimumFetchInterval;
  bool _initialized = false;

  @override
  String get providerId => 'firebase';

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _remoteConfig ??= FirebaseRemoteConfig.instance;

    await _remoteConfig!.setConfigSettings(RemoteConfigSettings(fetchTimeout: _fetchTimeout, minimumFetchInterval: _minimumFetchInterval));

    if (_defaults.isNotEmpty) {
      await _remoteConfig!.setDefaults(_defaults.map(MapEntry.new));
    }

    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }

  @override
  Future<bool> fetchAndActivate() async {
    return _remoteConfig!.fetchAndActivate();
  }

  @override
  String getString(String key, {String defaultValue = ''}) {
    final value = _remoteConfig!.getString(key);
    return value.isEmpty ? defaultValue : value;
  }

  @override
  bool getBool(String key, {bool defaultValue = false}) {
    return _remoteConfig!.getBool(key);
  }

  @override
  int getInt(String key, {int defaultValue = 0}) {
    return _remoteConfig!.getInt(key);
  }

  @override
  double getDouble(String key, {double defaultValue = 0.0}) {
    return _remoteConfig!.getDouble(key);
  }

  @override
  Map<String, dynamic> getAll() {
    return _remoteConfig!.getAll().map((key, value) => MapEntry(key, value.asString()));
  }

  @override
  Future<void> setMinimumFetchInterval(Duration interval) async {
    _minimumFetchInterval = interval;
    await _remoteConfig!.setConfigSettings(RemoteConfigSettings(fetchTimeout: _fetchTimeout, minimumFetchInterval: interval));
  }
}
