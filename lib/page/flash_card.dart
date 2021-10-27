import 'dart:io' as Io;
import 'dart:ui';
import 'dart:math';
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:vingo/page/page.dart' as Vingo;
import 'package:vingo/widget/widget.dart' as Vingo;
import 'package:vingo/util/util.dart' as Vingo;

class FlashCardPage extends StatefulWidget {
  final String title;
  final Vingo.Deck deck;
  final List<Vingo.Card> newCards;
  final List<Vingo.Card> learningCards;
  final List<Vingo.Card> reviewCards;
  final void Function()? onStart;
  final void Function(Vingo.Card? card)? onEdit;
  final void Function(Vingo.Card? card)? onEdited;

  /// These are used for creating multiple-choice study type.
  /// In case of being `null`, flash card study mode will be used.
  final Map<Vingo.Card, dynamic>? cardSynonyms;
  final Map<Vingo.Card, dynamic>? cardDefinitions;
  final Map<Vingo.Card, dynamic>? cardTranslations;

  const FlashCardPage({
    Key? key,
    required this.title,
    required this.deck,
    required this.newCards,
    required this.learningCards,
    required this.reviewCards,
    this.cardSynonyms,
    this.cardDefinitions,
    this.cardTranslations,
    this.onStart,
    this.onEdit,
    this.onEdited,
  }) : super(key: key);

  @override
  _FlashCardPageState createState() => _FlashCardPageState();
}

class _FlashCardPageState extends State<FlashCardPage> {
  bool showBack = false;
  bool studyFinished = false;
  List<int> collectionIds = <int>[];
  String currentChoice = "";
  List<String> currentCardChoices = <String>[];
  String? currentSpell = "";
  bool currentSpellSubmitted = false;
  late TextEditingController currentSpellController;
  Vingo.Card? currentCard;
  int? currentCollectionId;
  int? previousLearningCardTriggered; // since epoch
  static const int nextLearningCardDelay = 60; // seconds
  int progressTotalCount = -1;
  int progressCurrentCount = -1;
  int progressConsecutiveCount = 0;
  DateTime progressStart = DateTime.now();

  bool synonymsMultipleChoiceEnabled = false;
  bool definitionsMultipleChoiceEnabled = false;
  bool translationsMultipleChoiceEnabled = false;

  @override
  void initState() {
    super.initState();

    // @see [kf7y93gg] Learning card selection is handled based on a timer
    // 0: new cards
    // 1: learning cards
    // 2: review cards
    // collectionIds = <int>[0, 1, 2];
    collectionIds = <int>[0, 2];

    currentSpellController = TextEditingController();
  }

