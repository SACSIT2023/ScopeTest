class CardDetailsRaw {
  final String cardNumber;
  final String cvc;
  final String expMonth;
  final String expYear;
  final String cardName;

  CardDetailsRaw({
    required this.cardNumber,
    required this.cvc,
    required this.expMonth,
    required this.expYear,
    required this.cardName,
  });
}
