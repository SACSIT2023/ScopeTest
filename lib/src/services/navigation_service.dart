import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Navigate to a named route
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  // Go back
  void goBack({dynamic result}) {
    return navigatorKey.currentState!.pop(result);
  }

  // Replace current route with a new route
  Future<dynamic> replaceWith(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  // Pop all routes and return to the root
  void navigateToRoot() {
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }
}
