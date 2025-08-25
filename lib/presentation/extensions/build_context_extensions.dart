import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension BuildContextExtensions on BuildContext {
  bool isOnPage(String route) {
    final topRoute = GoRouterState.of(this).topRoute?.name;
    return topRoute == null ? false : topRoute == route;
  }
}
