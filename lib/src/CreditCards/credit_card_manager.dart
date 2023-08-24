import 'dart:convert';
import 'package:get_it/get_it.dart';

import '../../main_data.dart';
import '../services/http_controller.dart';
import '../services/logger_service.dart';
import 'card_detail_public.dart';

class CreditCardManager {
  final HttpController _httpController = GetIt.instance<HttpController>();
  final LoggerService _loggerService = GetIt.instance<LoggerService>();
  final MainData _mainData = GetIt.instance<MainData>();

  // Fetch all card listings from the backend.
  Future<List<CardDetailsPublic>> fetchCardListing() async {
    try {
      Map<String, dynamic> response = await _httpController.sendRequest(
        HttpMethod.post,
        'CCards/Listing',
        {'userEmail': _mainData.userEmail},
        true,
      );

      CardListResponse parsedResponse = CardListResponse.fromJson(response);
      if (parsedResponse.errorMessage != null) {
        throw Exception(parsedResponse.errorMessage);
      }

      return parsedResponse.cardDetails ?? [];
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

class CardListResponse {
  final List<CardDetailsPublic>? cardDetails;
  final String? errorMessage;

  CardListResponse({this.cardDetails, this.errorMessage});

  static CardListResponse fromJson(Map<String, dynamic> json) {
    List<CardDetailsPublic>? parsedList;

    // Check if the data key exists and is a List
    if (json.containsKey('data') && json['data'] is List) {
      parsedList = (json['data'] as List)
          .whereType<Map<String, dynamic>>() // Use whereType for filtering
          .map((item) => CardDetailsPublic.fromJson(item))
          .toList();
    }

    return CardListResponse(
      cardDetails: parsedList,
      errorMessage: json['errorMessage'] as String?,
    );
  }
}
