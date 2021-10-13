import 'dart:io';
import 'dart:ui' as Ui;
import 'dart:async' as Async;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vingo/util/util.dart' as Vingo;
import 'package:vingo/widget/widget.dart' as Vingo;

class Markdown extends StatefulWidget {
  final MarkdownEditingController controller;
  final String? hintText;
  final bool? enabled;
  final EdgeInsets? padding;

  const Markdown({
    Key? key,
    required this.controller,
    this.hintText,
    this.enabled = true,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  _MarkdownState createState() => _MarkdownState();
}

class _MarkdownState extends State<Markdown> {
  Offset cursorOffset = Offset(0, 0);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(onTextChanged);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onTextChanged() {
    widget.controller.offsets.forEach((key, value) {});
    // Offset computedOffset = computeCursorOffset();
    // print(computedOffset);
    // print(widget.controller.text);
    // if (cursorOffset != computedOffset) {
    //   setState(() {
    //     cursorOffset = computedOffset;
    //   });
    // }
  }

  // Offset computeCursorOffset() {
  //   double dx = 0.0;
  //   widget.controller.offsets.values.forEach((value) {
  //     dx += value * 7;
  //   });
  //   return Offset(dx, 0.0);
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Vingo.Text(
            // EditableText(
            //   style: TextStyle(
            //     // color: Colors.black,
            //   ),
            //   backgroundCursorColor: Colors.red,
            //   cursorColor: Colors.blue,
            //   focusNode: FocusNode(),
            //   cursorOffset: cursorOffset,

            obscureText: false,
            readOnly: false,
            enabled: widget.enabled,
            hintText: widget.hintText,
            controller: widget.controller,
            autofocus: true,
            autocorrect: false,
            enableInteractiveSelection: true,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onEditingComplete: () {},
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
  bool plainTextEnabled = false;
  static const String inv = "\u200d"; // int 0x200d; or "\u200b" invisible char
  late Map<int, int> offsets = <int, int>{};

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

    if (plainTextEnabled) {
      return TextSpan(
        text: this.text,
        style: TextStyle(
          fontFamily: Vingo.ThemeUtil.codeFont,
        ),
      );
    }

    offsets = {};

    List<InlineSpan> spans = run(
      context: context,
      functions: <Function>[
        blockCode,
        blockImage,
        inlineLink,
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
      pattern: RegExp(r"\*\*\*([^\*\n]+?)\*\*\*"),
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
      pattern: RegExp(r"\*\*([^\*\n]+?)\*\*"),
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
      pattern: RegExp(r"\*([^\*\n]+?)\*"),
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
      pattern: RegExp(r"`([^`\n]+?)`"),
      matchProcess: (match, style) {
        return TextSpan(
          children: [
            TextSpan(text: "$inv"),
            TextSpan(
              text: match.group(1),
              style: style!.merge(
                TextStyle(
                  backgroundColor: Colors.grey.withAlpha(100),
                  fontFamily: Vingo.ThemeUtil.codeFont,
                ),
              ),
            ),
            TextSpan(text: "$inv"),
          ],
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
      pattern: RegExp(r"\*\*\*`([^`\n]+?)`\*\*\*"),
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
      pattern: RegExp(r"\*\*`([^`\n]+?)`\*\*"),
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
      pattern: RegExp(r"\*`([^`\n]+?)`\*"),
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

  List<InlineSpan> inlineLink({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return inline(
      context: context,
      pattern: RegExp(r"\[([^\[\]]*?)\]\(([^\(\)]*?)\)"),
      matchProcess: (match, style) {
        return TextSpan(
          text: match.group(1) ?? "link",
          style: style!.merge(
            TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
          recognizer: new TapGestureRecognizer()
            ..onTap = () {
              String url = match.group(2) ?? "";
              Vingo.PlatformUtil.launchUrl(url);
            },
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

  List<InlineSpan> blockCode({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return block(
      context: context,
      pattern: RegExp(r"```([^`]*?)\n([^`]+?)\n```"),
      matchProcess: (match, style) {
        InlineSpan span = TextSpan(
          text: List.generate(match.group(0)!.length, (index) => inv).join(),
          // semanticsLabel: "SEMANTIC",
          children: [
            WidgetSpan(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(120),
                        borderRadius: BorderRadius.only(
                          topLeft:
                              Radius.circular(Vingo.ThemeUtil.borderRadius),
                          topRight:
                              Radius.circular(Vingo.ThemeUtil.borderRadius),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: Vingo.ThemeUtil.paddingQuarter,
                        bottom: Vingo.ThemeUtil.paddingQuarter,
                        left: Vingo.ThemeUtil.padding,
                        right: Vingo.ThemeUtil.padding,
                      ),
                      child: Text(match.group(1) ?? "",
                          style: TextStyle(
                            fontSize: Vingo.ThemeUtil.textFontSizeSmall,
                            color: Colors.white,
                          )),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(50),
                        borderRadius: BorderRadius.only(
                          bottomLeft:
                              Radius.circular(Vingo.ThemeUtil.borderRadius),
                          bottomRight:
                              Radius.circular(Vingo.ThemeUtil.borderRadius),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: Vingo.ThemeUtil.padding,
                        bottom: Vingo.ThemeUtil.padding,
                        left: Vingo.ThemeUtil.padding,
                        right: Vingo.ThemeUtil.padding,
                      ),
                      child: Text(
                        match.group(2) ?? "",
                        style: TextStyle(
                          fontFamily: Vingo.ThemeUtil.codeFont,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          style: style!.merge(
            TextStyle(
              fontFamily: Vingo.ThemeUtil.codeFont,
            ),
          ),
        );


        // Future.delayed(Duration.zero, () async {
        //   if (value.text.length == 39) {
        //     this.text += "x";
        //   }
        // });

        if (match.group(0) != null) {
          offsets[match.start] = 1;
        }

        return span;
      },
      text: text,
      style: style,
      process: process,
    );
  }

  List<InlineSpan> blockImage({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return block(
      context: context,
      pattern: RegExp(r"!\[([^\[\]]*?)\]\(([^\(\)]*?)\)"),
      matchProcess: (match, style) {
        InlineSpan span = TextSpan(
          text: List.generate(match.group(0)!.length, (index) => inv)
              .toList()
              .join(),
          children: [
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
