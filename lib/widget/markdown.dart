import 'dart:io';
import 'dart:ui' as Ui;
import 'dart:async' as Async;
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:katex_flutter/katex_flutter.dart' as Tex;
import 'package:vingo/util/util.dart' as Vingo;
import 'package:vingo/widget/widget.dart' as Vingo;

class Markdown extends StatefulWidget {
  final String? text;
  final MarkdownEditingController? controller;
  final String? hintText;
  final bool? editable;
  final bool? enabled;
  final EdgeInsets? padding;
  final Ui.VoidCallback? onTap;

  const Markdown({
    Key? key,
    this.text,
    this.controller,
    this.hintText,
    this.editable = true,
    this.enabled = true,
    this.padding = EdgeInsets.zero,
    this.onTap,
  }) : super(key: key);

  @override
  _MarkdownState createState() => _MarkdownState();
}

class _MarkdownState extends State<Markdown> {
  Offset cursorOffset = Offset(0, 0);
  late MarkdownEditingController controller;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      controller = widget.controller!;
    } else {
      controller = MarkdownEditingController();
    }
    if (widget.text != null) {
      controller.text = widget.text!;
    }
    controller.addListener(onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  void onTextChanged() {
    controller.offsets.forEach((key, value) {});
    // Offset computedOffset = computeCursorOffset();
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
          if (widget.editable != true)
            Text.rich(
              MarkdownEditingController.toTextSpan(
                context: context,
                text: widget.text!,
                style: TextStyle(),
                withPlainText: false,
              ),
            ),
          if (widget.editable == true)
            Vingo.TextFieldExtended(
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
              controller: controller,
              autofocus: true,
              autocorrect: false,
              enableInteractiveSelection: true,
              enableWordsCounter: true,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onEditingComplete: () {},
              onTap: widget.onTap,
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
  static const String inv = "\ufeff"; // 0x200d, 0x200b, 0xfeff
  static const String bullet = "\u2022";
  static const String rightArrow = "\u279c";
  static const String box = "\u2610";
  static const String boxChecked = "\u2612";
  static const String tab = "    ";
  late Map<int, int> offsets = <int, int>{};

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // offsets = {};
    return toTextSpan(
      context: context,
      text: this.text,
      style: style,
      withPlainText: plainTextEnabled,
    );
  }

  static TextSpan toTextSpan({
    required BuildContext context,
    required String text,
    TextStyle? style,
    required bool withPlainText,
  }) {
    if (withPlainText) {
      return TextSpan(
        text: text,
        style: style?.merge(
          TextStyle(
            fontFamily: Vingo.ThemeUtil.codeFont,
          ),
        ),
      );
    }

    List<InlineSpan> spans = run(
      context: context,
      functions: <Function>[
        blockCode,
        blockTex,
        blockImage,
        blockHeading,
        blockList,
        inlineLink,
        inlineBoldItalicCode,
        inlineBoldItalic,
        inlineBoldCode,
        inlineItalicCode,
        inlineCode,
        inlineTex,
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
  static List<InlineSpan> run({
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
      process: (text, innerStyle) {
        if (index >= functions.length - 1) {
          return <InlineSpan>[
            TextSpan(
              text: text,
              style: innerStyle, //?.merge(style),
            )
          ];
        }
        return run(
          context: context,
          functions: functions,
          index: index + 1,
          text: text,
          style: innerStyle, //?.merge(style),
        );
      },
    );
  }

  //----------------------------------------------------------------------------

  static List<InlineSpan> inlineBoldItalic({
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
          style: style?.merge(
            TextStyle(
              fontStyle: Ui.FontStyle.italic,
              fontWeight: Ui.FontWeight.bold,
            ),
          ),
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  static List<InlineSpan> inlineBold({
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
          style: style?.merge(
            TextStyle(
              fontWeight: Ui.FontWeight.bold,
            ),
          ),
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  static List<InlineSpan> inlineItalic({
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
          style: style?.merge(
            TextStyle(
              fontStyle: Ui.FontStyle.italic,
            ),
          ),
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  static List<InlineSpan> inlineTex({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return inline(
      context: context,
      pattern: RegExp(r"\$([^\$\n]*?)\$"),
      matchProcess: (match, style) {
        return TextSpan(
          children: [
            WidgetSpan(
              child: Tex.KaTeX(
                laTeXCode: Text("\$${match.group(1)!}\$"),
                delimiter: r"$",
                displayDelimiter: r"$$",
              ),
              alignment: Ui.PlaceholderAlignment.middle,
            ),
          ],
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  static List<InlineSpan> inlineCode({
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
              style: style?.merge(
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

  static List<InlineSpan> inlineBoldItalicCode({
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
          style: style?.merge(
            TextStyle(
              backgroundColor: Colors.grey.withAlpha(100),
              fontFamily: Vingo.ThemeUtil.codeFont,
              fontStyle: Ui.FontStyle.italic,
              fontWeight: Ui.FontWeight.bold,
            ),
          ),
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  static List<InlineSpan> inlineBoldCode({
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
          style: style?.merge(
            TextStyle(
              backgroundColor: Colors.grey.withAlpha(100),
              fontFamily: Vingo.ThemeUtil.codeFont,
              fontWeight: Ui.FontWeight.bold,
            ),
          ),
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  static List<InlineSpan> inlineItalicCode({
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
          style: style?.merge(
            TextStyle(
              backgroundColor: Colors.grey.withAlpha(100),
              fontFamily: Vingo.ThemeUtil.codeFont,
              fontStyle: Ui.FontStyle.italic,
            ),
          ),
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  static List<InlineSpan> inlineLink({
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
          style: style?.merge(
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

  static List<InlineSpan> inline({
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

  static List<InlineSpan> blockTex({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return block(
      context: context,
      pattern: RegExp(
        r"(^|\r\n|\r|\n)\$\$(\r\n|\r|\n)([^\$]*?)(\r\n|\r|\n)\$\$($|\r\n|\r|\n)",
        multiLine: true,
      ),
      matchProcess: (match, style) {
        return TextSpan(children: [
          // TextSpan(text: match.group(1)!),
          WidgetSpan(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Tex.KaTeX(
                laTeXCode: Text("\$\$${match.group(3)!}\$\$"),
                delimiter: r"$",
                displayDelimiter: r"$$",
              ),
            ),
          ),
        ]);
      },
      text: text,
      style: style,
      process: process,
    );
  }

  static List<InlineSpan> blockCode({
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
          // text: List.generate(match.group(0)!.length, (index) => inv).join(),
          // semanticsLabel: "code",
          children: [
            WidgetSpan(
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Language
                    Container(
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        // color: Vingo.ThemeUtil.of(context).buttonPrimaryColor,
                        color: Vingo.ThemeUtil.of(context)
                            .buttonPrimaryBoxShadowColor,
                        borderRadius: BorderRadius.only(
                          topLeft:
                              Radius.circular(Vingo.ThemeUtil.borderRadiusHalf),
                          topRight:
                              Radius.circular(Vingo.ThemeUtil.borderRadiusHalf),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        top: Vingo.ThemeUtil.paddingQuarter,
                        // bottom: Vingo.ThemeUtil.paddingQuarter,
                        left: Vingo.ThemeUtil.paddingQuarter,
                        right: Vingo.ThemeUtil.paddingQuarter,
                      ),
                      child: Text(
                        match.group(1) ?? "",
                        style: TextStyle(
                            fontSize: Vingo.ThemeUtil.textFontSizeSmall,
                            color: Vingo.ThemeUtil.of(context)
                                .buttonPrimaryColor
                                .withAlpha(150),
                            fontFamily: Vingo.ThemeUtil.codeFont),
                      ),
                    ),
                    // Code
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        // color: Colors.black.withAlpha(20),
                        color: Vingo.ThemeUtil.of(context)
                            .buttonPrimaryBoxShadowColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft:
                              Radius.circular(Vingo.ThemeUtil.borderRadiusHalf),
                          bottomRight:
                              Radius.circular(Vingo.ThemeUtil.borderRadiusHalf),
                        ),
                      ),
                      padding: EdgeInsets.only(
                        // top: Vingo.ThemeUtil.padding,
                        bottom: Vingo.ThemeUtil.padding,
                        left: Vingo.ThemeUtil.padding,
                        right: Vingo.ThemeUtil.padding,
                      ),
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.stylus,
                          },
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Text(
                            // SelectableText(
                            match.group(2) ?? "",
                            style: TextStyle(
                              fontFamily: Vingo.ThemeUtil.codeFont,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          style: style?.merge(
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

        // if (match.group(0) != null) {
        //   offsets[match.start] = 1;
        // }

        return span;
      },
      text: text,
      style: style,
      process: process,
    );
  }

  static List<InlineSpan> blockImage({
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

  static List<InlineSpan> blockHeading({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return block(
      context: context,
      pattern: RegExp(
        r"(^|\r\n|\r|\n)(#{1,6}) (.*?)($|\r\n|\r|\n)",
        multiLine: true,
      ),
      matchProcess: (match, style) {
        int heading = match.group(2)!.length - 1;
        heading = heading > 5 ? 5 : (heading < 0 ? 0 : heading);
        return TextSpan(
          children: [
            TextSpan(
              text: match.group(1),
            ),
            TextSpan(
              text:
                  List.generate(match.group(2)!.length + 1, (i) => inv).join(),
            ),
            TextSpan(
              children: run(
                context: context,
                functions: <Function>[
                  inlineLink,
                  inlineBoldItalicCode,
                  inlineBoldItalic,
                  inlineBoldCode,
                  inlineItalicCode,
                  inlineCode,
                  inlineTex,
                  inlineBold,
                  inlineItalic,
                ],
                index: 0,
                text: match.group(3)!,
                style: style?.merge(
                  TextStyle(
                    color: Vingo.ThemeUtil.of(context).buttonPrimaryColor,
                    fontSize: Vingo.ThemeUtil.headingFontSize[heading],
                    fontWeight: Ui.FontWeight.bold,
                  ),
                ),
              ),
            ),
            TextSpan(
              text: match.group(4)!,
            ),
          ],
          style: style,
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  static List<InlineSpan> blockList({
    required BuildContext context,
    required String text,
    TextStyle? style,
    ProcessCallback? process,
  }) {
    return block(
      context: context,
      pattern: RegExp(
          r"(^|\r\n|\r|\n)([ \t]*)(-|\d+\.)\s(\[ \]\s|\[[xX]\]\s){0,1}(.*?)"),
      matchProcess: (match, style) {
        // int length = match.group(2)!.length;
        bool todo = match.group(4) != null;
        bool checked = todo ? match.group(4)!.contains(RegExp(r'[xX]')) : false;
        bool ordered = !match.group(3)!.contains("-");
        return TextSpan(
          children: [
            TextSpan(
              text: match.group(1)!,
            ),
            TextSpan(
              // text: List.generate(length, (i) => tab).toList().join(),
              text: match.group(2)!,
            ),
            if (!todo && !ordered)
              TextSpan(
                text: "$rightArrow ",
                style: TextStyle(
                  color: Vingo.ThemeUtil.of(context).buttonPrimaryColor,
                ),
              ),
            // WidgetSpan(
            //   child: Container(
            //     padding: EdgeInsets.only(
            //       right: 4.0,
            //     ),
            //     child: Transform.scale(
            //       scale: 1.3,
            //       child: Icon(
            //         Icons.arrow_right_rounded,
            //         color: Vingo.ThemeUtil.of(context).buttonPrimaryColor,
            //       ),
            //     ),
            //   ),
            // ),
            if (!todo && ordered)
              TextSpan(
                text: match.group(3)! + " ",
                style: TextStyle(
                  color: Vingo.ThemeUtil.of(context).buttonPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (todo)
              TextSpan(
                text:
                    (checked ? boxChecked : box) + inv + inv + inv + inv + " ",
                style: TextStyle(
                  color: Vingo.ThemeUtil.of(context).buttonPrimaryColor,
                ),
              ),
            // WidgetSpan(
            //   child: Container(
            //     padding: EdgeInsets.only(
            //       right: 4.0,
            //     ),
            //     child: Transform.scale(
            //       scale: 1.0,
            //       child: Icon(
            //         checked ? Icons.check_box : Icons.check_box_outline_blank,
            //         color: Vingo.ThemeUtil.of(context).buttonPrimaryColor,
            //       ),
            //     ),
            //   ),
            // ),
            TextSpan(
              children: run(
                context: context,
                functions: <Function>[
                  blockCode,
                  blockTex,
                  blockImage,
                  blockList,
                  inlineLink,
                  inlineBoldItalicCode,
                  inlineBoldItalic,
                  inlineBoldCode,
                  inlineItalicCode,
                  inlineCode,
                  inlineTex,
                  inlineBold,
                  inlineItalic,
                ],
                index: 0,
                text: match.group(5)!,
                style: style,
              ),
            ),

            // WidgetSpan(
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(List.generate(length, (i) => tab).toList().join()),
            //       if (!todo && !ordered)
            //         Container(
            //           padding: EdgeInsets.only(
            //             right: 4.0,
            //           ),
            //           child: Icon(
            //             Icons.arrow_right_rounded,
            //             color: Vingo.ThemeUtil.of(context).buttonPrimaryColor,
            //           ),
            //         ),
            //       if (!todo && ordered)
            //         Container(
            //           padding: EdgeInsets.only(
            //             right: 4.0,
            //             top: 2.0,
            //           ),
            //           child: Transform.scale(
            //             scale: 0.9,
            //             child: Text(
            //               match.group(2)!,
            //               style: TextStyle(
            //                 color:
            //                     Vingo.ThemeUtil.of(context).buttonPrimaryColor,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           ),
            //         ),
            //       if (todo)
            //         Container(
            //           padding: EdgeInsets.only(
            //             right: 4.0,
            //           ),
            //           child: Transform.scale(
            //             scale: 0.75,
            //             child: Icon(
            //               checked
            //                   ? Icons.check_box
            //                   : Icons.check_box_outline_blank,
            //               color: Vingo.ThemeUtil.of(context).buttonPrimaryColor,
            //             ),
            //           ),
            //         ),
            //       Flexible(
            //         child: Container(
            //           padding: EdgeInsets.only(
            //             top: 2.0,
            //           ),
            //           child: Text(
            //             match.group(4)!,
            //           ),
            //         ),
            //       )
            //     ],
            //   ),
            //   // alignment: Ui.PlaceholderAlignment.middle,
            // ),
            // TextSpan(
            //   text: match.group(5),
            // ),
          ],
          style: style,
        );
      },
      text: text,
      style: style,
      process: process,
    );
  }

  static List<InlineSpan> block({
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
