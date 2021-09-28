import 'dart:ui' as Ui;
import 'dart:async' as Async;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vingo/util/util.dart' as Vingo;
import 'package:vingo/widget/widget.dart' as Vingo;

class Markdown extends StatefulWidget {
  final MarkdownEditingController controller;
  final String? hintText;
  final EdgeInsets? padding;

  const Markdown({
    Key? key,
    required this.controller,
    this.hintText,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  _MarkdownState createState() => _MarkdownState();
}

class _MarkdownState extends State<Markdown> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onTextChanged() {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Vingo.Text(
            hintText: widget.hintText,
            controller: widget.controller,
            autofocus: true,
            autocorrect: false,
            enableInteractiveSelection: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
          )
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

typedef ProcessCallback = List<InlineSpan>? Function(
    String text, TextStyle? style);

typedef MatchProcessCallback = InlineSpan Function(
    RegExpMatch match, TextStyle? style);

class MarkdownEditingController extends TextEditingController {
  static const String inv = "\u200b";

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // assert(!value.composing.isValid ||
    //     !withComposing ||
    //     value.isComposingRangeValid);

    // if (!value.isComposingRangeValid || !withComposing) {
    //   return TextSpan(style: style, text: text);
    // }

    List<InlineSpan> spans = run(
      context: context,
      functions: <Function>[
        blockImage,
        inlineBoldItalicCode,
        inlineBoldItalic,
        inlineBoldCode,
        inlineItalicCode,
        inlineCode,
        inlineBold,
        inlineItalic,
      ],
      index: 0,
      text: text,
      style: style,
    );

    return TextSpan(
      children: spans,
    );
  }

  /// Recursive execution of all inline functions
  ///
  /// ```dart
  /// List<InlineSpan> spans = inlineBoldCode(
  ///   text: text,
  ///   style: style,
  ///   process: (text, style) {
  ///     return inlineCode(
  ///       text: text,
  ///       style: style,
  ///       process: (text, style) {
  ///         return inlineBold(
  ///           text: text,
  ///           style: style,
  ///           process: (text, style) {
  ///             return <InlineSpan>[TextSpan(text: text, style: style)];
  ///           },
  ///         );
  ///       },
  ///     );
  ///   },
  /// );
  /// ```
  List<InlineSpan> run({
    required BuildContext context,
    required List<Function> functions,
    required int index,
    required String text,
    TextStyle? style,
  }) {
    return functions[index](
      context: context,
      text: text,
      style: style,
      process: (text, style) {
        if (index >= functions.length - 1) {
          return <InlineSpan>[TextSpan(text: text, style: style)];
        }
        return run(
          context: context,
          functions: functions,
          index: index + 1,
          text: text,
          style: style,
        );
      },
    );
  }

  //----------------------------------------------------------------------------

  List<InlineSpan> inlineBoldItalic({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return inline(
      context: context,
      pattern: RegExp(r"\*\*\*([^\*]+?)\*\*\*"),
      matchProcess: (match, style) {
        return TextSpan(
          text: "$inv$inv$inv${match.group(1)}$inv$inv$inv",
          style: style!.merge(TextStyle(
            fontStyle: Ui.FontStyle.italic,
            fontWeight: Ui.FontWeight.bold,
          )),
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  List<InlineSpan> inlineBold({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return inline(
      context: context,
      pattern: RegExp(r"\*\*([^\*]+?)\*\*"),
      matchProcess: (match, style) {
        return TextSpan(
          text: "$inv$inv${match.group(1)}$inv$inv",
          style: style!.merge(TextStyle(
            fontWeight: Ui.FontWeight.bold,
          )),
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  List<InlineSpan> inlineItalic({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return inline(
      context: context,
      pattern: RegExp(r"\*([^\*]+?)\*"),
      matchProcess: (match, style) {
        return TextSpan(
          text: "$inv${match.group(1)}$inv",
          style: style!.merge(TextStyle(
            fontStyle: Ui.FontStyle.italic,
          )),
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  List<InlineSpan> inlineCode({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return inline(
      context: context,
      pattern: RegExp(r"`([^`]+?)`"),
      matchProcess: (match, style) {
        return TextSpan(
          text: "$inv${match.group(1)}$inv",
          style: style!.merge(TextStyle(
            backgroundColor: Colors.grey.withAlpha(100),
            fontFamily: Vingo.ThemeUtil.codeFont,
          )),
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  List<InlineSpan> inlineBoldItalicCode({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return inline(
      context: context,
      pattern: RegExp(r"\*\*\*`([^`]+?)`\*\*\*"),
      matchProcess: (match, style) {
        return TextSpan(
          text: "$inv$inv$inv$inv${match.group(1)}$inv$inv$inv$inv",
          style: style!.merge(TextStyle(
            backgroundColor: Colors.grey.withAlpha(100),
            fontFamily: Vingo.ThemeUtil.codeFont,
            fontStyle: Ui.FontStyle.italic,
            fontWeight: Ui.FontWeight.bold,
          )),
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  List<InlineSpan> inlineBoldCode({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return inline(
      context: context,
      pattern: RegExp(r"\*\*`([^`]+?)`\*\*"),
      matchProcess: (match, style) {
        return TextSpan(
          text: "$inv$inv$inv${match.group(1)}$inv$inv$inv",
          style: style!.merge(TextStyle(
            backgroundColor: Colors.grey.withAlpha(100),
            fontFamily: Vingo.ThemeUtil.codeFont,
            fontWeight: Ui.FontWeight.bold,
          )),
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  List<InlineSpan> inlineItalicCode({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return inline(
      context: context,
      pattern: RegExp(r"\*`([^`]+?)`\*"),
      matchProcess: (match, style) {
        return TextSpan(
          text: "$inv$inv${match.group(1)}$inv$inv",
          style: style!.merge(TextStyle(
            backgroundColor: Colors.grey.withAlpha(100),
            fontFamily: Vingo.ThemeUtil.codeFont,
            fontStyle: Ui.FontStyle.italic,
          )),
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  List<InlineSpan> inline({
    required BuildContext context,
    required RegExp pattern,
    required MatchProcessCallback matchProcess,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    List<InlineSpan> spans = <InlineSpan>[];
    Iterable<RegExpMatch> matches = pattern.allMatches(text);

    // No matches
    if (matches.length == 0) {
      if (process != null) {
        spans = process(text, style)!;
      } else {
        spans.add(TextSpan(text: text, style: style));
      }
      return spans;
    }

    int position = 0;
    matches.forEach((match) {
      // Before text
      String before = text.substring(position, match.start);
      if (process != null) {
        spans.add(TextSpan(children: process(before, style), style: style));
      } else {
        spans.add(TextSpan(text: before, style: style));
      }

      // Inside text
      spans.add(matchProcess(match, style));

      // Reset starting positiong
      position = match.end;
    });

    // After text
    String after = text.substring(position);
    if (process != null) {
      spans.add(TextSpan(children: process(after, style), style: style));
    } else {
      spans.add(TextSpan(text: after, style: style));
    }

    return spans;
  }

  //----------------------------------------------------------------------------

  List<InlineSpan> blockImage({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return block(
      context: context,
      pattern: RegExp(r"\[([^\[\]]*?)\]\(([^\(\)]*?)\)"),
      matchProcess: (match, style) {
        InlineSpan span = TextSpan(
          children: [
            TextSpan(
              text: List.generate(match.group(0)!.length, (index) => inv)
                  .toList()
                  .join(),
            ),
            WidgetSpan(
              child: Vingo.ImageExtended(
                url: match.group(2) ?? "",
                isBlock: true,
                padding: EdgeInsets.only(
                  top: Vingo.ThemeUtil.padding,
                  bottom: Vingo.ThemeUtil.padding,
                ),
              ),
            ),
            WidgetSpan(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: Vingo.ThemeUtil.padding,
                  ),
                  child: Text(
                    match.group(1) ?? "",
                    style: TextStyle(
                      color: Vingo.ThemeUtil.of(context).textMutedColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
          style: style,
        );

        // print(this.selection);
        // print(this.text.length);

        // Future.delayed(Duration.zero, () async {
        //   if (value.selection.isValid && value.selection.isCollapsed) {
        //     value = value.copyWith(
        //       selection: TextSelection(
        //         baseOffset: match.end + 2,
        //         extentOffset: match.end + 2,
        //       ),
        //       text: this.text + "YYY",
        //     );
        //   }
        // });

        return span;
      },
      text: text,
      style: style,
      process: process,
    );
  }

  List<InlineSpan> block({
    required BuildContext context,
    required RegExp pattern,
    required MatchProcessCallback matchProcess,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    List<InlineSpan> spans = <InlineSpan>[];
    Iterable<RegExpMatch> matches = pattern.allMatches(text);

    // No matches
    if (matches.length == 0) {
      if (process != null) {
        spans = process(text, style)!;
      } else {
        spans.add(TextSpan(text: text, style: style));
      }
      return spans;
    }

    int position = 0;
    matches.forEach((match) {
      // Before text
      String before = text.substring(position, match.start);
      if (process != null) {
        spans.add(TextSpan(children: process(before, style), style: style));
      } else {
        spans.add(TextSpan(text: before, style: style));
      }

      // Inside text
      spans.add(matchProcess(match, style));

      // Reset starting positiong
      position = match.end;
    });

    // After text
    String after = text.substring(position);
    if (process != null) {
      spans.add(TextSpan(children: process(after, style), style: style));
    } else {
      spans.add(TextSpan(text: after, style: style));
    }

    return spans;
  }
}
