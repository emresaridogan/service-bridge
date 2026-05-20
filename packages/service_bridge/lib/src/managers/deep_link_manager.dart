import 'dart:async';

import 'package:service_bridge/src/contracts/deep_link_provider.dart';
import 'package:service_bridge/src/core/provider_resolver.dart';
import 'package:service_bridge/src/managers/push_notification_manager.dart';
import 'package:service_bridge/src/models/deep_link_params.dart';

/// Manages multiple [DeepLinkProvider] providers.
class DeepLinkManager {
  /// Creates a [DeepLinkManager].
  DeepLinkManager({required List<DeepLinkProvider> providers, Set<String> defaultProviderIds = const {}})
    : _providers = providers,
      _defaultProviderIds = defaultProviderIds;

  final List<DeepLinkProvider> _providers;
  final Set<String> _defaultProviderIds;

  /// All registered deep link providers.
  List<DeepLinkProvider> get providers => List.unmodifiable(_providers);

  /// Get the initial deep link from the first provider that returns one.
  Future<Uri?> getInitialLink() async {
    final targets = ProviderResolver.resolve(_providers, defaultProviderIds: _defaultProviderIds);
    for (final provider in targets) {
      final link = await provider.getInitialLink();
      if (link != null) return link;
    }
    return null;
  }

  /// Merged stream of deep links from all active providers.
  Stream<Uri> get onDeepLink {
    final targets = ProviderResolver.resolve(_providers, defaultProviderIds: _defaultProviderIds);
    return StreamGroup.merge(targets.map((p) => p.onDeepLink));
  }

  /// Create a deep link using a specific provider.
  ///
  /// [providerId] determines which provider generates the link.
  /// Falls back to the first available provider if not specified.
  Future<Uri?> createDeepLink(DeepLinkParams params, {String? providerId}) async {
    final targets = ProviderResolver.resolve(
      _providers,
      defaultProviderIds: _defaultProviderIds,
      only: providerId != null ? {providerId} : null,
    );
    if (targets.isEmpty) return null;
    return targets.first.createDeepLink(params);
  }
}
