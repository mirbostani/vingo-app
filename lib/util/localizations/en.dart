// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static areYouSureYouWantToDeleteX(x) =>
      "Are you sure you want to delete \"${x}\"?";
  static pressXToCreateANewDeck(x) => "Press ${x} to create a new deck.";
  static pressXToCreateANewCard(x) => "Press ${x} to create a new card.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function>{
        "title": MessageLookupByLibrary.simpleMessage("Vingo"),
        "aboutSoftware":
            MessageLookupByLibrary.simpleMessage("A study helper application."),
        "developedBy": MessageLookupByLibrary.simpleMessage(
            "Developed by Morteza Mirbostani"),
        "licensedUnder1": MessageLookupByLibrary.simpleMessage(
            "This software is licensed under"),
        "licensedUnder2": MessageLookupByLibrary.simpleMessage("GNU GPL v3.0"),
        "licensedUnder3": MessageLookupByLibrary.simpleMessage("."),
        "sourceCodeAvail1":
            MessageLookupByLibrary.simpleMessage("Source code is available on"),
        "sourceCodeAvail2": MessageLookupByLibrary.simpleMessage("GitHub"),
        "sourceCodeAvail3": MessageLookupByLibrary.simpleMessage("."),
        "systemDefault": MessageLookupByLibrary.simpleMessage("System default"),
        "dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "light": MessageLookupByLibrary.simpleMessage("Light"),
        "english": MessageLookupByLibrary.simpleMessage("English"),
        "persian": MessageLookupByLibrary.simpleMessage("فارسی"),
        "small": MessageLookupByLibrary.simpleMessage("Small"),
        "medium": MessageLookupByLibrary.simpleMessage("Medium"),
        "large": MessageLookupByLibrary.simpleMessage("Large"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "study": MessageLookupByLibrary.simpleMessage("Study"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "saved": MessageLookupByLibrary.simpleMessage("Saved"),
        "create": MessageLookupByLibrary.simpleMessage("Create"),
        "rename": MessageLookupByLibrary.simpleMessage("Rename"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "fontSize": MessageLookupByLibrary.simpleMessage("Font Size"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "help": MessageLookupByLibrary.simpleMessage("Help"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "more": MessageLookupByLibrary.simpleMessage("More"),
        "back": MessageLookupByLibrary.simpleMessage("Back"),
        "search": MessageLookupByLibrary.simpleMessage("Search"),
        "paste": MessageLookupByLibrary.simpleMessage("Paste"),
        "deck": MessageLookupByLibrary.simpleMessage("Deck"),
        "decks": MessageLookupByLibrary.simpleMessage("Decks"),
        "deckName": MessageLookupByLibrary.simpleMessage("Deck Name"),
        "card": MessageLookupByLibrary.simpleMessage("Card"),
        "cardFront": MessageLookupByLibrary.simpleMessage("Front"),
        "cardBack": MessageLookupByLibrary.simpleMessage("Back"),
        "createCard": MessageLookupByLibrary.simpleMessage("Create Card"),
        "viewCard": MessageLookupByLibrary.simpleMessage("View Card"),
        "editCard": MessageLookupByLibrary.simpleMessage("Edit Card"),
        "cards": MessageLookupByLibrary.simpleMessage("cards"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "createANewDeck":
            MessageLookupByLibrary.simpleMessage("Create a new deck"),
        "createANewCard":
            MessageLookupByLibrary.simpleMessage("Create a new card"),
        "areYouSure": MessageLookupByLibrary.simpleMessage("Are you sure?"),
        "areYouSureYouWantToDeleteX": areYouSureYouWantToDeleteX,
        "pressXToCreateANewDeck": pressXToCreateANewDeck,
        "pressXToCreateANewCard": pressXToCreateANewCard,

        // Shortcuts
        "helpShortcut": MessageLookupByLibrary.simpleMessage("F1"),
        "closeShortcut": MessageLookupByLibrary.simpleMessage("Esc"),
        "backShortcut": MessageLookupByLibrary.simpleMessage("Ctrl + Esc"),
        "createANewDeckShortcut":
            MessageLookupByLibrary.simpleMessage("Ctrl + N"),
        "createANewCardShortcut":
            MessageLookupByLibrary.simpleMessage("Ctrl + N"),
        "searchShortcut": MessageLookupByLibrary.simpleMessage("Ctrl + F"),
        "studyShortcut": MessageLookupByLibrary.simpleMessage("Ctrl + L"),
        "saveShortcut": MessageLookupByLibrary.simpleMessage("Ctrl + S"),
      };
}
