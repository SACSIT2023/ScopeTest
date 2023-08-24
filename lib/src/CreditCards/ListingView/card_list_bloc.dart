import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import '../card_detail_public.dart';
import '../card_details_raw.dart';
import '../cards_utility.dart';
import '../credit_card_manager.dart';

enum CardListState { initial, loading, loaded, error }

class CardListBloc {
  final _creditCardManager = GetIt.instance<CreditCardManager>();

  final _cardsController = BehaviorSubject<List<CardDetailsPublic>>();
  final _stateController = BehaviorSubject<CardListState>();
  final _errorController = PublishSubject<String>(); // To handle error messages

  // Outputs (Getters)
  Stream<List<CardDetailsPublic>> get cards => _cardsController.stream;
  Stream<CardListState> get state => _stateController.stream;
  Stream<String> get errors => _errorController.stream; // Expose error messages

  fetchCards() async {
    _stateController.sink.add(CardListState.loading);
    try {
      List<CardDetailsPublic> fetchedCards =
          await _creditCardManager.fetchCardListing();

      if (fetchedCards.isEmpty) {
        throw Exception('No cards found or returned value is null.');
      }

      _cardsController.sink.add(fetchedCards);
      _stateController.sink.add(CardListState.loaded);
    } catch (e) {
      _stateController.sink.add(CardListState.error);
      _errorController.sink.add(e.toString()); // Capture the error message
    }
  }

  addCard(String stripeToken, CardDetailsRaw cardDetails) async {
    try {
      var ctp = convertCardDetailsToCardDetailsPublic(cardDetails);
      await _creditCardManager.addCard(stripeToken, ctp);

      final currentCards = _cardsController.value; // ?? [];
      currentCards.add(ctp);
      _cardsController.sink.add(currentCards);
    } catch (e) {
      _stateController.sink.add(CardListState.error);
      _errorController.sink.add(e.toString());
    }
  }

  deleteCard(String cardId) async {
    try {
      await _creditCardManager.removeCard(cardId);
      final currentCards = _cardsController.value; // ?? [];
      final updatedCards =
          currentCards.where((card) => card.id != cardId).toList();
      _cardsController.sink.add(updatedCards);
    } catch (e) {
      _stateController.sink.add(CardListState.error);
      _errorController.sink.add(e.toString());
    }
  }

  dispose() {
    _cardsController.close();
    _stateController.close();
    _errorController.close();
  }

  CardDetailsPublic convertCardDetailsToCardDetailsPublic(
      CardDetailsRaw cardDetails) {
    return CardDetailsPublic(
        id: const Uuid().v4(),
        cardNumber: CardsUtility.getCardNumberMasked(cardDetails.cardNumber),
        expMonth: cardDetails.expMonth,
        expYear: cardDetails.expYear,
        cardName: cardDetails.cardName,
        cardType: CardsUtility.getCardType(cardDetails.cardNumber));
  }
}
