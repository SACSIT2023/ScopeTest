import 'dart:async';

class ValidatorCredential {
  final validateEmail = StreamTransformer<String, String>.fromHandlers(
    handleData: (email, sink) {
      if (isValidEmail(email)) {
        sink.add(email);
      } else {
        sink.addError('invalid email');
      }
    },
  );

  final validatePassword = StreamTransformer<String, String>.fromHandlers(
    handleData: (password, sink) {
      if (password.length > 3) {
        sink.add(password);
      } else {
        sink.addError('Password must be at least 3 characters!');
      }
    },
  );

  static bool isValidEmail(String email) {
    final RegExp regex =
        RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$");
    return regex.hasMatch(email);
  }
}
