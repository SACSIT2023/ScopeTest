import 'dart:convert';
import 'package:http/http.dart' as http;

class StripeProvider {
  final String _apiKey = "YOUR_STRIPE_SECRET_KEY";

  Future<ResponseData> getToken(CardDetails cardDetails) async {
    const url = "https://api.stripe.com/v1/tokens";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'card[number]': cardDetails.number,
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

class CardDetails {
  final String number;
  final String expMonth;
  final String expYear;
  final String cvc;

  CardDetails({
    required this.number,
    required this.expMonth,
    required this.expYear,
    required this.cvc,
  });
}
