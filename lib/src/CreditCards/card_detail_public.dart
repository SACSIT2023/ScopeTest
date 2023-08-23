class CardDetailsPublic {
  final String cardName;
  final String cardNumber;
  final String expMonth;
  final String expYear;
  final String id;

  CardDetailsPublic({
    required this.cardName,
    required this.cardNumber,
    required this.expMonth,
    required this.expYear,
    required this.id,
  });

  // convert JSON to CardDetailsPublic
  static CardDetailsPublic fromJson(Map<String, dynamic> json) {
    return CardDetailsPublic(
      cardName: json['cardName'],
      cardNumber: json['cardNumber'],
      expMonth: json['expMonth'],
      expYear: json['expYear'],
      id: json['id'],
    );
  }
}
