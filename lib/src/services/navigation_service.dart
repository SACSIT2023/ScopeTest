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



// *** Forward Navigation with Data:  ***
//      .pushNamed('/screenB', arguments: 'Hello!');
//  Called Screen (Screen B) retrieves the data:
//  String data = ModalRoute.of(context)!.settings.arguments as String;


// ***** Backward Navigation with Data: *****
//     Called Screen (Screen B) returns data:
//          .pop('Hello back to Screen A');

//    Caller Screen (Screen A) retrieves the data:
//      var result = await .pushNamed('/screenB');
//      print(result);  // prints: Hello back to Screen A

