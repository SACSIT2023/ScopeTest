class CardsUtility {
  static const String visa = "assets/images/visa.png";
  static const String mastercard = "assets/images/mastercard.png";
  static const String americanExpress = "assets/images/american_express.png";
  static const String discover = "assets/images/discover.png";
  static const String jcb = "assets/images/jcb.png";
  static const String dinersClub = "assets/images/diners_club.png";
  static const String unknown = "assets/images/unknown.png";

  static String getCardTypeImage(String cardType) {
    switch (cardType) {
      case "VISA":
        return visa;
      case "MASTERCARD":
        return mastercard;
      case "AMERICAN_EXPRESS":
        return americanExpress;
      case "DISCOVER":
        return discover;
      case "JCB":
        return jcb;
      case "DINERS_CLUB":
        return dinersClub;
      default:
        return unknown;
    }
  }

  static String getCardType(String cardNumber) {
    if (cardNumber.startsWith("4")) {
      return "VISA";
    } else if (cardNumber.startsWith("5")) {
      return "MASTERCARD";
    } else if (cardNumber.startsWith("3")) {
      return "AMERICAN_EXPRESS";
    } else if (cardNumber.startsWith("6")) {
      return "DISCOVER";
    } else if (cardNumber.startsWith("35")) {
      return "JCB";
    } else if (cardNumber.startsWith("36")) {
      return "DINERS_CLUB";
    } else {
      return "UNKNOWN";
    }
  }

  static String getCardNumber(String cardNumber) {
    if (cardNumber.length > 4) {
      return cardNumber.substring(cardNumber.length - 4);
    } else {
      return cardNumber;
    }
  }

  static String getCardNumberMasked(String cardNumber) {
    String cardNumberMasked = "";
    for (int i = 0; i < cardNumber.length; i++) {
      if (i < cardNumber.length - 4) {
        cardNumberMasked += "*";
      } else {
        cardNumberMasked += cardNumber[i];
      }
    }
    return cardNumberMasked;
  }

  static String getCardHolderName(String cardHolderName) {
    if (cardHolderName.isNotEmpty) {
      return cardHolderName;
    } else {
      return "CARD HOLDER";
    }
  }
}
