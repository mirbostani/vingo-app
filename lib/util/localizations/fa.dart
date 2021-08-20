// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fa locale. All the
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
  String get localeName => 'fa';

  static areYouSureYouWantToDeleteX(x) =>
      "آیا مطمئن هستید که میخواهید ${x} را حذف کنید؟";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function>{
        "title": MessageLookupByLibrary.simpleMessage("وینگو"),
        "aboutSoftware": MessageLookupByLibrary.simpleMessage("یک نرم افزار دستیار مطالعه."),
        "developedBy": MessageLookupByLibrary.simpleMessage("توسعه یافته توسط مرتضی میربستانی"),
        "licensedUnder1": MessageLookupByLibrary.simpleMessage("این نرم افزار تحت مجوز"),
        "licensedUnder2": MessageLookupByLibrary.simpleMessage("GNU GPL v3.0"),
        "licensedUnder3": MessageLookupByLibrary.simpleMessage("منتشر شده است."),
        "sourceCodeAvail1": MessageLookupByLibrary.simpleMessage("کد منبع در"),
        "sourceCodeAvail2": MessageLookupByLibrary.simpleMessage("GitHub"),
        "sourceCodeAvail3": MessageLookupByLibrary.simpleMessage("موجود است."),
        "areYouSure":
            MessageLookupByLibrary.simpleMessage("آیا اطمینان دارید؟"),
        "areYouSureYouWantToDeleteX": areYouSureYouWantToDeleteX,
        "systemDefault": MessageLookupByLibrary.simpleMessage("پیش فرض سیستم"),
        "dark": MessageLookupByLibrary.simpleMessage("تاریک"),
        "light": MessageLookupByLibrary.simpleMessage("روشن"),
        "english": MessageLookupByLibrary.simpleMessage("English"),
        "persian": MessageLookupByLibrary.simpleMessage("فارسی"),
        "small": MessageLookupByLibrary.simpleMessage("کوچک"),
        "medium": MessageLookupByLibrary.simpleMessage("متوسط"),
        "large": MessageLookupByLibrary.simpleMessage("بزرگ"),
        "ok": MessageLookupByLibrary.simpleMessage("تایید"),
        "cancel": MessageLookupByLibrary.simpleMessage("لغو"),
        "language": MessageLookupByLibrary.simpleMessage("زبان"),
        "theme": MessageLookupByLibrary.simpleMessage("پوسته"),
        "fontSize": MessageLookupByLibrary.simpleMessage("اندازه خط"),
        "home": MessageLookupByLibrary.simpleMessage("خانه"),
        "settings": MessageLookupByLibrary.simpleMessage("تنظیمات"),
      };
}