  @override
  void dispose() {
    currentSpellController.dispose();
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
          Text(Vingo.Shortcuts.helpShortcut),
        ],
        [
          Text(Vingo.LocalizationsUtil.of(context).back),
          Text(Vingo.Shortcuts.backShortcut),
        ],
      ],
    );
  }

  Map<String, int> countCards() {
    int countNewCards = widget.newCards.length;
    int countLearningCards = widget.learningCards.length;
    int countReviewCards = widget.reviewCards.length;
    // In getCards() invoke, a card will be retrieved from one of the above
    // lists. We have to add that one manually so that the count lists to be
    // calculated correctly.
    if (currentCollectionId == 0) {
      countNewCards += 1;
    } else if (currentCollectionId == 1) {
      countLearningCards += 1;
    } else if (currentCollectionId == 2) {
      countReviewCards += 1;
    }
    int countTotalCards = countNewCards + countLearningCards + countReviewCards;
    return {
      "new_cards": countNewCards,
      "learning_cards": countLearningCards,
      "review_cards": countReviewCards,
      "total_cards": countTotalCards,
    };
  }

  void updateSRS(int easinessQuality) async {
    if (currentCard == null) return;
    switch (easinessQuality) {
      case 5: // easy
      case 4: // good
      case 3: // hard
        // Update card SRS info
        currentCard!.updateSRS(easinessQuality);
        await currentCard!.update();
        break;
      case 2: // again
        // Update card SRS info
        currentCard!.updateSRS(easinessQuality);
        await currentCard!.update();
        widget.learningCards.add(currentCard!);
        // @see [kf7y93gg] Learning card selection is handled based on a timer
        // if (!collectionIds.contains(1)) {
        //   // 1: learning cards
        //   collectionIds.add(1);
        // }
        // @see [kf7y93gg] Learning card selection is handled based on a timer
        // Set learning trigger date time
        if (previousLearningCardTriggered == null) {
          previousLearningCardTriggered =
              new DateTime.now().millisecondsSinceEpoch ~/ 1000;
        }
        break;
    }

    showBack = false;
    currentCard = null;
    currentSpell = "";
    currentSpellController.text = "";
    currentSpellSubmitted = false;
    currentCollectionId = null;

    var count = countCards();
    if (count["total_cards"] == 0) {
      studyFinished = true;
    }

    setState(() {});
  }

  Vingo.Card? getCard() {
    if (collectionIds.length == 0) {
      return null;
    }

    // Randomly select between new, learning, or review cards.
    var random = new Random();
    int n = collectionIds[random.nextInt(collectionIds.length)];

    // @see [kf7y93gg] Learning card selection is handled based on a timer
    // Force learning cards when requirements are valid
    if (widget.learningCards.length > 0) {
      // Set learning trigger date time when there are pending learning cards.
      if (previousLearningCardTriggered == null) {
        previousLearningCardTriggered =
            new DateTime.now().millisecondsSinceEpoch ~/ 1000;
      }
      int now = new DateTime.now().millisecondsSinceEpoch ~/ 1000;
      // Force if timer duration for learning cards is passed
      if (now > previousLearningCardTriggered! + nextLearningCardDelay) {
        n = 1;
        previousLearningCardTriggered = null;
      }
      if (widget.newCards.length + widget.reviewCards.length < 10) {
        // 10
        n = 1;
        previousLearningCardTriggered = null;
      }
    }

    // new cards
    if (n == 0) {
      if (widget.newCards.length == 0) {
        collectionIds.remove(0);
        return getCard();
      }
      currentCard = widget.newCards.removeAt(0);
      currentCollectionId = n;
    }
    // learning cards
    else if (n == 1) {
      if (widget.learningCards.length == 0) {
        collectionIds.remove(1);
        return getCard();
      }
      currentCard = widget.learningCards.removeAt(0);
      currentCollectionId = n;
    }
    // review cards
    else if (n == 2) {
      if (widget.reviewCards.length == 0) {
        collectionIds.remove(2);
        return getCard();
      }
      currentCard = widget.reviewCards.removeAt(0);
      currentCollectionId = n;
    }

    if (currentCard != null) {
      return currentCard;
    }

    return null;
  }

  void editCard(BuildContext context, Vingo.Card? card) async {
    widget.onEdit?.call(currentCard); // Callback

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Vingo.CardPage(
          deck: widget.deck,
          card: card,
          // TODO
          // onCardEdited: (Vingo.Card _card) async {
          //   widget.onEdited(_card);
          //   setState(() {
          //     currentCard = _card;
          //   });
          // },
        ),
      ),
    );
  }

  Widget spellCheckWidget(BuildContext context) {
    List<TextSpan> letters = <TextSpan>[];
    List<String> wordLetters = <String>[];
    if (currentCard != null) {
      wordLetters = currentCard!.front.split('');
    }
    if (currentSpell == null) {
      currentSpell = "";
    }
    int delta = wordLetters.length - currentSpell!.length;
    if (delta > 0) {
      currentSpell = currentSpell! +
          List<String>.generate(delta, (index) => '*').join('').toString();
    }
    List<String> spellLetters = currentSpell!.split('');
    Color? color;
    for (int i = 0; i < wordLetters.length; i++) {
      if (i < spellLetters.length) {
        if (wordLetters[i] == spellLetters[i]) {
          color = Colors.green;
        } else {
          color = Colors.red;
        }
      } else {
        // color = Colors.grey;
      }
      letters.add(
        TextSpan(
          text: wordLetters[i],
          style: TextStyle(
            backgroundColor: color,
            fontSize: Vingo.ThemeUtil.textFontSizeLarge,
          ),
        ),
      );
    }
    Widget richText = RichText(
      text: TextSpan(
        children: letters,
      ),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: Vingo.ThemeUtil.padding,
        right: Vingo.ThemeUtil.padding,
        top: Vingo.ThemeUtil.padding,
        bottom: Vingo.ThemeUtil.padding,
      ),
      constraints: BoxConstraints(
        minHeight: Vingo.ThemeUtil.fieldHeight,
      ),
      decoration: BoxDecoration(
        color: Vingo.ThemeUtil.of(context).backgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Vingo.ThemeUtil.borderRadiusDouble),
          bottomRight: Radius.circular(Vingo.ThemeUtil.borderRadiusDouble),
          topLeft: Radius.circular(Vingo.ThemeUtil.borderRadiusDouble),
          topRight: Radius.circular(Vingo.ThemeUtil.borderRadiusDouble),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [richText],
      ),
    );
  }

  Future<void> playAudioNormal({
    required BuildContext context,
    bool playFirstDefinition = false,
  }) async {
    if (currentCard == null) return;
    if (widget.deck.autoplayPronunciationEnabled) {
      if (!playFirstDefinition) {
        // await Vingo.AudioExtended.playFirstAudio(
        //   context: context,
        //   content: currentCard.back,
        //   attachment: currentCard.attachment,
        //   speed: 1.0,
        // );
      } else {
        // await Vingo.AudioExtended.playFirstDefinitionAudio(
        //   context: context,
        //   content: currentCard.back,
        //   attachment: currentCard.attachment,
        //   speed: 1.0,
        // );
      }
    }
  }

  Future<void> playAudioSlow({
    required BuildContext context,
    bool playFirstDefinition = false,
  }) async {
    if (currentCard == null) return;
    if (widget.deck.autoplayPronunciationEnabled) {
      if (!playFirstDefinition) {
        // await Vingo.AudioExtended.playFirstAudio(
        //   context: context,
        //   content: currentCard.back,
        //   speed: 0.5,
        // );
      } else {
        // await Vingo.AudioExtended.playFirstDefinitionAudio(
        //   context: context,
        //   content: currentCard.back,
        //   speed: 0.5,
        // );
      }
    }
  }

  void showBackOfCard() async {
    // Show Answer is triggered
    setState(() {
      if (widget.deck.spellCheckEnabled && !currentSpellSubmitted) {
        currentSpell = currentSpellController.text;
        currentSpellSubmitted = true;
      }
      showBack = true;
    });
  }

  List<String> prepareCurrentCardSynonymsChoices() {
    // Prepare right choice
    var random = new Random();
    List<String> choices = <String>[];
    if (widget.cardSynonyms == null) return choices;

    List<dynamic> synonyms = <dynamic>[];
    (widget.cardSynonyms![currentCard] as List<dynamic>).forEach((synonymsSet) {
      synonyms.addAll(synonymsSet);
    });
    String rightChoice = synonyms[random.nextInt(synonyms.length)].toString();
    choices.add(rightChoice);
    List<dynamic> keys = widget.cardSynonyms!.keys.toList();
    keys.remove(currentCard);
    // Prepare wrong choices
    for (int i = 0; i < 3; i++) {
      var randomCard = keys[random.nextInt(keys.length)];
      synonyms.clear();
      (widget.cardSynonyms![randomCard] as List<dynamic>)
          .forEach((synonymsSet) {
        synonyms.addAll(synonymsSet);
      });
      String wrongChoice = synonyms[random.nextInt(synonyms.length)].toString();
      choices.add(wrongChoice);
      keys.remove(randomCard);
    }
    choices.shuffle();
    currentCardChoices = choices;
    return choices;
  }

  List<int> validateCurrentCardSynonymsChoices() {
    List<int> answers = <int>[];
    if (widget.cardSynonyms == null) return answers;

    List<dynamic> synonyms = <dynamic>[];
    (widget.cardSynonyms![currentCard] as List<dynamic>).forEach((synonymsSet) {
      synonyms.addAll(synonymsSet);
    });
    List<String> s = synonyms.map((e) => e.toString()).toList();
    for (int i = 0; i < currentCardChoices.length; i++) {
      String choice = currentCardChoices[i];
      if (s.indexOf(choice) != -1) {
        answers.add(4); // good
      } else {
        answers.add(2); // again
      }
    }
    return answers;
  }

  String getCurrentCardDefinitionsRightChoice() {
    if (widget.cardDefinitions == null) return "";

    var random = new Random();
    List<dynamic> definitions = <dynamic>[];
    (widget.cardDefinitions![currentCard] as List<dynamic>)
        .forEach((definitionsSet) {
      definitions.addAll(definitionsSet);
    });
    String currentDefinition =
        definitions[random.nextInt(definitions.length)].toString();
    return currentDefinition;
  }

  List<String> prepareCurrentCardDefinitionsChoices() {
    // Prepare right choices
    var random = new Random();
    List<String> choices = <String>[];
    if (widget.cardDefinitions == null || currentCard == null) return choices;

    String rightChoice = currentCard!.front;
    choices.add(rightChoice);
    List<dynamic> keys = widget.cardDefinitions!.keys.toList();
    keys.remove(currentCard);
    // Prepare wrong choices
    for (int i = 0; i < 3; i++) {
      var randomCard = keys[random.nextInt(keys.length)];
      String wrongChoice = randomCard.front;
      choices.add(wrongChoice);
      keys.remove(randomCard);
    }
    choices.shuffle();
    currentCardChoices = choices;
    return choices;
  }

  List<int> validateCurrentCardDefinitionsChoices() {
    List<int> answers = <int>[];
    if (currentCard == null) return answers;

    for (int i = 0; i < currentCardChoices.length; i++) {
      String choice = currentCardChoices[i];
      if (currentCard!.front == choice) {
        answers.add(4); // good
      } else {
        answers.add(2);
      }
    }
    return answers;
  }

  String getCurrentCardTranslationsRightChoice() {
    if (widget.cardTranslations == null) return "";

    var random = new Random();
    List<dynamic> translations = <dynamic>[];
    (widget.cardTranslations![currentCard] as List<dynamic>)
        .forEach((translationsSet) {
      translations.addAll(translationsSet);
    });
    String currentTranslation =
        translations[random.nextInt(translations.length)].toString();
    return currentTranslation;
  }

  List<String> prepareCurrentCardTranslationsChoices() {
    // Prepare right choices
    var random = new Random();
    List<String> choices = <String>[];
    if (widget.cardTranslations == null || currentCard == null) return choices;

    String rightChoice = currentCard!.front;
    choices.add(rightChoice);
    List<dynamic> keys = widget.cardTranslations!.keys.toList();
    keys.remove(currentCard);
    // Prepare wrong choices
    for (int i = 0; i < 3; i++) {
      var randomCard = keys[random.nextInt(keys.length)];
      String wrongChoice = randomCard.front;
      choices.add(wrongChoice);
      keys.remove(randomCard);
    }
    choices.shuffle();
    currentCardChoices = choices;
    return choices;
  }

  List<int> validateCurrentCardTranslationsChoices() {
    List<int> answers = <int>[];
    if (currentCard == null) return answers;

    for (int i = 0; i < currentCardChoices.length; i++) {
      String choice = currentCardChoices[i];
      if (currentCard!.front == choice) {
        answers.add(4); // good
      } else {
        answers.add(2);
      }
    }
    return answers;
  }

  //----------------------------------------------------------------------------

  Widget multipleChoicesBuilder(
    BuildContext context, {
    required List<String> choices,
    List<int>? validatedChoices,
    required Widget countCardsWidget,
  }) {
    int good = 4;
    int again = 2;
    return Padding(
      padding: const EdgeInsets.only(
        top: Vingo.ThemeUtil.paddingQuarter,
        bottom: Vingo.ThemeUtil.paddingQuarter,
        left: Vingo.ThemeUtil.padding,
        right: Vingo.ThemeUtil.padding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: Vingo.ThemeUtil.paddingQuarter,
                        right: Vingo.ThemeUtil.paddingQuarter),
                    child: Vingo.Button(
                      text: choices[0],
                      type: (validatedChoices == null
                          ? Vingo.ButtonType.PRIMARY
                          : (validatedChoices[0] == good
                              ? Vingo.ButtonType.EASY // is green
                              : Vingo.ButtonType.AGAIN)),
                      height: 50,
                      onPressed: () {
                        if (validatedChoices != null) {
                          if (validatedChoices[0] == good) {
                            updateSRS(4);
                            return;
                          }
                          if (validatedChoices[0] == again) {
                            updateSRS(2);
                            return;
                          }
                        }
                        // Show Answer is triggered
                        setState(() {
                          showBack = true;
                          currentChoice = choices[0];
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: Vingo.ThemeUtil.paddingQuarter,
                        left: Vingo.ThemeUtil.paddingQuarter),
                    child: Vingo.Button(
                      text: choices[1],
                      type: (validatedChoices == null
                          ? Vingo.ButtonType.PRIMARY
                          : (validatedChoices[1] == good
                              ? Vingo.ButtonType.EASY // is green
                              : Vingo.ButtonType.AGAIN)),
                      height: 50,
                      onPressed: () {
                        if (validatedChoices != null) {
                          if (validatedChoices[1] == good) {
                            updateSRS(4);
                            return;
                          }
                          if (validatedChoices[1] == again) {
                            updateSRS(2);
                            return;
                          }
                        }
                        // Show Answer is triggered
                        setState(() {
                          showBack = true;
                          currentChoice = choices[1];
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: Vingo.ThemeUtil.paddingQuarter,
                        right: Vingo.ThemeUtil.paddingQuarter),
                    child: Vingo.Button(
                      text: choices[2],
                      type: (validatedChoices == null
                          ? Vingo.ButtonType.PRIMARY
                          : (validatedChoices[2] == good
                              ? Vingo.ButtonType.EASY // is green
                              : Vingo.ButtonType.AGAIN)),
                      height: 50,
                      onPressed: () {
                        if (validatedChoices != null) {
                          if (validatedChoices[2] == good) {
                            updateSRS(4);
                            return;
                          }
                          if (validatedChoices[2] == again) {
                            updateSRS(2);
                            return;
                          }
                        }
                        // Show Answer is triggered
                        setState(() {
                          showBack = true;
                          currentChoice = choices[2];
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: Vingo.ThemeUtil.paddingQuarter,
                        left: Vingo.ThemeUtil.paddingQuarter),
                    child: Vingo.Button(
                      text: choices[3],
                      type: (validatedChoices == null
                          ? Vingo.ButtonType.PRIMARY
                          : (validatedChoices[3] == good
                              ? Vingo.ButtonType.EASY // is green
                              : Vingo.ButtonType.AGAIN)),
                      height: 50,
                      onPressed: () {
                        if (validatedChoices != null) {
                          if (validatedChoices[3] == good) {
                            updateSRS(4);
                            return;
                          }
                          if (validatedChoices[3] == again) {
                            updateSRS(2);
                            return;
                          }
                        }
                        // Show Answer is triggered
                        setState(() {
                          showBack = true;
                          currentChoice = choices[3];
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: countCardsWidget,
          ),
        ],
      ),
    );
  }

  Widget progressIndicatorBuilder(BuildContext context) {
    int totalCards = countCards()["total_cards"] ?? 0;

    // Previous value
    double preValue = 0;
    if (progressTotalCount != -1 && progressCurrentCount != -1) {
      preValue = progressCurrentCount / progressTotalCount;
    }

    // Initialize total count one time
    if (progressTotalCount == -1) {
      progressTotalCount = totalCards;
      progressStart = DateTime.now();
    }

    // Calculate current count
    progressCurrentCount = progressTotalCount - totalCards;

    // Prevent progress if something goes wrong
    if (progressTotalCount == -1 || progressCurrentCount == -1) {
      return Container();
    }

    // Calculate current value
    double value = progressCurrentCount / progressTotalCount;

    if (!showBack) {
      if (value > preValue) {
        progressConsecutiveCount += 1;
      } else {
        progressConsecutiveCount = 0;
      }
    }

    return LinearProgressIndicator(
      minHeight: 2.0,
      value: value,
      backgroundColor:
          Vingo.ThemeUtil.of(context).progressIndicatorBackgroundColor,
      valueColor: AlwaysStoppedAnimation<Color>(
        Vingo.ThemeUtil.of(context).progressIndicatorValueColor,
      ),
    );
  }

  Widget cardViewBuilder(BuildContext context) {
    if (currentCard == null || studyFinished) {
      int totalSeconds = (DateTime.now().millisecondsSinceEpoch -
              progressStart.millisecondsSinceEpoch) ~/
          1000;
      int totalMinute = totalSeconds ~/ 60;
      String message = "";
      if (totalMinute == 0) {
        message = Vingo.LocalizationsUtil.of(context)
            .youHaveFinishedYourStudyInLessThanAMinute;
      } else if (totalMinute == 1) {
        message = Vingo.LocalizationsUtil.of(context)
            .youHaveFinishedYourStudyInOneMinute;
      } else {
        message = Vingo.LocalizationsUtil.of(context)
            .youHaveFinishedYourStudyInXMinutes(totalMinute);
      }
      return Container(
        padding: EdgeInsets.all(Vingo.ThemeUtil.padding),
        child: Text(message),
      );
    }

    // Trigger autoplay pronunciation causes double play!!! Because `getCard`
    // might be called multiple times. See the function definition.
    // playAudioNormal();

    // Create widget
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Display current definition
        if (!showBack && definitionsMultipleChoiceEnabled)
          Padding(
            padding: const EdgeInsets.only(
              top: Vingo.ThemeUtil.paddingHalf,
              bottom: Vingo.ThemeUtil.padding,
            ),
            child: Text("TODO"),
            // child: Vingo.CardViewer(
            //   text: _getCurrentCardDefinitionsRightChoice(),
            // ),
          ),
        // Display current translation
        if (!showBack && translationsMultipleChoiceEnabled)
          Padding(
            padding: const EdgeInsets.only(
              top: Vingo.ThemeUtil.paddingHalf,
              bottom: Vingo.ThemeUtil.padding,
            ),
            child: Text("TODO"),
            // child: Vingo.CardViewer(
            //   text: _getCurrentCardTranslationsRightChoice(),
            // ),
          ),
        // Spell check field
        if (widget.deck.spellCheckEnabled && !currentSpellSubmitted)
          Padding(
            padding: const EdgeInsets.only(
              top: Vingo.ThemeUtil.paddingHalf,
              bottom: Vingo.ThemeUtil.padding,
            ),
            child: Vingo.TextFieldExtended(
              controller: currentSpellController,
              fontSize: Vingo.ThemeUtil.textFontSizeLarge,
              autocorrect: false,
              autofocus: true,
              onTap: () {
                playAudioNormal(context: context);
              },
              onFieldSubmitted: (value) {
                showBackOfCard();
              },
            ),
          ),
        // Spell check results
        if (widget.deck.spellCheckEnabled && currentSpellSubmitted)
          Padding(
            padding: const EdgeInsets.only(
              top: Vingo.ThemeUtil.paddingHalf,
              bottom: Vingo.ThemeUtil.padding,
            ),
            child: spellCheckWidget(context),
          ),
        // Display front
        if (!widget.deck.spellCheckEnabled &&
            !(!showBack && definitionsMultipleChoiceEnabled) &&
            !(!showBack && translationsMultipleChoiceEnabled))
          Padding(
            padding: const EdgeInsets.only(
              top: Vingo.ThemeUtil.paddingHalf,
              bottom: Vingo.ThemeUtil.padding,
            ),
            child: GestureDetector(
              onTap: () {
                playAudioNormal(context: context);
              },
              onLongPress: () {
                playAudioSlow(context: context);
              },
              child: Vingo.Markdown(
                text: currentCard!.front,
                hintText: Vingo.LocalizationsUtil.of(context).cardFront,
                editable: false,
                enabled: false,
                padding: EdgeInsets.only(
                  bottom: Vingo.ThemeUtil.padding,
                ),
                onTap: () {},
              ),
              // child: Vingo.CardViewer(
              //   // text: currentCard.front,
              //   text: Vingo.CardViewer.frontCloze(
              //     front: currentCard.front,
              //     back: currentCard.back,
              //   ),
              //   attachment: currentCard.attachment,
              //   sourceLanguage: Vingo.LanguageCodeExt.getEnumFromShortName(
              //       widget.deck.sourceLanguage),
              //   targetLanguage: Vingo.LanguageCodeExt.getEnumFromShortName(
              //       widget.deck.targetLanguage),
              //   currentDeckId: widget.deck.id,
              //   dictionaryDefinitionEnabled:
              //       widget.deck.dictionaryDefinitionEnabled,
              //   dictionarySynonymEnabled: widget.deck.dictionarySynonymEnabled,
              //   dictionaryExampleEnabled: widget.deck.dictionaryExampleEnabled,
              //   dictionaryPhoneticEnabled:
              //       widget.deck.dictionaryPhoneticEnabled,
              //   dictionaryPronunciationEnabled:
              //       widget.deck.dictionaryPronunciationEnabled,
              //   dictionaryImageEnabled: widget.deck.dictionaryImageEnabled,
              //   dictionaryVideoEnabled: widget.deck.dictionaryVideoEnabled,
              //   onWordTap: (String word) {},
              // ),
            ),
          ),
        // Display back
        Visibility(
          visible: showBack,
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: Vingo.ThemeUtil.padding,
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: Vingo.ThemeUtil.padding,
                  ),
                  child: Divider(
                    height: 1.0,
                  ),
                ),
                Vingo.Markdown(
                  text: currentCard!.back,
                  hintText: Vingo.LocalizationsUtil.of(context).cardBack,
                  editable: false,
                  enabled: false,
                  padding: EdgeInsets.only(
                    bottom: Vingo.ThemeUtil.padding,
                  ),
                  onTap: () {},
                ),
              ],
            ),
            // child: Vingo.CardViewer(
            //   // text: currentCard.back,
            //   text: Vingo.CardViewer.backCloze(
            //     front: currentCard.front,
            //     back: currentCard.back,
            //   ),
            //   attachment: currentCard.attachment,
            //   // autoplayAudio: widget.deck.autoplayPronunciationEnabled,
            //   sourceLanguage: Vingo.LanguageCodeExt.getEnumFromShortName(
            //       widget.deck.sourceLanguage),
            //   targetLanguage: Vingo.LanguageCodeExt.getEnumFromShortName(
            //       widget.deck.targetLanguage),
            //   currentDeckId: widget.deck.id,
            //   dictionaryDefinitionEnabled:
            //       widget.deck.dictionaryDefinitionEnabled,
            //   dictionarySynonymEnabled: widget.deck.dictionarySynonymEnabled,
            //   dictionaryExampleEnabled: widget.deck.dictionaryExampleEnabled,
            //   dictionaryPhoneticEnabled: widget.deck.dictionaryPhoneticEnabled,
            //   dictionaryPronunciationEnabled:
            //       widget.deck.dictionaryPronunciationEnabled,
            //   dictionaryImageEnabled: widget.deck.dictionaryImageEnabled,
            //   dictionaryVideoEnabled: widget.deck.dictionaryVideoEnabled,
            //   onWordTap: (String word) {},
            // ),
          ),
        ),
      ],
    );
  }

  Widget controlBuilder(BuildContext context) {
    bool isLtr = Vingo.LocalizationsUtil.isLtr(context);

    // Count cards to prepare stats
    var count = countCards();
    Widget countCardsWidget = Container(
      padding: EdgeInsets.only(
        top: Vingo.ThemeUtil.paddingHalf,
        bottom: Vingo.ThemeUtil.paddingQuarter,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.all(2.0),
            child: Text(
              Vingo.LocalizationsUtil.of(context)
                  .totalX(count['total_cards'])
                  .toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Vingo.ThemeUtil.of(context).statTotalColor,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(2.0),
            child: Text(
              Vingo.LocalizationsUtil.of(context)
                  .newX(count['new_cards'])
                  .toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Vingo.ThemeUtil.of(context).statNewColor,
                decoration: currentCollectionId == 0
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(2.0),
            child: Text(
              Vingo.LocalizationsUtil.of(context)
                  .learningX(count['learning_cards'])
                  .toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Vingo.ThemeUtil.of(context).statLearningColor,
                decoration: currentCollectionId == 1
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(2.0),
            child: Text(
              Vingo.LocalizationsUtil.of(context)
                  .reviewX(count['review_cards'])
                  .toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: Vingo.ThemeUtil.of(context).statReviewColor,
                decoration: currentCollectionId == 2
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        ],
      ),
    );

    if (studyFinished) {
      return Padding(
        padding: const EdgeInsets.only(
          top: Vingo.ThemeUtil.paddingQuarter,
          bottom: Vingo.ThemeUtil.paddingQuarter,
          left: Vingo.ThemeUtil.padding,
          right: Vingo.ThemeUtil.padding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Vingo.Button(
              text: Vingo.LocalizationsUtil.of(context).finished,
              height: Vingo.ThemeUtil.fabButtonHeight,
              type: Vingo.ButtonType.PRIMARY,
              onPressed: () {
                Navigator.of(context).pop(0);
              },
            ),
            Flexible(
              child: countCardsWidget,
            ),
          ],
        ),
      );
    }
    if (!showBack) {
      // Synonyms Multiple-Choice Questions
      if (widget.cardSynonyms != null &&
          widget.cardSynonyms!.containsKey(currentCard) &&
          widget.cardSynonyms!.keys.length >= 4) {
        return multipleChoicesBuilder(
          context,
          countCardsWidget: countCardsWidget,
          choices: prepareCurrentCardSynonymsChoices(),
        );
      }
      // Definitions Multiple-Choice Questions
      else if (widget.cardDefinitions != null &&
          widget.cardDefinitions!.containsKey(currentCard) &&
          widget.cardDefinitions!.keys.length >= 4) {
        return multipleChoicesBuilder(
          context,
          countCardsWidget: countCardsWidget,
          choices: prepareCurrentCardDefinitionsChoices(),
        );
      }
      // Translations Multiple-Choice Questions
      else if (widget.cardTranslations != null &&
          widget.cardTranslations!.containsKey(currentCard) &&
          widget.cardTranslations!.keys.length >= 4) {
        return multipleChoicesBuilder(
          context,
          countCardsWidget: countCardsWidget,
          choices: prepareCurrentCardTranslationsChoices(),
        );
      }
      // Manual Flashcards
      else {
        return Padding(
          padding: const EdgeInsets.only(
            left: Vingo.ThemeUtil.padding,
            right: Vingo.ThemeUtil.padding,
            top: Vingo.ThemeUtil.paddingQuarter,
            bottom: Vingo.ThemeUtil.paddingQuarter,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Vingo.Button(
                text: Vingo.LocalizationsUtil.of(context).showBack,
                height: Vingo.ThemeUtil.fabButtonHeight,
                type: Vingo.ButtonType.PRIMARY,
                onPressed: showBackOfCard,
              ),
              Flexible(
                child: countCardsWidget,
              ),
            ],
          ),
        );
      }
    }

    // Show synonyms multiple choices (showBack is enabled)
    if (widget.cardSynonyms != null &&
        widget.cardSynonyms!.containsKey(currentCard) &&
        widget.cardSynonyms!.keys.length >= 4) {
      return multipleChoicesBuilder(
        context,
        countCardsWidget: countCardsWidget,
        choices: currentCardChoices,
        validatedChoices: validateCurrentCardSynonymsChoices(),
      );
    }

    // Show definitions multiple choice (showBack is enabled)
    if (widget.cardDefinitions != null &&
        widget.cardDefinitions!.containsKey(currentCard) &&
        widget.cardDefinitions!.keys.length >= 4) {
      return multipleChoicesBuilder(
        context,
        countCardsWidget: countCardsWidget,
        choices: currentCardChoices,
        validatedChoices: validateCurrentCardDefinitionsChoices(),
      );
    }

    // Show translations multiple choices (showBack is enabled)
    if (widget.cardTranslations != null &&
        widget.cardTranslations!.containsKey(currentCard) &&
        widget.cardTranslations!.keys.length >= 4) {
      return multipleChoicesBuilder(
        context,
        countCardsWidget: countCardsWidget,
        choices: currentCardChoices,
        validatedChoices: validateCurrentCardTranslationsChoices(),
      );
    }

    // Show again/hard/good/easy (showBack is enabled)
    return Padding(
      padding: const EdgeInsets.only(
        left: Vingo.ThemeUtil.padding,
        right: Vingo.ThemeUtil.padding,
        top: Vingo.ThemeUtil.paddingQuarter,
        bottom: Vingo.ThemeUtil.paddingQuarter,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Vingo.Button(
                  text: Vingo.LocalizationsUtil.of(context).again,
                  height: Vingo.ThemeUtil.fabButtonHeight,
                  borderRadius: BorderRadius.only(
                    topLeft: isLtr
                        ? Radius.circular(Vingo.ThemeUtil.paddingHalf)
                        : Radius.circular(0.0),
                    bottomLeft: isLtr
                        ? Radius.circular(Vingo.ThemeUtil.paddingHalf)
                        : Radius.circular(0.0),
                    topRight: !isLtr
                        ? Radius.circular(Vingo.ThemeUtil.paddingHalf)
                        : Radius.circular(0.0),
                    bottomRight: !isLtr
                        ? Radius.circular(Vingo.ThemeUtil.paddingHalf)
                        : Radius.circular(0.0),
                  ),
                  type: Vingo.ButtonType.AGAIN,
                  onPressed: () {
                    updateSRS(2);
                  },
                ),
              ),
              Expanded(
                child: Vingo.Button(
                  text: Vingo.LocalizationsUtil.of(context).hard,
                  height: Vingo.ThemeUtil.fabButtonHeight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0.0),
                    bottomLeft: Radius.circular(0.0),
                    topRight: Radius.circular(0.0),
                    bottomRight: Radius.circular(0.0),
                  ),
                  type: Vingo.ButtonType.HARD,
                  onPressed: () {
                    updateSRS(3);
                  },
                ),
              ),
              Expanded(
                child: Vingo.Button(
                  text: Vingo.LocalizationsUtil.of(context).good,
                  height: Vingo.ThemeUtil.fabButtonHeight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0.0),
                    bottomLeft: Radius.circular(0.0),
                    topRight: Radius.circular(0.0),
                    bottomRight: Radius.circular(0.0),
                  ),
                  type: Vingo.ButtonType.GOOD,
                  onPressed: () {
                    updateSRS(4);
                  },
                ),
              ),
              Expanded(
                child: Vingo.Button(
                  text: Vingo.LocalizationsUtil.of(context).easy,
                  height: Vingo.ThemeUtil.fabButtonHeight,
                  borderRadius: BorderRadius.only(
                    topLeft: !isLtr
                        ? Radius.circular(Vingo.ThemeUtil.paddingHalf)
                        : Radius.circular(0.0),
                    bottomLeft: !isLtr
                        ? Radius.circular(Vingo.ThemeUtil.paddingHalf)
                        : Radius.circular(0.0),
                    topRight: isLtr
                        ? Radius.circular(Vingo.ThemeUtil.paddingHalf)
                        : Radius.circular(0.0),
                    bottomRight: isLtr
                        ? Radius.circular(Vingo.ThemeUtil.paddingHalf)
                        : Radius.circular(0.0),
                  ),
                  type: Vingo.ButtonType.EASY,
                  onPressed: () {
                    updateSRS(5);
                  },
                ),
              ),
            ],
          ),
          Flexible(
            child: countCardsWidget,
          ),
        ],
      ),
    );
  }

  Widget bodyBuilder(BuildContext context) {
    if (currentCard == null) {
      currentCard = getCard(); // fill currentCard with a card

      // Override spell check when in synonyms multiple-choice questions mode
      synonymsMultipleChoiceEnabled = (widget.cardSynonyms != null &&
          widget.cardSynonyms!.containsKey(currentCard) &&
          widget.cardSynonyms!.keys.length >= 4);
      if (synonymsMultipleChoiceEnabled) {
        widget.deck.spellCheckEnabled = false;
      }

      // Override spell check when in definitions multiple-choice questions mode
      definitionsMultipleChoiceEnabled = (widget.cardDefinitions != null &&
          widget.cardDefinitions!.containsKey(currentCard) &&
          widget.cardDefinitions!.keys.length >= 4);
      if (definitionsMultipleChoiceEnabled) {
        widget.deck.spellCheckEnabled = false;
        widget.deck.autoplayPronunciationEnabled = false;
      }

      // Override spell check when in translation multiple-choice questions mode
      translationsMultipleChoiceEnabled = (widget.cardTranslations != null &&
          widget.cardTranslations!.containsKey(currentCard) &&
          widget.cardTranslations!.keys.length >= 4);
      if (translationsMultipleChoiceEnabled) {
        widget.deck.spellCheckEnabled = false;
        widget.deck.autoplayPronunciationEnabled = false;
      }

      // playAudioNormal(context: context); // Plays audio one time
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        progressIndicatorBuilder(context),
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.stylus,
              },
            ),
            child: SingleChildScrollView(
              // controller: ,
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: Vingo.ThemeUtil.padding,
                right: Vingo.ThemeUtil.padding,
                top: Vingo.ThemeUtil.padding,
                bottom: Vingo.ThemeUtil.padding,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Vingo.ThemeUtil.padding,
                  vertical: Vingo.ThemeUtil.paddingHalf,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cardViewBuilder(context),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          child: controlBuilder(context),
        ),
      ],
    );
  }

  Widget androidBuilder(BuildContext context) {
    return Vingo.Shortcuts(
      autofocus: true,
      onCloseDetected: () {
        Vingo.Messenger.of(context).hide();
      },
      onEditDetected: () {
        editCard(context, currentCard);
      },
      onHelpDetected: () {
        showHelp(context);
      },
      onBackDetected: () {
        Navigator.of(context).pop(false);
      },
      child: Scaffold(
        // backgroundColor: Vingo.ThemeUtil.of(context).formBackgroundColor,
        appBar: AppBar(
          // backgroundColor: Vingo.ThemeUtil.of(context).formBackgroundColor,
          title: Text(
            widget.title,
            style: TextStyle(
              color: Vingo.ThemeUtil.of(context).appBarTitleTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              tooltip: Vingo.LocalizationsUtil.of(context).editCard +
                  " (" +
                  Vingo.Shortcuts.editShortcut +
                  ")",
              onPressed: () {
                editCard(context, currentCard);
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
        body: bodyBuilder(context),
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
