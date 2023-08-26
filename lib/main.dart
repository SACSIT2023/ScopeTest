import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import 'main_data.dart';
import 'src/CreditCards/ListingView/card_list_bloc.dart';
import 'src/CreditCards/credit_card_manager.dart';
import 'src/CreditCards/AddDialog/stripe_service.dart';
import 'src/CreditCards/AddDialog/tokenization_bloc.dart';
import 'src/Credentials/bloc_credential.dart';
import 'src/Credentials/http_credential.dart';
import 'src/Credentials/user_settings_service.dart';
import 'src/app.dart';
import 'src/notifs/notifications_provider.dart';
import 'src/notifs/notifications_bloc.dart';
import 'src/services/auth_tocken_service.dart';
import 'src/services/config_service.dart';
import 'src/services/device_info_service.dart';
import 'src/services/http_controller.dart';
import 'src/services/logger_service.dart';
import 'src/services/navigation_service.dart';
import 'src/services/settings_service.dart';

import '.env';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripePublicKey;
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();

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

  getIt.registerSingleton<NotificationsProvider>(NotificationsProvider());

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
            return TokenizationBloc();
          },
          dispose: (context, bloc) => bloc.dispose(),
        ),
        Provider<CardListBloc>(
          create: (context) {
            return CardListBloc();
          },
          dispose: (context, bloc) => bloc.dispose(),
        ),
        Provider<NotificationsBloc>(
          create: (context) {
            return NotificationsBloc();
          },
          dispose: (context, bloc) => bloc.dispose(),
        ),
      ],
      child: const App(),
    ),
  );
}
//
// void mainOld() {
//   runApp(
//     Provider<BlocCredential>(
//       create: (context) => BlocCredential(),
//       dispose: (context, bloc) => bloc.dispose(),
//       child: App(),
//     ),
//   );
// }


