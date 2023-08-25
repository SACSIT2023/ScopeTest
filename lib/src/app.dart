import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:scope_test/src/Credentials/sign_in_page.dart';
import 'package:scope_test/src/Home/home_page.dart';

import 'Credentials/sign_up_page.dart';
import 'CreditCards/AddDialog/card_details_page.dart';
import 'CreditCards/ListingView/card_list_page.dart';
import 'Home/splash_page.dart';
import 'notifs/notification_detailed_page.dart';
import 'notifs/notification_list_page.dart';
import 'notifs/notification_model.dart';
import 'services/navigation_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DragonFlight',
      initialRoute: SplashPage.routeName,
      navigatorKey: GetIt.instance<NavigationService>().navigatorKey,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case SignInPage.routeName:
            final startupModeArg = settings.arguments as bool?;
            return MaterialPageRoute(
              builder: (context) => SignInPage(
                key: UniqueKey(), // This will provide a unique key every time
                startupMode: startupModeArg ?? false,
              ),
            );

          case HomePage.routeName:
            return MaterialPageRoute(
              builder: (context) => const HomePage(),
            );
          case SignUpPage.routeName:
            return MaterialPageRoute(
              builder: (context) => const SignUpPage(),
            );
          case CardDetailsPage.routeName:
            return MaterialPageRoute(
              builder: (context) => const CardDetailsPage(),
            );
          case CardListPage.routeName:
            final editModeArg = settings.arguments as bool?;
            return MaterialPageRoute(
              builder: (context) => CardListPage(
                key: UniqueKey(),
                editMode: editModeArg ?? false,
              ),
            );
          case NotificationListPage.routeName:
            return MaterialPageRoute(
              builder: (context) => const NotificationListPage(),
            );
          case NotificationDetailedPage.routeName:
            final notificationDetailArg =
                settings.arguments as NotificationModel;
            return MaterialPageRoute(
              builder: (context) =>
                  NotificationDetailedPage(notification: notificationDetailArg),
            );
          // Add other named routes here
          default:
            // If there is no such route
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(
                  child: Text('404 - Not Found'),
                ),
              ),
            );
        }
      },
    );
  }
}
//SignUpPage