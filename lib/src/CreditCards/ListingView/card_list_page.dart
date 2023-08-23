import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../main_data.dart';
import '../card_detail_public.dart';
import 'card_list_bloc.dart';
import 'card_widget.dart';

class CardListPage extends StatefulWidget {
  const CardListPage({super.key});

  @override
  CardListPageState createState() => CardListPageState();
}

class CardListPageState extends State<CardListPage> {
  final MainData _mainData = MainData();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
  }

  Future<void> _loadData(BuildContext context) async {
    final bloc = Provider.of<CardListBloc>(context, listen: false);
    await bloc.fetchCards(_mainData.userEmail ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CardListBloc>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text("Cards")),
      body: StreamBuilder<CardListState>(
        stream: bloc.state,
        builder: (context, stateSnapshot) {
          if (stateSnapshot.data == CardListState.loading) {
            return const CircularProgressIndicator();
          } else if (stateSnapshot.data == CardListState.error) {
            return const Text("An error occurred!");
          } else {
            return StreamBuilder<List<CardDetailsPublic>>(
              stream: bloc.cards,
              builder: (context, cardSnapshot) {
                if (!cardSnapshot.hasData ||
                    cardSnapshot.data?.isEmpty == true) {
                  return const Text("No cards available");
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: cardSnapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    return CardWidget(
                        cardDetailsPublic: cardSnapshot.data![index]);
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Assuming a navigation logic to add card
          // Once the card is added, it will be updated in the BLoC
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
