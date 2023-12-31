import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import '../card_details_raw.dart';
import 'stripe_service.dart';
import 'card_validator.dart';

enum TokenizationStatus { initial, loading, success, error }

class TokenizationState {
  final TokenizationStatus status;
  final String? token;
  final String? errorMessage;

  TokenizationState({required this.status, this.token, this.errorMessage});
}

class TokenizationBloc extends CardValidator {
  final StripeService _stripeService = GetIt.instance<StripeService>();

  TokenizationBloc();

  CardDetailsRaw get currentCardDetails => CardDetailsRaw(
        cardNumber: _cardNumberController.value,
        cvc: _cvcController.value,
        expMonth: _expMonthController.value,
        expYear: _expYearController.value,
        cardName: _cardNameController.value,
      );

  final _stateController = BehaviorSubject<TokenizationState>.seeded(
      TokenizationState(status: TokenizationStatus.initial));

  Stream<TokenizationState> get state => _stateController.stream;
  Stream<String> get tokenValue => _tokenValueController.stream;

  Stream<bool> get isValid => Rx.combineLatest5(
      cardNumber,
      cvc,
      expMonth,
      expYear,
      cardName,
      (String cardNumber, String cvc, String expMonth, String expYear,
              String cardName) =>
          cardNumber.isNotEmpty &&
          cvc.isNotEmpty &&
          expMonth.isNotEmpty &&
          expYear.isNotEmpty &&
          cardName.isNotEmpty);

  // Input stream controllers
  final _cardNumberController = BehaviorSubject<String>();
  final _cvcController = BehaviorSubject<String>();
  final _expMonthController = BehaviorSubject<String>();
  final _expYearController = BehaviorSubject<String>();
  final _cardNameController = BehaviorSubject<String>();

  final _tokenValueController = BehaviorSubject<String>();
  String get currentTokenValue => _tokenValueController.value;

  // Output stream controllers (no need anymore as TokenizationState that handles the state (including token or error results))
  //final _tokenizationResultController = StreamController<ResponseData>();

  // Input streams
  Stream<String> get cardNumber =>
      _cardNumberController.stream.transform(cardNumberTransformer);
  Stream<String> get cvc => _cvcController.stream.transform(cvcTransformer);
  Stream<String> get expMonth =>
      _expMonthController.stream.transform(expMonthTransformer);
  Stream<String> get expYear =>
      _expYearController.stream.transform(expYearTransformer);
  Stream<String> get cardName =>
      _cardNameController.stream.transform(cardNameTransformer);

  // Sinks
  Function(String) get changeCardNumber => _cardNumberController.sink.add;
  Function(String) get changeCvc => _cvcController.sink.add;
  Function(String) get changeExpMonth => _expMonthController.sink.add;
  Function(String) get changeExpYear => _expYearController.sink.add;
  Function(String) get changeCardName => _cardNameController.sink.add;

  tokenize() async {
    _stateController.add(TokenizationState(status: TokenizationStatus.loading));

    final cardNumber = _cardNumberController.value;
    final cvc = _cvcController.value;
    final expMonth = _expMonthController.value;
    final expYear = _expYearController.value;
    final cardName = _cardNameController.value;

    final cardDetails = CardDetailsRaw(
      cardNumber: cardNumber,
      cvc: cvc,
      expMonth: expMonth,
      expYear: expYear,
      cardName: cardName,
    );

    final response = await _stripeService.getToken(cardDetails);

    if (response.data != null) {
      _stateController.add(TokenizationState(
        status: TokenizationStatus.success,
        token: response.data,
      ));
      _tokenValueController.add(response.data!);
    } else {
      _stateController.add(TokenizationState(
        status: TokenizationStatus.error,
        errorMessage: response.error,
      ));
      _tokenValueController.add('');
    }
  }

  dispose() {
    _cardNumberController.close();
    _cvcController.close();
    _expMonthController.close();
    _expYearController.close();
    _cardNameController.close();
    _stateController.close();
    _tokenValueController.close();
  }
}
