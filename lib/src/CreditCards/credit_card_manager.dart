import 'dart:convert';
import '../../main_data.dart';
import '../services/http_controller.dart';
import '../services/logger_service.dart';
import 'card_detail_public.dart';
import 'card_details.dart';
import 'cards_utility.dart';
import 'package:uuid/uuid.dart';

class CreditCardManager {
  final HttpController _httpController = HttpController();
  final LoggerService _loggerService = LoggerService();
  final MainData _mainData = MainData();

  List<CardDetailsPublic> _cards = [];

  List<CardDetailsPublic> get cards => _cards;

  // Fetch all card listings from the backend.
  Future<List<CardDetailsPublic>> fetchCardListing(String clientId) async {
    try {
      Map<String, dynamic> response = await _httpController.sendRequest(
        HttpMethod.post,
        'CCards/CreditCardNew',
        {'clientId': clientId},
        true,
      );

      _cards = (response['data'] as List)
          .map((item) => CardDetailsPublic.fromJson(item))
          .toList();

      return _cards;
    } catch (e, stacktrace) {
      _loggerService.logError('Failed to fetch card listing', e, stacktrace);
      throw Exception('Failed to fetch card listing.');
    }
  }

  // Add a card to the backend.
  Future<void> addCard(String stripeToken, CardDetails cardDetails) async {
    CardDetailsPublic cardDetailsPublic = CardDetailsPublic(
      cardName: cardDetails.cardName,
      cardNumber: CardsUtility.getCardNumberMasked(cardDetails.cardNumber),
      expMonth: cardDetails.expMonth,
      expYear: cardDetails.expYear,
      id: const Uuid().v4(),
    );

    // Update the request body to include userEmail
    await _httpController.sendRequest(
      HttpMethod.post,
      'CCards/AddCard',
      {
        'stripeToken': stripeToken,
        'userEmail': _mainData.userEmail,
        'card': jsonEncode(cardDetailsPublic),
      },
      true,
    );
    _cards.add(cardDetailsPublic);
  }

  // Remove a card from the backend.
  Future<void> removeCard(String cardId) async {
    await _httpController.sendRequest(
      HttpMethod.post,
      'CCards/RemoveCard',
      {
        'cardId': cardId,
        'userEmail': _mainData.userEmail // Assigning the userEmail value here
      },
      true,
    );

    _cards.removeWhere((card) => card.id == cardId);
  }
}
