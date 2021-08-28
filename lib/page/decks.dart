import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:vingo/util/localizations.dart' as Vingo;
import 'package:vingo/util/theme.dart' as Vingo;
import 'package:vingo/util/sqlite.dart' as Vingo;
import 'package:vingo/util/platform.dart' as Vingo;
import 'package:vingo/widget/platform.dart' as Vingo;
import 'package:vingo/widget/input_dialog.dart' as Vingo;
import 'package:vingo/widget/shortcuts.dart' as Vingo;

class DecksPage extends StatefulWidget {
  static const String route = "/decks";
  static const String title = "Decks";
  static const Icon icon = Icon(Icons.inbox);
  final Widget? androidDrawer;

  const DecksPage({
    Key? key,
    this.androidDrawer,
  }) : super(key: key);

  @override
  _DecksPageState createState() => _DecksPageState();
}

class _DecksPageState extends State<DecksPage> {
  late Vingo.Decks decks;
  late ScrollController decksScrollController;

  @override
  void initState() {
    super.initState();
    decks = Vingo.Decks();
    decksScrollController = new ScrollController()
      ..addListener(onDecksScrolled);
    refreshDecks();
  }

  @override
  void dispose() {
    decksScrollController.dispose();
    super.dispose();
  }

  //----------------------------------------------------------------------------

  Future<void> refreshDecks() async {
    await decks.refresh();
    setState(() {
      if (decksScrollController.hasClients) {
        decksScrollController.jumpTo(0.0);
      }
    });
  }

  Future<void> loadMoreDecks() async {
    int count = await decks.loadMore();
    if (count == 0) return;
    setState(() {});
  }

  void onDecksScrolled() {
    if (decks.loading) return;
    if (decksScrollController.position.pixels >=
        0.9 * decksScrollController.position.maxScrollExtent) {
      decks.loadMore();
    }
  }

  Future<void> createDeck(BuildContext context) async {
    String? deckName = await Vingo.InputDialog.show(
      context: context,
      title: Vingo.LocalizationsUtil.of(context).deckName,
      confirmText: Vingo.LocalizationsUtil.of(context).create,
    );
    if (deckName != null) {
      await Vingo.Deck(name: deckName).insert();
      refreshDecks();
    }
  }

  //----------------------------------------------------------------------------

  Widget decksBuilder(BuildContext context) {
    if (decks.items.length <= 0) {
      return Expanded(
        child: Container(
          child: Text("Empty"),
        ),
      );
    }
    return Expanded(
      child: RefreshIndicator(
        backgroundColor:
            Vingo.ThemeUtil.of(context).refreshIndicatorBackgroundColor,
        color: Vingo.ThemeUtil.of(context).refreshIndicatorColor,
        onRefresh: () async {
          refreshDecks();
        },
        child: ListView.builder(
          controller: decksScrollController,
          // Force to work with one item
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount:
              decks.hasMore ? decks.items.length + 1 : decks.items.length,
          itemBuilder: (BuildContext context, int index) {
            if (index >= decks.items.length) return Container();
            final deck = decks.items[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Directionality(
                  textDirection:
                      Vingo.LocalizationsUtil.textDirectionByStr(deck.name),
                  child: ListTile(
                    dense: true,
                    title: Text(deck.name),
                    onTap: () async {},
                    onLongPress: () async {},
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget bodyBuilder(BuildContext context) {
    return Vingo.Shortcuts(
      autofocus: true,
      onNewDetected: () {
        createDeck(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          decksBuilder(context),
        ],
      ),
    );
  }

  Widget androidBuilder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Vingo.LocalizationsUtil.of(context).decks,
          style: TextStyle(
            color: Vingo.ThemeUtil.of(context).appBarTitleTextColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [],
      ),
      drawer: widget.androidDrawer,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Vingo.ThemeUtil.of(context).fabBackgroundColor,
        child: Icon(
          Icons.add,
          color: Vingo.ThemeUtil.of(context).fabIconColor,
          size: Vingo.ThemeUtil.fabIconSize,
        ),
        onPressed: () {
          createDeck(context);
        },
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            // statusBarColor: Colors.white,
            // systemNavigationBarColor: Colors.white,
            ),
        child: bodyBuilder(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Vingo.Platform(
      defaultBuilder: androidBuilder,
    );
  }
}
