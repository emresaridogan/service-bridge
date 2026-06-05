import 'package:service_bridge_core/src/contracts/base_service_provider.dart';
import 'package:service_bridge_core/src/core/enums.dart';

/// Resolves which providers should be used for a given call.
///
/// Filters providers based on:
/// - Initialization status
/// - `only` set (whitelist)
/// - `exclude` set (blacklist)
/// - Default provider set from config
class ProviderResolver {
  const ProviderResolver._();

  /// Resolve providers to use for a call.
  ///
  /// [providers] — all registered providers for a category.
  /// [defaultProviders] — default set of providers from config.
  /// [only] — if provided, only these providers will be used.
  /// [exclude] — if provided, these providers will be excluded.
  ///
  /// Priority:
  /// 1. If [only] is provided → filter to only those IDs
  /// 2. If [exclude] is provided → remove those IDs from defaults
  /// 3. Otherwise → use [defaultProviders]
  /// 4. Always filter out uninitialized providers
  static List<T> resolve<T extends BaseServiceProvider>(
    List<T> providers, {
    required Set<SBProvider> defaultProviders,
    Set<SBProvider>? only,
    Set<SBProvider>? exclude,
  }) {
    var filtered = providers.where((p) => p.isInitialized).toList();

    if (only != null && only.isNotEmpty) {
      filtered = filtered.where((p) {
        final provider = SBProvider.fromId(p.providerId);
        return provider != null && only.contains(provider);
      }).toList();
    } else if (exclude != null && exclude.isNotEmpty) {
      filtered = filtered.where((p) {
        final provider = SBProvider.fromId(p.providerId);
        return provider != null && defaultProviders.contains(provider) && !exclude.contains(provider);
      }).toList();
    } else if (defaultProviders.isNotEmpty) {
      filtered = filtered.where((p) {
        final provider = SBProvider.fromId(p.providerId);
        return provider != null && defaultProviders.contains(provider);
      }).toList();
    }

    return filtered;
  }
}
