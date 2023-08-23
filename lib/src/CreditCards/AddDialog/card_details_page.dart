import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'tokenization_bloc.dart';

class CardDetailsPage extends StatefulWidget {
  static const routeName = '/CardDetailsPage'; // Named route

  const CardDetailsPage({super.key});

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
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<TokenizationBloc>(context, listen: false);

    return Scaffold(
      appBar: buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildCardNumberField(bloc),
              buildCvcField(bloc),
              buildExpMonthField(bloc),
              buildExpYearField(bloc),
              buildCardNameField(bloc),
              buildTokenizationStatus(bloc),
              buildTokenizeCardButton(bloc),
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

  Widget buildCardNumberField(TokenizationBloc bloc) {
    return StreamBuilder<String>(
      stream: bloc.cardNumber,
      builder: (context, snapshot) {
        return TextField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: "Card Number",
            errorText: snapshot.error?.toString(),
          ),
          onChanged: bloc.changeCardNumber,
        );
      },
    );
  }

  Widget buildCvcField(TokenizationBloc bloc) {
    return StreamBuilder<String>(
      stream: bloc.cvc,
      builder: (context, snapshot) {
        return TextField(
          controller: _cvcController,
          decoration: InputDecoration(
            labelText: "CVC",
            errorText: snapshot.error?.toString(),
          ),
          onChanged: bloc.changeCvc,
        );
      },
    );
  }

  Widget buildExpMonthField(TokenizationBloc bloc) {
    return StreamBuilder<String>(
      stream: bloc.expMonth,
      builder: (context, snapshot) {
        return TextField(
          controller: _expMonthController,
          decoration: InputDecoration(
            labelText: "Expiration Month",
            errorText: snapshot.error?.toString(),
          ),
          onChanged: bloc.changeExpMonth,
        );
      },
    );
  }

  Widget buildExpYearField(TokenizationBloc bloc) {
    return StreamBuilder<String>(
      stream: bloc.expYear,
      builder: (context, snapshot) {
        return TextField(
          controller: _expYearController,
          decoration: InputDecoration(
            labelText: "Expiration Year",
            errorText: snapshot.error?.toString(),
          ),
          onChanged: bloc.changeExpYear,
        );
      },
    );
  }

  Widget buildCardNameField(TokenizationBloc bloc) {
    return StreamBuilder<String>(
      stream: bloc.cardName,
      builder: (context, snapshot) {
        return TextField(
          controller: _cardNameController,
          decoration: InputDecoration(
            labelText: "Card Name",
            errorText: snapshot.error?.toString(),
          ),
          onChanged: bloc.changeCardName,
        );
      },
    );
  }

  Widget buildTokenizationStatus(TokenizationBloc bloc) {
    return StreamBuilder<TokenizationState>(
      stream: bloc.state,
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

  Widget buildTokenizeCardButton(TokenizationBloc bloc) {
    return StreamBuilder<bool>(
      stream: bloc.isValid, // Assuming you have added the isValid stream
      builder: (BuildContext context, AsyncSnapshot<bool> validSnapshot) {
        return StreamBuilder<TokenizationState>(
          stream: bloc.state,
          builder: (BuildContext context,
              AsyncSnapshot<TokenizationState> stateSnapshot) {
            bool isLoading =
                stateSnapshot.data?.status == TokenizationStatus.loading;

            return ElevatedButton(
              onPressed:
                  (validSnapshot.hasData && validSnapshot.data! && !isLoading)
                      ? () {
                          bloc.tokenize();
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
