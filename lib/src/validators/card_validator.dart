import 'dart:async';

class CardValidator {
  static bool _isValidLuhn(String number) {
    int sum = 0;
    bool alternate = false;
    for (int i = number.length - 1; i >= 0; i--) {
      int n = int.parse(number[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  final cardNumberTransformer = StreamTransformer<String, String>.fromHandlers(
      handleData: (cardNumber, sink) {
    if (cardNumber.isEmpty || !_isValidLuhn(cardNumber)) {
      sink.addError("Invalid card number");
    } else {
      sink.add(cardNumber);
    }
  });

  final cvcTransformer =
      StreamTransformer<String, String>.fromHandlers(handleData: (cvc, sink) {
    if (cvc.isEmpty || (cvc.length != 3 && cvc.length != 4)) {
      sink.addError("Invalid CVC");
    } else {
      sink.add(cvc);
    }
  });

  final expMonthTransformer = StreamTransformer<String, String>.fromHandlers(
      handleData: (expMonth, sink) {
    if (expMonth.isEmpty ||
        int.tryParse(expMonth) == null ||
        int.parse(expMonth) < 1 ||
        int.parse(expMonth) > 12) {
      sink.addError("Invalid expiration month");
    } else {
      sink.add(expMonth);
    }
  });

  final expYearTransformer = StreamTransformer<String, String>.fromHandlers(
      handleData: (expYear, sink) {
    if (expYear.isEmpty ||
        expYear.length != 4 ||
        int.tryParse(expYear) == null ||
        int.parse(expYear) < DateTime.now().year) {
      // Simple validation to not allow years before the current year.
      sink.addError("Invalid expiration year");
    } else {
      sink.add(expYear);
    }
  });

  final cardNameTransformer = StreamTransformer<String, String>.fromHandlers(
      handleData: (cardName, sink) {
    if (cardName.isEmpty) {
      sink.addError("Invalid card name");
    } else {
      sink.add(cardName);
    }
  });
}
