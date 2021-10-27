import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:vingo/util/util.dart' as Vingo;
import 'package:vingo/widget/widget.dart' as Vingo;

/// Displays disposable messages using a snackbar.
class Messenger {
  static Messenger? instance;
  late BuildContext buildContext;
  late ScaffoldMessengerState? scaffoldMessengerState;

  static Messenger of(BuildContext context) {
    if (instance == null) {
      instance = Messenger();
    }
    instance?.buildContext = context;
    instance?.scaffoldMessengerState = ScaffoldMessenger.of(context);
    return instance!;
  }

  void hide() {
    if (scaffoldMessengerState != null && scaffoldMessengerState!.mounted) {
      scaffoldMessengerState?.hideCurrentSnackBar();
    }
  }

  void show({
    String? title,
    required Widget content,
    Duration duration = const Duration(milliseconds: 3000),
    bool fullscreen = false,
    bool closeButton = true,
  }) {
    if (scaffoldMessengerState == null) return;
    scaffoldMessengerState?.hideCurrentSnackBar();
    scaffoldMessengerState?.showSnackBar(SnackBar(
      duration: duration,
      padding: EdgeInsets.only(
        top: Vingo.ThemeUtil.padding,
        left: Vingo.ThemeUtil.paddingDouble,
        right: Vingo.ThemeUtil.paddingDouble,
        bottom: Vingo.ThemeUtil.padding,
      ),
      behavior: SnackBarBehavior.fixed,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (title != null)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: Vingo.ThemeUtil.textFontSizeMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (title == null) content,
              Flexible(child: Container()),
              if (closeButton)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Vingo.ThemeUtil.of(buildContext).iconColorReversed,
                  ),
                  tooltip: Vingo.LocalizationsUtil.of(buildContext).close +
                      ' (' +
                      Vingo.Shortcuts.closeShortcut +
                      ')',
                  onPressed: () async {
                    scaffoldMessengerState?.hideCurrentSnackBar();
                  },
                ),
            ],
          ),
          if (title != null)
            Flexible(
              fit: fullscreen ? FlexFit.tight : FlexFit.loose,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: Vingo.ThemeUtil.paddingDouble,
                      // left: Vingo.ThemeUtil.paddingQuarter,
                      right: Vingo.ThemeUtil.padding,
                    ),
                    child: content,
                  ),
                ],
              ),
            ),
        ],
      ),
    ));
  }

  void showText({
    required String text,
    Duration duration = const Duration(milliseconds: 3000),
    bool fullscreen = false,
    bool closeButton = true,
  }) {
    show(
      content: Text(
        text,
      ),
      duration: duration,
      fullscreen: fullscreen,
      closeButton: closeButton,
    );
  }

  /// Show a table consisting of rows and columns of widgets.
  ///
  /// ```dart
  /// Vingo.Messenger.of(context).showTable(
  ///   table: [
  ///     [Text("key 1"), Text("value 1")],
  ///     [Text("key 2"), Text("value 2")]
  ///   ]
  /// );
  /// ```
  void showTable({
    String? title,
    required List<List<Widget>> table,
    Duration duration = const Duration(milliseconds: 3000),
    bool fullscreen = false,
    bool closeButton = true,
  }) {
    show(
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: table
            .map((row) => Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: row
                      .map((col) => Padding(
                            padding:
                                EdgeInsets.all(Vingo.ThemeUtil.paddingQuarter),
                            child: col,
                          ))
                      .toList(),
                ))
            .toList(),
      ),
      duration: duration,
      fullscreen: fullscreen,
      closeButton: closeButton,
    );
  }
}
