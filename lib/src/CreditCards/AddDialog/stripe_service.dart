import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../card_details_raw.dart';

class StripeService {
  Future<ResponseData> getToken(CardDetailsRaw cardDetails) async {
    const url = "https://api.stripe.com/v1/tokens";
    final String publishableKey = dotenv.env['stripePublicKey'] ?? "";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $publishableKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'card[number]': cardDetails.cardNumber,
          'card[exp_month]': cardDetails.expMonth,
          'card[exp_year]': cardDetails.expYear,
          'card[cvc]': cardDetails.cvc,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ResponseData.success(data['id']);
      } else {
        final errorData = json.decode(response.body);
        return ResponseData.error(
            errorData['error']['message'] ?? "An error occurred.");
      }
    } catch (e) {
      return ResponseData.error(e.toString());
    }
  }
}

class ResponseData {
  final String? data;
  final String? error;

  ResponseData._({this.data, this.error});

  factory ResponseData.success(String data) => ResponseData._(data: data);

  factory ResponseData.error(String error) => ResponseData._(error: error);
}
