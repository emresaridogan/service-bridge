import 'package:service_bridge_core/src/managers/analytics_manager.dart';
import 'package:flutter/widgets.dart';

/// A [NavigatorObserver] that automatically logs screen views
/// to all active analytics providers via [AnalyticsManager].
class ServiceBridgeNavigatorObserver extends NavigatorObserver {
  /// Creates a [ServiceBridgeNavigatorObserver].
  ServiceBridgeNavigatorObserver({
    required AnalyticsManager analyticsManager,
    this.nameExtractor = _defaultNameExtractor,
    this.routeFilter = _defaultRouteFilter,
  }) : _analyticsManager = analyticsManager;

  final AnalyticsManager _analyticsManager;

  /// Extracts the screen name from a [RouteSettings].
  /// Defaults to [RouteSettings.name].
  final String? Function(RouteSettings settings) nameExtractor;

  /// Determines whether a route should be tracked.
  /// Defaults to tracking all named routes.
  final bool Function(Route<dynamic>? route) routeFilter;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logScreenView(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _logScreenView(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) _logScreenView(previousRoute);
  }

  void _logScreenView(Route<dynamic> route) {
    if (!routeFilter(route)) return;

    final screenName = nameExtractor(route.settings);
    if (screenName == null || screenName.isEmpty) return;

    _analyticsManager.logScreenView(screenName, screenClass: route.settings.name);
  }

  static String? _defaultNameExtractor(RouteSettings settings) => settings.name;

  static bool _defaultRouteFilter(Route<dynamic>? route) => route is PageRoute || route is PopupRoute;
}
