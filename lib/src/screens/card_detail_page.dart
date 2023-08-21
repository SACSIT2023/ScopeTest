import 'package:flutter/material.dart';
import '../blocs/tokenization_bloc.dart';

class CardDetailsPage extends StatefulWidget {
  final TokenizationBloc bloc;

  const CardDetailsPage({super.key, required this.bloc});

  @override
  CardDetailsPageState createState() => CardDetailsPageState();
}

class CardDetailsPageState extends State<CardDetailsPage> {
  final _cardNumberController = TextEditingController();
  final _cvcController = TextEditingController();
  final _expMonthController = TextEditingController();
  final _expYearController = TextEditingController();
  final _cardNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildCardNumberField(),
              buildCvcField(),
              buildExpMonthField(),
              buildExpYearField(),
              buildCardNameField(),
              buildTokenizationStatus(),
              buildTokenizeCardButton(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      title: const Text("Card Details"),
    );
  }

  Widget buildCardNumberField() {
    return StreamBuilder<String>(
      stream: widget.bloc.cardNumber,
      builder: (context, snapshot) {
        return TextField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: "Card Number",
            errorText: snapshot.error?.toString(),
          ),
          onChanged: widget.bloc.changeCardNumber,
        );
      },
    );
  }

  Widget buildCvcField() {
    return StreamBuilder<String>(
      stream: widget.bloc.cvc,
      builder: (context, snapshot) {
        return TextField(
          controller: _cvcController,
          decoration: InputDecoration(
            labelText: "CVC",
            errorText: snapshot.error?.toString(),
          ),
          onChanged: widget.bloc.changeCvc,
        );
      },
    );
  }

  Widget buildExpMonthField() {
    return StreamBuilder<String>(
      stream: widget.bloc.expMonth,
      builder: (context, snapshot) {
        return TextField(
          controller: _expMonthController,
          decoration: InputDecoration(
            labelText: "Expiration Month",
            errorText: snapshot.error?.toString(),
          ),
          onChanged: widget.bloc.changeExpMonth,
        );
      },
    );
  }

  Widget buildExpYearField() {
    return StreamBuilder<String>(
      stream: widget.bloc.expYear,
      builder: (context, snapshot) {
        return TextField(
          controller: _expYearController,
          decoration: InputDecoration(
            labelText: "Expiration Year",
            errorText: snapshot.error?.toString(),
          ),
          onChanged: widget.bloc.changeExpYear,
        );
      },
    );
  }

  Widget buildCardNameField() {
    return StreamBuilder<String>(
      stream: widget.bloc.cardName,
      builder: (context, snapshot) {
        return TextField(
          controller: _cardNameController,
          decoration: InputDecoration(
            labelText: "Card Name",
            errorText: snapshot.error?.toString(),
          ),
          onChanged: widget.bloc.changeCardName,
        );
      },
    );
  }

  Widget buildTokenizationStatus() {
    return StreamBuilder<TokenizationState>(
      stream: widget.bloc.state,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final state = snapshot.data!;
          switch (state.status) {
            case TokenizationStatus.loading:
              return const CircularProgressIndicator();
            case TokenizationStatus.success:
              return Text("Tokenization Success! Token: ${state.token}");
            case TokenizationStatus.error:
              return Text("Error: ${state.errorMessage}");
            default:
              return const SizedBox.shrink();
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget buildTokenizeCardButton() {
    return StreamBuilder<bool>(
      stream: widget.bloc.isValid, // Assuming you have added the isValid stream
      builder: (BuildContext context, AsyncSnapshot<bool> validSnapshot) {
        return StreamBuilder<TokenizationState>(
          stream: widget.bloc.state,
          builder: (BuildContext context,
              AsyncSnapshot<TokenizationState> stateSnapshot) {
            bool isLoading =
                stateSnapshot.data?.status == TokenizationStatus.loading;

            return ElevatedButton(
              onPressed:
                  (validSnapshot.hasData && validSnapshot.data! && !isLoading)
                      ? () {
                          widget.bloc.tokenize();
                        }
                      : null, // null disables the button
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Tokenize Card"),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cvcController.dispose();
    _expMonthController.dispose();
    _expYearController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }
}
