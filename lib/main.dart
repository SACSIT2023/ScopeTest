import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scope_test/src/blocs/bloc_credential.dart';
import 'package:scope_test/src/blocs/tokenization_bloc.dart';
import 'package:scope_test/src/controllers/http_controller.dart';
import 'package:scope_test/src/services/auth_service.dart';
import 'package:scope_test/src/services/device_info_service.dart';
import 'package:scope_test/src/services/stripe_provider.dart';
import 'src/app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        Provider<DeviceInfoProvider>(
          create: (context) => DeviceInfoProvider(),
        ),
        Provider<StripeProvider>(
          create: (context) => StripeProvider(),
        ),
        Provider<HttpController>(
          create: (context) {
            final authService = context.read<AuthProvider>();
            final deviceInfoService = context.read<DeviceInfoProvider>();
            return HttpController(authService, deviceInfoService);
          },
        ),
        Provider<BlocCredential>(
          create: (context) {
            final authService = context.read<AuthProvider>();
            final httpController = context.read<HttpController>();
            return BlocCredential(authService, httpController);
          },
          dispose: (context, bloc) => bloc.dispose(),
        ),
        Provider<TokenizationBloc>(
          create: (context) {
            final stripeProvider = context.read<StripeProvider>();
            return TokenizationBloc(stripeProvider);
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


