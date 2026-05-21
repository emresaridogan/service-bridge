import 'package:service_bridge_core/src/contracts/base_service_provider.dart';

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
  /// [defaultProviderIds] — default set of provider IDs from config.
  /// [only] — if provided, only these provider IDs will be used.
  /// [exclude] — if provided, these provider IDs will be excluded.
  ///
  /// Priority:
  /// 1. If [only] is provided → filter to only those IDs
  /// 2. If [exclude] is provided → remove those IDs from defaults
  /// 3. Otherwise → use [defaultProviderIds]
  /// 4. Always filter out uninitialized providers
  static List<T> resolve<T extends BaseServiceProvider>(
    List<T> providers, {
    required Set<String> defaultProviderIds,
    Set<String>? only,
    Set<String>? exclude,
  }) {
    var filtered = providers.where((p) => p.isInitialized).toList();

    if (only != null && only.isNotEmpty) {
      filtered = filtered.where((p) => only.contains(p.providerId)).toList();
    } else if (exclude != null && exclude.isNotEmpty) {
      filtered = filtered.where((p) => defaultProviderIds.contains(p.providerId) && !exclude.contains(p.providerId)).toList();
    } else if (defaultProviderIds.isNotEmpty) {
      filtered = filtered.where((p) => defaultProviderIds.contains(p.providerId)).toList();
    }

    return filtered;
  }
}
