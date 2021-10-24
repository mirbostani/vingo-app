import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:vingo/util/util.dart' as Vingo;
import 'package:vingo/widget/widget.dart' as Vingo;
import 'package:vingo/page/page.dart' as Vingo;

class DeckPage extends StatefulWidget {
  final String title;
  final Vingo.Deck deck;

  const DeckPage({
    Key? key,
    required this.title,
    required this.deck,
  }) : super(key: key);

  @override
  _DeckPageState createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> with TickerProviderStateMixin {
  late Vingo.Cards cards;
  late ScrollController cardsScrollController;
  int selectedIndex = -1;
  double cardsScrollPosition = 0.0;

  Key? draggableKey;
  Key? lastMoveDragKey;
  Key? lastMoveTargetKey;
  bool? lastMoveUpward;

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

    cards = Vingo.Cards();

    cardsScrollController = new ScrollController()
      ..addListener(onCardsScrolled);

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

    refreshCards();
  }

  @override
  void dispose() {
    cardsScrollController.dispose();
    fabAnimationController.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  //----------------------------------------------------------------------------

  Future<void> refreshCards() async {
    if (searchEnabled && searchController.text.isNotEmpty) {
      await cards.refresh(
        deckId: widget.deck.id,
        search: searchController.text,
      );
    } else {
      await cards.refresh(
        deckId: widget.deck.id,
      );
    }
    setState(() {
      selectedIndex = -1;
      if (cardsScrollController.hasClients) {
        cardsScrollController.jumpTo(0.0);
      }
    });
  }

  Future<void> loadMoreCards() async {
    int count = 0;
    if (searchEnabled && searchController.text.isNotEmpty) {
      count = await cards.loadMore(
        deckId: widget.deck.id,
        search: searchController.text,
      );
    } else {
      count = await cards.loadMore(deckId: widget.deck.id);
    }
    if (count == 0) return;
    setState(() {});
  }

  void onCardsScrolled() {
    // Showing/Hiding FAB
    double delta = cardsScrollController.position.pixels - cardsScrollPosition;
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
    cardsScrollPosition = cardsScrollController.position.pixels;

    // Loading cards
    if (cards.loading) return;
    if (cardsScrollController.position.pixels >=
        0.9 * cardsScrollController.position.maxScrollExtent) {
      loadMoreCards();
    }
  }

  void onSearchChanged(BuildContext context, String value) {
    refreshCards();
  }

  Future<void> studyDeck(BuildContext context) async {
    print("Study Deck");
  }

  Future<void> createCard(BuildContext context) async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Vingo.CardPage(
          deck: widget.deck,
        ),
      ),
    );
    refreshCards();
  }

  Future<void> showHelp(BuildContext context) async {
    Vingo.Messenger.of(context).showTable(
      title: Vingo.LocalizationsUtil.of(context).help,
      duration: Duration(hours: 1),
      table: [
        [
          Text(Vingo.LocalizationsUtil.of(context).help),
          Text(Vingo.LocalizationsUtil.of(context).helpShortcut),
        ],
        [
          Text(Vingo.LocalizationsUtil.of(context).back),
          Text(Vingo.LocalizationsUtil.of(context).backShortcut),
        ],
        [
          Text(Vingo.LocalizationsUtil.of(context).search),
          Text(Vingo.LocalizationsUtil.of(context).searchShortcut),
        ],
        [
          Text(Vingo.LocalizationsUtil.of(context).study),
          Text(Vingo.LocalizationsUtil.of(context).studyShortcut),
        ],
        [
          Text(Vingo.LocalizationsUtil.of(context).createANewCard),
          Text(Vingo.LocalizationsUtil.of(context).createANewCardShortcut),
        ],
      ],
    );
  }

  Future<void> showSearch(BuildContext context) async {
    searchEnabled = !searchEnabled;
    if (searchEnabled) searchFocusNode.requestFocus();
    refreshCards();
  }

  void selectCard(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Future<void> openCard(BuildContext context, int index) async {
    if (index < 0 || index >= cards.items.length) return;
    selectCard(index);
    final Vingo.Card card = cards.items[index];
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Vingo.CardPage(
          deck: widget.deck,
          card: card,
        ),
      ),
    );
  }

  Future<void> openCardMenu(BuildContext context, int index) async {
    if (index < 0 || index >= cards.items.length) return;
    selectCard(index);
    final Vingo.Card card = cards.items[index];
    var result = await Vingo.ContextMenu.show(
      context: context,
      title: Vingo.StringUtil.addEllipsis(
        text: Vingo.LocalizationsUtil.of(context).card,
      ),
      items: [
        Vingo.ContextMenuItem(
          key: Key("delete"),
          title: Vingo.LocalizationsUtil.of(context).delete,
          onTap: () {
            deleteCard(context, index);
          },
        ),
      ],
    );
  }

  Future<void> deleteCard(BuildContext context, int index) async {
    if (index < 0 || index >= cards.items.length) return;
    final Vingo.Card card = cards.items[index];
    var result = await Vingo.Dialog.show(
      context: context,
      title: Vingo.LocalizationsUtil.of(context).delete,
      message: Vingo.LocalizationsUtil.of(context).areYouSure,
      confirmButtonType: Vingo.ButtonType.SECONDARY,
      confirmText: Vingo.LocalizationsUtil.of(context).delete,
    );
    if (result == true) {
      await cards.removeAt(index);
      setState(() {
        selectedIndex = -1;
      });
    }
  }

  Future<void> move(Key? dragKey, Key? targetKey, bool upward) async {
    if (dragKey == null || targetKey == null) return;
    if (dragKey == lastMoveDragKey &&
        targetKey == lastMoveTargetKey &&
        upward == lastMoveUpward) return;

    // print("$dragKey $targetKey $upward");

    dragKey as ValueKey;
    targetKey as ValueKey;

    int dragIndex = cards.items.indexWhere(
        (item) => item.id == (dragKey.value as Map<String, dynamic>)["id"]);
    Vingo.Card? dragItem;
    if (dragIndex != -1) {
      dragItem = cards.items.removeAt(dragIndex);
    }
    int targetIndex = cards.items.indexWhere(
        (item) => item.id == (targetKey.value as Map<String, dynamic>)["id"]);
    targetIndex = targetIndex + (upward ? 0 : 1);
    if (targetIndex != -1 && dragItem != null) {
      cards.items.insert(targetIndex, dragItem);
    }

    setState(() {
      lastMoveDragKey = dragKey;
      lastMoveTargetKey = targetKey;
      lastMoveUpward = upward;
    });
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

  Widget cardsBuilder(BuildContext context) {
    if (cards.items.length <= 0) {
      return Expanded(
        child: Center(
          child: Container(
            child:
                Text(Vingo.LocalizationsUtil.of(context).pressXToCreateANewCard(
              Vingo.LocalizationsUtil.of(context).createANewCardShortcut,
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
          refreshCards();
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
            controller: cardsScrollController,
            // shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount:
                cards.hasMore ? cards.items.length + 1 : cards.items.length,
            itemBuilder: (BuildContext context, int index) {
              if (index >= cards.items.length) return Container();
              final Vingo.Card card = cards.items[index];
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
                    textDirection: Vingo.LocalizationsUtil.textDirectionByStr(
                      card.front,
                    ),
                    child: Vingo.DraggableListTile(
                      key: ValueKey({"id": card.id}),
                      enableDraggable: false,
                      // showDraggable: !(invisibleDraggableKey?.value == card.id),
                      level: 0,
                      title: Text(
                        card.front,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      // leadingIcon: Icon(
                      //   Icons.arrow_right,
                      //   color: selectedIndex == index
                      //       ? Vingo.ThemeUtil.of(context).buttonPrimaryColor
                      //       : Vingo.ThemeUtil.of(context).iconMutedColor,
                      // ),
                      tileColor: selectedIndex == index
                          ? Vingo.ThemeUtil.of(context).listTileBackgroundColor
                          : null,
                      moreButtonColor: selectedIndex == index
                          ? Vingo.ThemeUtil.of(context).buttonPrimaryColor
                          : Vingo.ThemeUtil.of(context).iconMutedColor,
                      onMorePressed: (key) {
                        openCardMenu(context, index);
                      },
                      onDragStarted: (key) {
                        selectedIndex = -1;
                        draggableKey = key;
                      },
                      onDragEnded: (key) {
                        draggableKey = null;
                      },
                      onDragCanceled: (key) {
                        draggableKey = null;
                      },
                      onDragTargetMoveUp: (key) {
                        move(draggableKey, key, false);
                      },
                      onDragTargetMoveDown: (key) {
                        move(draggableKey, key, true);
                      },
                      onDragTargetAcceptChild: (draggableKey, dragTargetKey) {
                        // selectedIndex = index;
                        // setState(() {});
                        // print('onDragTargetAcceptedChild: $dragTargetKey -> $dragTargetKey');
                      },
                      onTap: (key) {
                        openCard(context, index);
                      },
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
      children: [
        cardsBuilder(context),
      ],
    );
  }

  Widget androidBuilder(BuildContext context) {
    return Vingo.Shortcuts(
      autofocus: true,
      onNewDetected: () {
        createCard(context);
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
      onBackDetected: () {
        Navigator.of(context).pop(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: searchEnabled
              ? searchBuilder(context)
              : Text(
                  widget.title,
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
                  Vingo.LocalizationsUtil.of(context).searchShortcut +
                  ")",
              onPressed: () {
                showSearch(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.help_outline),
              tooltip: Vingo.LocalizationsUtil.of(context).help +
                  " (" +
                  Vingo.LocalizationsUtil.of(context).helpShortcut +
                  ")",
              onPressed: () {
                showHelp(context);
              },
            ),
          ],
        ),
        floatingActionButton: Transform.scale(
          scale: fabScale,
          child: Vingo.MultipleFabButton(
            children: [
              // Vingo.MultipleFabButtonChild(
              //   icon: Icons.local_library,
              //   scale: 0.85,
              //   title: Vingo.LocalizationsUtil.of(context).study,
              //   // tooltip: Vingo.LocalizationsUtil.of(context).study +
              //   //     " (" +
              //   //     Vingo.LocalizationsUtil.of(context).studyShortcut +
              //   //     ")",
              //   onPressed: () {
              //     studyDeck(context);
              //   },
              // ),
              Vingo.MultipleFabButtonChild(
                icon: Icons.add,
                scale: 0.85,
                title: Vingo.LocalizationsUtil.of(context).createANewCard,
                // tooltip: Vingo.LocalizationsUtil.of(context).createANewCard +
                //     " (" +
                //     Vingo.LocalizationsUtil.of(context).createANewCardShortcut +
                //     ")",
                onPressed: () {
                  createCard(context);
                },
              ),
            ],
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
