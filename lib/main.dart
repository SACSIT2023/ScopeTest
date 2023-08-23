import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import 'main_data.dart';
import 'src/CreditCards/credit_card_manager.dart';
import 'src/CreditCards/AddDialog/stripe_service.dart';
import 'src/CreditCards/AddDialog/tokenization_bloc.dart';
import 'src/Credentials/bloc_credential.dart';
import 'src/Credentials/http_credential.dart';
import 'src/Credentials/user_settings_service.dart';
import 'src/app.dart';
import 'src/services/auth_tocken_service.dart';
import 'src/services/config_service.dart';
import 'src/services/device_info_service.dart';
import 'src/services/http_controller.dart';
import 'src/services/logger_service.dart';
import 'src/services/navigation_service.dart';
import 'src/services/settings_service.dart';

void main() {
  final getIt = GetIt.instance;

  getIt.registerSingleton<NavigationService>(NavigationService());
  getIt.registerSingleton<MainData>(MainData());

  getIt.registerSingleton<SettingsService>(SettingsService());
  getIt.registerSingleton<AuthTockenService>(AuthTockenService());
  getIt.registerSingleton<ConfigService>(ConfigService());
  getIt.registerSingleton<DeviceInfoService>(DeviceInfoService());

  getIt.registerSingleton<LoggerService>(LoggerService());

  getIt.registerSingleton<HttpController>(HttpController());
  getIt.registerSingleton<HttpCredential>(HttpCredential());

  getIt.registerSingleton<CreditCardManager>(CreditCardManager());

  getIt.registerSingleton<StripeService>(StripeService());
  getIt.registerSingleton<UserSettingsService>(UserSettingsService());

  runApp(
    MultiProvider(
      providers: [
        Provider<BlocCredential>(
          create: (context) {
            // final authService = context.read<AuthTockenService>();
            // final httpController = context.read<HttpController>();
            return BlocCredential();
          },
          dispose: (context, bloc) => bloc.dispose(),
        ),
        Provider<TokenizationBloc>(
          create: (context) {
            // final stripeProvider = context.read<StripeService>();
            return TokenizationBloc();
          },
          dispose: (context, bloc) => bloc.dispose(),
        ),
      ],
      child: const App(),
    ),
  );
}

// void mainOld() {
//   runApp(
//     Provider<BlocCredential>(
//       create: (context) => BlocCredential(),
//       dispose: (context, bloc) => bloc.dispose(),
//       child: App(),
//     ),
//   );
// }


