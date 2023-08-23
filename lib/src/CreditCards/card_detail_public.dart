class CardDetailsPublic {
  final String cardName;
  final String cardNumber;
  final String expMonth;
  final String expYear;
  final String id;
  final String cardType;

  CardDetailsPublic({
    required this.cardName,
    required this.cardNumber,
    required this.expMonth,
    required this.expYear,
    required this.id,
    required this.cardType,
  });

  // convert JSON to CardDetailsPublic
  static CardDetailsPublic fromJson(Map<String, dynamic> json) {
    return CardDetailsPublic(
        cardName: json['cardName'],
        cardNumber: json['cardNumber'],
        expMonth: json['expMonth'],
        expYear: json['expYear'],
        id: json['id'],
        cardType: json['cardType']);
  }
}
