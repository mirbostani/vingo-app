import 'dart:convert' as Convert;

class StringUtil {
  static String htmlEscape(String s) {
    return Convert.htmlEscape.convert(s).trim();
  }

  static String addEllipsis({
    required String text,
    int limit = 32,
  }) {
    return text.length > limit ? text.substring(0, limit - 3) + "..." : text;
  }

  static String escapeSql(String str) {
    str = str.replaceAll(RegExp(r"'"), r"''");
    str = str.replaceAll(RegExp(r"%"), r"");
    return str;
  }

  static String digitsToLatin(String digits) {
    var sb = new StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      switch (digits[i]) {
        //Persian digits
        case '\u06f0':
          sb.write('0');
          break;
        case '\u06f1':
          sb.write('1');
          break;
        case '\u06f2':
          sb.write('2');
          break;
        case '\u06f3':
          sb.write('3');
          break;
        case '\u06f4':
          sb.write('4');
          break;
        case '\u06f5':
          sb.write('5');
          break;
        case '\u06f6':
          sb.write('6');
          break;
        case '\u06f7':
          sb.write('7');
          break;
        case '\u06f8':
          sb.write('8');
          break;
        case '\u06f9':
          sb.write('9');
          break;

        //Arabic digits
        case '\u0660':
          sb.write('0');
          break;
        case '\u0661':
          sb.write('1');
          break;
        case '\u0662':
          sb.write('2');
          break;
        case '\u0663':
          sb.write('3');
          break;
        case '\u0664':
          sb.write('4');
          break;
        case '\u0665':
          sb.write('5');
          break;
        case '\u0666':
          sb.write('6');
          break;
        case '\u0667':
          sb.write('7');
          break;
        case '\u0668':
          sb.write('8');
          break;
        case '\u0669':
          sb.write('9');
          break;
        default:
          sb.write(digits[i]);
          break;
      }
    }
    return sb.toString();
  }
}
