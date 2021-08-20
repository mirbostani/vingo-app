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

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function>{
        "title": MessageLookupByLibrary.simpleMessage("Vingo"),
        "aboutSoftware": MessageLookupByLibrary.simpleMessage("A study helper application."),
        "developedBy": MessageLookupByLibrary.simpleMessage("Developed by Morteza Mirbostani"),
        "licensedUnder1": MessageLookupByLibrary.simpleMessage("This software is licensed under"),
        "licensedUnder2": MessageLookupByLibrary.simpleMessage("GNU GPL v3.0"),
        "licensedUnder3": MessageLookupByLibrary.simpleMessage("."),
        "sourceCodeAvail1": MessageLookupByLibrary.simpleMessage("Source code is available on"),
        "sourceCodeAvail2": MessageLookupByLibrary.simpleMessage("GitHub"),
        "sourceCodeAvail3": MessageLookupByLibrary.simpleMessage("."),
        "areYouSure": MessageLookupByLibrary.simpleMessage("Are you sure?"),
        "areYouSureYouWantToDeleteX": areYouSureYouWantToDeleteX,
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
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "fontSize": MessageLookupByLibrary.simpleMessage("Font Size"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
      };
}