import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../../services/navigation_service.dart';
import '../AddDialog/card_details_page.dart';
import '../card_detail_public.dart';
import 'card_list_bloc.dart';
import 'card_widget.dart';

class CardListPage extends StatefulWidget {
  static const routeName = '/CardListPage'; // Named route
  final bool editMode;

  const CardListPage({super.key, required this.editMode});

  @override
  CardListPageState createState() => CardListPageState();
}

class CardListPageState extends State<CardListPage> {
  final _navigationService = GetIt.instance<NavigationService>();

  String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    // Schedules _loadData to be called after the current frame has been drawn,
    // ensuring that the widget has been fully built. This avoids potential issues
    // related to accessing the context and modifying the state within initState.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
  }

  Future<void> _loadData(BuildContext context) async {
    final bloc = Provider.of<CardListBloc>(context, listen: false);
    await bloc.fetchCards();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CardListBloc>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cards"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _selectedCardId == null
                ? null
                : () => _deleteSelectedCard(context, bloc),
          ),
        ],
      ),
      body: _buildBody(bloc),
      floatingActionButton: _buildFloatingActionButton(bloc),
    );
  }

  Widget _buildBody(CardListBloc bloc) {
    return StreamBuilder<CardListState>(
      stream: bloc.state,
      builder: (context, stateSnapshot) {
        if (stateSnapshot.data == CardListState.loading) {
          return const CircularProgressIndicator();
        } else if (stateSnapshot.data == CardListState.error) {
          return const Text("An error occurred!");
        } else {
          return _buildCardList(bloc);
        }
      },
    );
  }

  Widget _buildCardList(CardListBloc bloc) {
    return StreamBuilder<List<CardDetailsPublic>>(
      stream: bloc.cards,
      builder: (context, cardSnapshot) {
        if (!cardSnapshot.hasData || cardSnapshot.data?.isEmpty == true) {
          return const Text("No cards available");
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemCount: cardSnapshot.data?.length ?? 0,
          itemBuilder: (context, index) {
            return CardWidget(
              cardDetailsPublic: cardSnapshot.data![index],
              onTap: _handleCardSelection, // Add the selection handler
            );
          },
        );
      },
    );
  }

  void _handleCardSelection(String cardId) {
    setState(() {
      _selectedCardId = cardId;
    });
  }

  Widget _buildFloatingActionButton(CardListBloc bloc) {
    return StreamBuilder<CardListState>(
      stream: bloc.state,
      builder: (context, stateSnapshot) {
        return FloatingActionButton(
          onPressed: stateSnapshot.data == CardListState.loading
              ? null
              : () {
                  _navigationService.navigateTo(CardDetailsPage.routeName);
                },
          child: const Icon(Icons.add),
        );
      },
    );
  }

  void _deleteSelectedCard(BuildContext context, CardListBloc bloc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Card"),
        content: const Text("Are you sure you want to delete this card?"),
        actions: [
          TextButton(
            onPressed: () =>
                _navigationService.goBack(), // Updated to use NavigationService
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              var scr = ScaffoldMessenger.of(context);
              await bloc.deleteCard(_selectedCardId!);
              scr.showSnackBar(
                const SnackBar(content: Text("Card deleted successfully")),
              );
              setState(() => _selectedCardId = null);
              _navigationService.goBack(); // Updated to use NavigationService
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
