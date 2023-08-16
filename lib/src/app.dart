import 'package:flutter/material.dart';
import 'package:scope_test/src/screens/login_page.dart';
import 'package:scope_test/src/screens/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Log Me In',
      initialRoute: HomePage.routeName,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case LoginPage.routeName:
            final startupModeArg = settings.arguments as bool?;
            return MaterialPageRoute(
              builder: (context) => LoginPage(
                key: UniqueKey(), // This will provide a unique key every time
                startupMode: startupModeArg ?? false,
              ),
            );
          case HomePage.routeName:
            return MaterialPageRoute(
              builder: (context) => const HomePage(),
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
