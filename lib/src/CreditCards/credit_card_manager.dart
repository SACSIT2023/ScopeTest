import 'dart:convert';
import '../../main_data.dart';
import '../services/http_controller.dart';
import '../services/logger_service.dart';
import 'card_detail_public.dart';

class CreditCardManager {
  final HttpController _httpController = HttpController();
  final LoggerService _loggerService = LoggerService();
  final MainData _mainData = MainData();

  // Fetch all card listings from the backend.
  Future<List<CardDetailsPublic>> fetchCardListing(String userEmail) async {
    try {
      Map<String, dynamic> response = await _httpController.sendRequest(
        HttpMethod.post,
        'CCards/CreditCardNew',
        {'userEmail': userEmail},
        true,
      );

      return (response['data'] as List)
          .map((item) => CardDetailsPublic.fromJson(item))
          .toList();
    } catch (e, stacktrace) {
      _loggerService.logError('Failed to fetch card listing', e, stacktrace);
      throw Exception('Failed to fetch card listing.');
    }
  }

  // Add a card to the backend.
  Future<void> addCard(
      String stripeToken, CardDetailsPublic cardDetails) async {
    await _httpController.sendRequest(
      HttpMethod.post,
      'CCards/AddCard',
      {
        'stripeToken': stripeToken,
        'userEmail': _mainData.userEmail,
        'card': jsonEncode(cardDetails),
      },
      true,
    );
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
  }
}
