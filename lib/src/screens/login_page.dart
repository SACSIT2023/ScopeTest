import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../blocs/bloc_credential.dart';
import '../services/log_provider.dart';
import '../services/user_settings.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/LoginPage'; // Named route
  final bool startupMode;

  const LoginPage({super.key, required this.startupMode});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  final _userSettings = UserSettings();
  final LogProvider logProvider = LogProvider();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadUserSettings(context));
  }

  Future<void> _loadUserSettings(BuildContext context) async {
    final bloc = Provider.of<BlocCredential>(context, listen: false);

    _rememberMe = await _userSettings.isRememberMeChecked();
    final credentials = await _userSettings.retrieveUserCredentials();

    final email = credentials['email'] ?? '';
    final password = credentials['password'] ?? '';

    if (_rememberMe && widget.startupMode) {
      // Update the email and password in your BLoC
      bloc.changeEmail(email);
      bloc.changePassword(password);
    } else {
      bloc.changeEmail('');
      bloc.changePassword('');
    }

    // below not needed, as the StreamBuilder will rebuild the widget
    // check it anyway
    // Call setState if the values affect your widget's appearance
    // if (_rememberMe || widget.checkUserSettings) {
    //   setState(() {});
    // }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<BlocCredential>(context, listen: false);
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              emailField(bloc),
              passwordField(bloc),
              rememberMeCheckbox(),
              signInButton(bloc),
              registrationPrompt(),
              _errorMessage != null
                  ? Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red))
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget emailField(BlocCredential bloc) {
    return StreamBuilder<String>(
      stream: bloc.email,
      builder: (context, snapshot) {
        return TextField(
            onChanged: bloc.changeEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Enter your email",
              errorText:
                  snapshot.error == null ? null : snapshot.error as String,
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ));
      },
    );
  }

  Widget passwordField(BlocCredential bloc) {
    return StreamBuilder<String>(
      stream: bloc.password,
      builder: (context, snapshot) {
        return TextField(
            onChanged: bloc.changePassword,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Enter your password",
              errorText:
                  snapshot.error == null ? null : snapshot.error as String,
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ));
      },
    );
  }

  Widget rememberMeCheckbox() {
    return CheckboxListTile(
      value: _rememberMe,
      onChanged: (value) {
        setState(() {
          _rememberMe = value!;
        });
        _userSettings.toggleRememberMe(value!);
      },
      title: const Text('Remember me'),
    );
  }

  Widget signInButton(BlocCredential bloc) {
    return StreamBuilder<bool>(
      stream: bloc.isValid,
      builder: (context, snapshot) {
        return ElevatedButton(
          onPressed: snapshot.hasData && snapshot.data == true && !_isLoading
              ? () async {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  final navigator =
                      Navigator.of(context); // store the Navigator

                  final success = await bloc.authenticateUser();
                  if (success) {
                    // navigator.pushReplacementNamed('/home');
                    navigator.pushNamed(HomePage.routeName);
                  } else {
                    setState(() {
                      _errorMessage = 'Incorrect email or password.';
                      _isLoading = false;
                    });
                    logProvider.logWarning(_errorMessage!);
                  }
                }
              : null, // Disabling the button if the form isn't valid
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
          ),
          child: _buildChildSignInBtn(),
        );
      },
    );
  }

  Widget _buildChildSignInBtn() {
    return _isLoading
        ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.white),
          )
        : const Text('Sign In', style: TextStyle(color: Colors.white));
  }

  Widget registrationPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account",
            style: TextStyle(color: Colors.black)),
        TextButton(
          onPressed: () {
            // replace with form SingUp:
            Navigator.of(context).pushNamed(HomePage.routeName);
          },
          child: const Text('[Create Account]',
              style: TextStyle(color: Colors.orange)),
        ),
      ],
    );
  }

  Widget errorText() {
    return Text(
      _errorMessage!,
      style: const TextStyle(color: Colors.red),
    );
  }
}
