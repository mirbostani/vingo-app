import 'dart:convert' as Convert;

class DateTimeUtil {
  static int getSecondsSinceEpoch() {
    return (new DateTime.now().millisecondsSinceEpoch) ~/ 1000;
  }
}