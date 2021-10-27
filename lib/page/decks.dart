import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:vingo/util/util.dart' as Vingo;
import 'package:vingo/widget/widget.dart' as Vingo;
import 'package:vingo/page/page.dart' as Vingo;

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

class _DecksPageState extends State<DecksPage> with TickerProviderStateMixin {
  late Vingo.Decks decks;
  late ScrollController decksScrollController;
  int selectedIndex = -1;
  double decksScrollPosition = 0.0;

  bool searchEnabled = false;
  double searchScale = 0.0;
  late TextEditingController searchController;
  late FocusNode searchFocusNode;

  bool fabEnabled = true;
  double fabScale = 1.0;
  late AnimationController fabAnimationController;

  @override
  void initState() {
    super.initState();

    decks = Vingo.Decks();

    decksScrollController = new ScrollController()
      ..addListener(onDecksScrolled);

    searchController = new TextEditingController();
    searchFocusNode = new FocusNode();

    fabAnimationController = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {
          fabScale = fabAnimationController.value;
        });
      });

    refreshDecks();
  }

  @override
  void dispose() {
    decksScrollController.dispose();
    fabAnimationController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  //----------------------------------------------------------------------------

  Future<void> refreshDecks() async {
    if (searchEnabled && searchController.text.isNotEmpty) {
      await decks.refresh(
        name: searchController.text,
      );
    } else {
      await decks.refresh();
    }
    setState(() {
      selectedIndex = -1;
      if (decksScrollController.hasClients) {
        decksScrollController.jumpTo(0.0);
      }
    });
  }

  Future<void> loadMoreDecks() async {
    int count = 0;
    if (searchEnabled && searchController.text.isNotEmpty) {
      count = await decks.loadMore(
        name: searchController.text,
      );
    } else {
      count = await decks.loadMore();
    }
    if (count == 0) return;
    setState(() {});
  }

  void onDecksScrolled() {
    // Showing/Hiding FAB
    double delta = decksScrollController.position.pixels - decksScrollPosition;
    if (delta > 0) {
      if (fabEnabled) {
        fabAnimationController.reverse(from: 1.0);
        fabEnabled = false;
      }
    } else {
      if (!fabEnabled) {
        fabAnimationController.forward(from: 0.0);
        fabEnabled = true;
      }
    }
    decksScrollPosition = decksScrollController.position.pixels;

    // Loading decks
    if (decks.loading) return;
    if (decksScrollController.position.pixels >=
        0.9 * decksScrollController.position.maxScrollExtent) {
      loadMoreDecks();
    }
  }

  void onSearchChanged(BuildContext context, String value) {
    refreshDecks();
  }

  Future<void> createDeck(BuildContext context) async {
    String? deckName = await Vingo.TextDialog.show(
      context: context,
      title: Vingo.LocalizationsUtil.of(context).deckName,
      confirmText: Vingo.LocalizationsUtil.of(context).create,
    );
    if (deckName != null) {
      await Vingo.Deck(name: deckName).insert();
      refreshDecks();
    }
  }

  Future<void> showHelp(BuildContext context) async {
    Vingo.Messenger.of(context).showTable(
      title: Vingo.LocalizationsUtil.of(context).help,
      duration: Duration(hours: 1),
      table: [
        [
          Text(Vingo.LocalizationsUtil.of(context).help),
          Text(Vingo.Shortcuts.helpShortcut),
        ],
        [
          Text(Vingo.LocalizationsUtil.of(context).search),
          Text(Vingo.Shortcuts.searchShortcut),
        ],
        [
          Text(Vingo.LocalizationsUtil.of(context).createDeck),
          Text(Vingo.Shortcuts.newShortcut),
        ],
      ],
    );
  }

  Future<void> showSearch(BuildContext context) async {
    searchEnabled = !searchEnabled;
    if (searchEnabled) searchFocusNode.requestFocus();
    refreshDecks();
  }

  void selectDeck(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> openDeck(BuildContext context, int index) async {
    if (index < 0 || index >= decks.items.length) return;
    selectDeck(index);
    final Vingo.Deck deck = decks.items[index];
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Vingo.DeckPage(
          title: "${deck.name} (${deck.totalCardsCount})",
          deck: deck,
        ),
      ),
    );
  }

  Future<void> openDeckMenu(BuildContext context, int index) async {
    if (index < 0 || index >= decks.items.length) return;
    selectDeck(index);
    final Vingo.Deck deck = decks.items[index];
    var result = await Vingo.ContextMenu.show(
      context: context,
      title: Vingo.StringUtil.addEllipsis(text: deck.name),
      items: [
        Vingo.ContextMenuItem(
          key: Key("rename"),
          title: Vingo.LocalizationsUtil.of(context).rename,
          onTap: () {
            renameDeck(context, index);
          },
        ),
        Vingo.ContextMenuItem(
          key: Key("delete"),
          title: Vingo.LocalizationsUtil.of(context).delete,
          onTap: () {
            deleteDeck(context, index);
          },
        ),
      ],
    );
  }

  Future<void> renameDeck(BuildContext context, int index) async {
    if (index < 0 || index >= decks.items.length) return;
    final Vingo.Deck deck = decks.items[index];
    var result = await Vingo.TextDialog.show(
      context: context,
      title: Vingo.LocalizationsUtil.of(context).rename,
      currentValue: deck.name,
    );
    if (result != null && result.isNotEmpty && result != deck.name) {
      deck.name = result;
      await deck.update();
      refreshDecks();
    }
  }

  Future<void> deleteDeck(BuildContext context, int index) async {
    if (index < 0 || index >= decks.items.length) return;
    final Vingo.Deck deck = decks.items[index];
    var result = await Vingo.Dialog.show(
      context: context,
      title: Vingo.LocalizationsUtil.of(context).delete,
      message: Vingo.LocalizationsUtil.of(context).areYouSureYouWantToDeleteX(
        Vingo.StringUtil.addEllipsis(text: deck.name),
      ),
      confirmButtonType: Vingo.ButtonType.SECONDARY,
      confirmText: Vingo.LocalizationsUtil.of(context).delete,
    );
    if (result == true) {
      await decks.removeAt(index);
      setState(() {});
    }
  }

  //----------------------------------------------------------------------------

  Widget searchBuilder(BuildContext context) {
    return Vingo.TextFieldExtended(
      focuseNode: searchFocusNode,
      controller: searchController,
      hintText: Vingo.LocalizationsUtil.of(context).search,
      onCloseDetected: () {
        showSearch(context); // toggle off
      },
      changeDelayInMilliseconds: 300,
      onDelayedChange: (value) {
        onSearchChanged(context, value);
      },
    );
  }

  Widget decksBuilder(BuildContext context) {
    if (decks.items.length <= 0) {
      return Expanded(
        child: Center(
          child: Container(
            child:
                Text(Vingo.LocalizationsUtil.of(context).pressXToCreateANewDeck(
              "+",
            )),
          ),
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
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.stylus,
            },
          ),
          child: ListView.builder(
            controller: decksScrollController,
            // shrinkWrap: true,
            // Force to work with one item
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount:
                decks.hasMore ? decks.items.length + 1 : decks.items.length,
            itemBuilder: (BuildContext context, int index) {
              if (index >= decks.items.length) return Container();
              final Vingo.Deck deck = decks.items[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (index == 0)
                    Divider(
                      height: 1,
                      color: selectedIndex == 0
                          ? Vingo.ThemeUtil.of(context).dividerSelectedColor
                          : Vingo.ThemeUtil.of(context).dividerColor,
                    ),
                  Directionality(
                    textDirection:
                        Vingo.LocalizationsUtil.textDirectionByStr(deck.name),
                    child: ListTileTheme(
                      selectedColor:
                          Vingo.ThemeUtil.of(context).listTileTextColor,
                      selectedTileColor:
                          Vingo.ThemeUtil.of(context).listTileBackgroundColor,
                      child: ListTile(
                        dense: false,
                        title: Text(
                          deck.name,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                        selected: selectedIndex == index,
                        // leading: Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   children: [],
                        // ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                "${deck.newCardsCount + deck.reviewCardsCount + deck.learningCardsCount}/${deck.totalCardsCount}",
                                style: TextStyle(
                                  color: Vingo.ThemeUtil.of(context)
                                      .statTotalColor,
                                  fontSize: Vingo.ThemeUtil.textFontSizeSmall,
                                ),
                              ),
                            ),
                            // Padding(
                            //   padding: const EdgeInsets.all(2.0),
                            //   child: Text(
                            //     deck.newCardsCount.toString(),
                            //     style: TextStyle(
                            //       color: Vingo.ThemeUtil.of(context).statNewColor,
                            //     ),
                            //   ),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.all(2.0),
                            //   child: Text(
                            //     deck.learningCardsCount.toString(),
                            //     style: TextStyle(
                            //       color: Vingo.ThemeUtil.of(context).statLearningColor,
                            //     ),
                            //   ),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.all(2.0),
                            //   child: Text(
                            //     deck.reviewCardsCount.toString(),
                            //     style: TextStyle(
                            //         color: Vingo.ThemeUtil.of(context).statReviewColor),
                            //   ),
                            // ),
                            Container(
                              width: 8.0,
                            ),
                            Vingo.CircularStudyIndicator(
                              width: 20,
                              height: 20,
                              totalCardsCount: deck.totalCardsCount,
                              newCardsCount: deck.newCardsCount,
                              learningCardsCount: deck.learningCardsCount,
                              reviewCardsCount: deck.reviewCardsCount,
                            ),
                            Container(
                              width: 8.0,
                            ),
                            IconButton(
                              icon: Icon(Icons.more_horiz),
                              iconSize: Vingo.ThemeUtil.iconSizeSmall,
                              splashRadius:
                                  Vingo.ThemeUtil.iconSizeSmallSplashRadius,
                              // tooltip: Vingo.LocalizationsUtil.of(context).more,
                              color: selectedIndex == index
                                  ? Vingo.ThemeUtil.of(context)
                                      .buttonPrimaryColor
                                  : Vingo.ThemeUtil.of(context).iconMutedColor,
                              hoverColor: Colors.transparent,
                              onPressed: () {
                                openDeckMenu(context, index);
                              },
                            ),
                          ],
                        ),
                        onTap: () async {
                          openDeck(context, index);
                        },
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: selectedIndex == index || selectedIndex == index + 1
                        ? Vingo.ThemeUtil.of(context).dividerSelectedColor
                        : Vingo.ThemeUtil.of(context).dividerColor,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget bodyBuilder(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [decksBuilder(context)],
    );
  }

  Widget androidBuilder(BuildContext context) {
    return Vingo.Shortcuts(
      autofocus: true,
      onNewDetected: () {
        createDeck(context);
      },
      onCloseDetected: () {
        Vingo.Messenger.of(context).hide();
      },
      onHelpDetected: () {
        showHelp(context);
      },
      onSearchDetected: () {
        showSearch(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: searchEnabled
              ? searchBuilder(context)
              : Text(
                  Vingo.LocalizationsUtil.of(context).decks,
                  style: TextStyle(
                    color: Vingo.ThemeUtil.of(context).appBarTitleTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
          leading: searchEnabled ? Container() : null,
          leadingWidth: searchEnabled ? 0.0 : null,
          actions: [
            IconButton(
              icon: searchEnabled ? Icon(Icons.search_off) : Icon(Icons.search),
              tooltip: Vingo.LocalizationsUtil.of(context).search +
                  " (" +
                  Vingo.Shortcuts.searchShortcut +
                  ")",
              onPressed: () {
                showSearch(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.help_outline),
              tooltip: Vingo.LocalizationsUtil.of(context).help +
                  " (" +
                  Vingo.Shortcuts.helpShortcut +
                  ")",
              onPressed: () {
                showHelp(context);
              },
            ),
          ],
        ),
        drawer: widget.androidDrawer,
        floatingActionButton: Transform.scale(
          scale: fabScale,
          child: FloatingActionButton(
            backgroundColor: Vingo.ThemeUtil.of(context).fabBackgroundColor,
            child: Icon(
              Icons.add,
              color: Vingo.ThemeUtil.of(context).fabIconColor,
              size: Vingo.ThemeUtil.fabIconSize,
            ),
            tooltip: Vingo.LocalizationsUtil.of(context).createDeck +
                " (" +
                Vingo.Shortcuts.newShortcut +
                ")",
            onPressed: () {
              createDeck(context);
            },
          ),
        ),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
              // statusBarColor: Colors.white,
              // systemNavigationBarColor: Colors.white,
              ),
          child: bodyBuilder(context),
        ),
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
