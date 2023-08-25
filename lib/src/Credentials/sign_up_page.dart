import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../Home/home_page.dart';
import '../services/navigation_service.dart';
import 'bloc_credential.dart';
import 'sign_in_page.dart';

// need to implement eCAPTCHA v3.

class SignUpPage extends StatefulWidget {
  static const routeName = '/SignUpPage';

  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final NavigationService _navigationService =
      GetIt.instance<NavigationService>();

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
              rePasswordField(bloc),
              companyCheckbox(bloc),
              companyNameField(bloc),
              firstNameField(bloc),
              lastNameField(bloc),
              signUpButton(bloc),
              errorText(bloc),
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

  Widget rePasswordField(BlocCredential bloc) {
    return StreamBuilder<String>(
      stream: bloc.rePassword,
      builder: (context, snapshot) {
        return TextField(
            onChanged: bloc.changeRePassword,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Re-enter your password",
              errorText:
                  snapshot.error == null ? null : snapshot.error as String,
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ));
      },
    );
  }

  Widget companyCheckbox(BlocCredential bloc) {
    return StreamBuilder<bool>(
      stream: bloc.isCompany,
      builder: (context, snapshot) {
        return CheckboxListTile(
          value: snapshot.data ?? false,
          onChanged: bloc.changeIsCompany,
          title: const Text('Is a company'),
        );
      },
    );
  }

  Widget companyNameField(BlocCredential bloc) {
    return StreamBuilder<String>(
      stream: bloc.company,
      builder: (context, snapshot) {
        return TextField(
          onChanged: bloc.changeCompany,
          decoration: InputDecoration(
            hintText: 'Enter company name',
            labelText: 'Company Name',
            errorText: snapshot.error == null ? null : snapshot.error as String,
          ),
        );
      },
    );
  }

  Widget firstNameField(BlocCredential bloc) {
    return StreamBuilder<String>(
      stream: bloc.firstName,
      builder: (context, snapshot) {
        return TextField(
          onChanged: bloc.changeFirstName,
          decoration: InputDecoration(
            hintText: 'Enter first name',
            labelText: 'First Name',
            errorText: snapshot.error == null ? null : snapshot.error as String,
          ),
        );
      },
    );
  }

  Widget lastNameField(BlocCredential bloc) {
    return StreamBuilder<String>(
      stream: bloc.lastName,
      builder: (context, snapshot) {
        return TextField(
          onChanged: bloc.changeLastName,
          decoration: InputDecoration(
            hintText: 'Enter last name',
            labelText: 'Last Name',
            errorText: snapshot.error == null ? null : snapshot.error as String,
          ),
        );
      },
    );
  }

  Widget signUpButton(BlocCredential bloc) {
    return StreamBuilder<bool>(
      stream: bloc.isValidSignUp,
      builder: (context, snapshot) {
        return ElevatedButton(
          onPressed: snapshot.hasData && snapshot.data == true
              ? () async {
                  final success = await bloc.registerUser();
                  if (success) {
                    _navigationService.navigateTo(HomePage.routeName);
                  } else {
                    _navigationService.navigateTo(SignInPage.routeName,
                        arguments: false);
                  }
                }
              : null,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue),
          ),
          child: const Text('Sign Up', style: TextStyle(color: Colors.white)),
        );
      },
    );
  }

  Widget errorText(BlocCredential bloc) {
    return StreamBuilder<String?>(
      stream: bloc.errorMessage,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Text(
            snapshot.data!,
            style: const TextStyle(color: Colors.red),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
