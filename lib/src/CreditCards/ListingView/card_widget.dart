import 'package:flutter/material.dart';

import '../card_detail_public.dart';
import '../cards_utility.dart';
import 'dart:math' as math;

class CardWidget extends StatefulWidget {
  final CardDetailsPublic cardDetailsPublic;
  final void Function(String) onTap; // Callback for card selection

  const CardWidget(
      {super.key, required this.cardDetailsPublic, required this.onTap});

  @override
  CardWidgetState createState() => CardWidgetState();
}

class CardWidgetState extends State<CardWidget>
    with SingleTickerProviderStateMixin {
  bool _isFront = true;
  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateY(_flipController.value * math.pi),
        child: _isFront ? _frontView() : _backView(),
      ),
    );
  }

  void _handleTap() {
    widget
        .onTap(widget.cardDetailsPublic.id); // Pass the card ID to the callback
    _flipController.forward().then((_) {
      _isFront = !_isFront;
      _flipController.reverse();
    });
  }

  Widget _frontView() {
    return Card(
      elevation: 5.0,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _frontCardContent(),
      ),
    );
  }

  Widget _frontCardContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_cardTypeImage(), _lastFourDigits(), _expiryDate()],
    );
  }

  Widget _cardTypeImage() {
    return Align(
      alignment: Alignment.topRight,
      child: Image.asset(
        CardsUtility.getCardTypeImage(widget.cardDetailsPublic.cardType),
        height: 50.0,
      ),
    );
  }

  Widget _lastFourDigits() {
    return Text(
      CardsUtility.getLastFourDigits(widget.cardDetailsPublic.cardNumber),
      style: const TextStyle(
        fontSize: 24.0,
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 2.0,
            color: Colors.black38,
            offset: Offset(1.0, 1.0),
          ),
        ],
      ),
    );
  }

  Widget _expiryDate() {
    return Text(
      'Expiry: ${widget.cardDetailsPublic.expMonth}/${widget.cardDetailsPublic.expYear}',
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _backView() {
    return Card(
      elevation: 5.0,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        color: Colors.grey,
        child: _backCardContent(),
      ),
    );
  }

  Widget _backCardContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _cardHolderName(),
        _maskedCardNumber(),
      ],
    );
  }

  Widget _maskedCardNumber() {
    return Text(
      widget.cardDetailsPublic.cardNumber,
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget _cardHolderName() {
    return Text(
      widget.cardDetailsPublic.cardName,
      style: const TextStyle(color: Colors.white),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }
}
