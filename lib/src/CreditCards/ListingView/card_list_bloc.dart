import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import '../card_detail_public.dart';
import '../card_details.dart';
import '../cards_utility.dart';
import '../credit_card_manager.dart';

enum CardListState { initial, loading, loaded, error }

class CardListBloc {
  final _cardsController = BehaviorSubject<List<CardDetailsPublic>>();
  final _stateController = BehaviorSubject<CardListState>();

  final CreditCardManager _creditCardManager = CreditCardManager();

  // Outputs (Getters)
  Stream<List<CardDetailsPublic>> get cards => _cardsController.stream;
  Stream<CardListState> get state => _stateController.stream;

  fetchCards(String userEmail) async {
    _stateController.sink.add(CardListState.loading);
    try {
      List<CardDetailsPublic> fetchedCards =
          await _creditCardManager.fetchCardListing(userEmail);
      _cardsController.sink.add(fetchedCards);
      _stateController.sink.add(CardListState.loaded);
    } catch (e) {
      _stateController.sink.add(CardListState.error);
    }
  }

// This function adds a card using the CreditCardManager and updates the BLoC's list.
  addCard(String stripeToken, CardDetails cardDetails) async {
    try {
      var ctp = convertCardDetailsToCardDetailsPublic(cardDetails);
      await _creditCardManager.addCard(stripeToken, ctp);

      final currentCards = _cardsController.value;
      currentCards.add(ctp);
      _cardsController.sink.add(currentCards);
    } catch (e) {
      _stateController.sink.add(CardListState.error);
    }
  }

  // This function removes a card using the CreditCardManager and updates the BLoC's list.
  deleteCard(String cardId) async {
    try {
      await _creditCardManager.removeCard(cardId);
      final currentCards = _cardsController.value;
      final updatedCards =
          currentCards.where((card) => card.id != cardId).toList();
      _cardsController.sink.add(updatedCards);
    } catch (e) {
      _stateController.sink.add(CardListState.error);
    }
  }

  dispose() {
    _cardsController.close();
    _stateController.close();
  }

  CardDetailsPublic convertCardDetailsToCardDetailsPublic(
      CardDetails cardDetails) {
    return CardDetailsPublic(
        id: const Uuid().v4(),
        cardNumber: CardsUtility.getCardNumberMasked(cardDetails.cardNumber),
        expMonth: cardDetails.expMonth,
        expYear: cardDetails.expYear,
        cardName: cardDetails.cardName,
        cardType: CardsUtility.getCardType(cardDetails.cardNumber));
  }
}
