import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:vingo/util/util.dart' as Vingo;
import 'package:vingo/widget/widget.dart' as Vingo;

class CardPage extends StatefulWidget {
  final String? title;
  final Vingo.Deck? deck;
  final Vingo.Card? card;

  const CardPage({
    Key? key,
    this.title,
    this.deck,
    this.card,
  }) : super(key: key);

  @override
  _CardPageState createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  Vingo.Deck? deck;
  Vingo.Card? card;
  late Vingo.MarkdownEditingController frontController;
  late Vingo.MarkdownEditingController backController;
  late ScrollController scrollController;
  late ScrollController scrollControllerForPlainText;

  @override
  void initState() {
    super.initState();

    frontController = Vingo.MarkdownEditingController();
    backController = Vingo.MarkdownEditingController();

    if (widget.deck != null) {
      deck = widget.deck!;
    }
    if (widget.card != null) {
      card = widget.card!;
      frontController.text = card!.front;
      backController.text = card!.back ?? "";
    }

    scrollController = ScrollController(keepScrollOffset: true);
    scrollControllerForPlainText = ScrollController(keepScrollOffset: true);
  }

  @override
  void dispose() {
    frontController.dispose();
    backController.dispose();
    scrollController.dispose();
    scrollControllerForPlainText.dispose();
    super.dispose();
  }

  //----------------------------------------------------------------------------

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
          Text(Vingo.LocalizationsUtil.of(context).save),
          Text(Vingo.LocalizationsUtil.of(context).saveShortcut),
        ],
      ],
    );
  }

  Future<void> saveCard(BuildContext context) async {
    if (card == null) {
      card = new Vingo.Card(
        deckId: deck!.id!,
        front: frontController.text,
        back: backController.text,
      );
      await card!.insert();
    } else {
      card!.front = frontController.text;
      card!.back = backController.text;
      await card!.update();
    }
    Vingo.Messenger.of(context).showText(
      text: Vingo.LocalizationsUtil.of(context).saved,
    );
  }

  //----------------------------------------------------------------------------

  Widget bodyBuilder(BuildContext context, bool plainTextEnabled) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
        },
      ),
      child: SingleChildScrollView(
        // Forces scroll view to keep its position on tab switch
        // key: !plainTextEnabled
        //     ? PageStorageKey("markdown")
        //     : PageStorageKey("plaintext"),
        controller:
            !plainTextEnabled ? scrollController : scrollControllerForPlainText,
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(
          left: Vingo.ThemeUtil.padding,
          right: Vingo.ThemeUtil.padding,
          top: Vingo.ThemeUtil.padding,
          bottom: Vingo.ThemeUtil.padding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Vingo.Markdown(
              controller: frontController,
              hintText: Vingo.LocalizationsUtil.of(context).cardFront,
              enabled: plainTextEnabled,
              padding: EdgeInsets.only(
                bottom: Vingo.ThemeUtil.padding,
              ),
            ),
            Vingo.Markdown(
              controller: backController,
              hintText: Vingo.LocalizationsUtil.of(context).cardBack,
              enabled: plainTextEnabled,
              padding: EdgeInsets.only(
                bottom: Vingo.ThemeUtil.padding,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget androidBuilder(BuildContext context) {
    return Vingo.Shortcuts(
      autofocus: true,
      onCloseDetected: () {
        Vingo.Messenger.of(context).hide();
      },
      onHelpDetected: () {
        showHelp(context);
      },
      onBackDetected: () {
        // TODO: Ask before leaving the page if anything is unsaved.
        Navigator.of(context).pop(false);
      },
      onSaveDetected: () {
        saveCard(context);
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          // backgroundColor: Vingo.ThemeUtil.of(context).formBackgroundColor,
          appBar: AppBar(
            // backgroundColor: Vingo.ThemeUtil.of(context).formBackgroundColor,
            title: Text(
              widget.title ??
                  (widget.card != null
                      ? Vingo.LocalizationsUtil.of(context).viewCard
                      : Vingo.LocalizationsUtil.of(context).createCard),
              style: TextStyle(
                color: Vingo.ThemeUtil.of(context).appBarTitleTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.save_outlined),
                tooltip: Vingo.LocalizationsUtil.of(context).save +
                    " (" +
                    Vingo.LocalizationsUtil.of(context).saveShortcut +
                    ")",
                onPressed: () {
                  saveCard(context);
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
            bottom: TabBar(
              indicatorColor:
                  Vingo.ThemeUtil.of(context).progressIndicatorValueColor,
              tabs: [
                Tab(
                  icon: Icon(
                    Icons.remove_red_eye_outlined,
                    color: Vingo.ThemeUtil.of(context).iconColor,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.code,
                    color: Vingo.ThemeUtil.of(context).iconColor,
                  ),
                ),
              ],
              onTap: (value) {
                if (value == 0) {
                  // markdown view
                  frontController.plainTextEnabled = false;
                  backController.plainTextEnabled = false;
                } else {
                  // plain text view
                  frontController.plainTextEnabled = true;
                  backController.plainTextEnabled = true;
                }
              },
            ),
          ),
          body: TabBarView(
            children: [
              bodyBuilder(context, false),
              bodyBuilder(context, true),
            ],
          ),
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