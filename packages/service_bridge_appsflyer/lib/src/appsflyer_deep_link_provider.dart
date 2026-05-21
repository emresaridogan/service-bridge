import 'dart:async';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:service_bridge/service_bridge.dart';

/// AppsFlyer implementation of [DeepLinkProvider].
///
/// Requires [AppsflyerSdk] to be initialized (typically via
/// [AppsFlyerAnalyticsProvider]).
class AppsFlyerDeepLinkProvider implements DeepLinkProvider {
  /// Creates an [AppsFlyerDeepLinkProvider].
  ///
  /// [sdk] should be the same instance used by [AppsFlyerAnalyticsProvider].
  AppsFlyerDeepLinkProvider({required AppsflyerSdk sdk}) : _sdk = sdk;

  final AppsflyerSdk _sdk;
  bool _initialized = false;
  final StreamController<Uri> _deepLinkController = StreamController<Uri>.broadcast();

  @override
  String get providerId => SBProvider.appsflyer.id;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _sdk.onDeepLinking((result) {
      final deepLink = result.deepLink;
      if (deepLink != null) {
        final link = deepLink.getStringValue('deep_link_value');
        if (link != null) {
          _deepLinkController.add(Uri.parse(link));
        }
      }
    });
    _initialized = true;
  }

  @override
  Future<void> dispose() async {
    await _deepLinkController.close();
    _initialized = false;
  }

  @override
  Future<Uri?> getInitialLink() async {
    // AppsFlyer handles initial links via onDeepLinking callback.
    return null;
  }

  @override
  Stream<Uri> get onDeepLink => _deepLinkController.stream;

  @override
  Future<Uri> createDeepLink(DeepLinkParams params) async {
    // AppsFlyer OneLink generation is typically done via dashboard.
    // Return the input link as fallback.
    return params.link;
  }
}
