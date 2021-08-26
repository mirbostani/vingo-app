import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vingo/util/localizations.dart' as Vingo;
import 'package:vingo/util/theme.dart' as Vingo;
import 'package:vingo/widget/button.dart' as Vingo;

class RadioDialog extends StatefulWidget {
  final String title;
  final String currentOptionKey;
  final Map<String, String> options;

  const RadioDialog({
    Key? key,
    required this.title,
    required this.currentOptionKey,
    required this.options,
  }) : super(key: key);

  /// Show radio dialog.
  ///
  /// ```dart
  /// String? result = await Vingo.RadioDialog.show(
  ///     context: context,
  ///     title: "Choose language",
  ///     currentOptionKey: "fa",
  ///     options: {
  ///       "fa": "Persian",
  ///       "en": "English",
  ///     },
  ///   );
  /// ```
  ///
  /// @return Returns one of the option keys or `null` if being cancelled.
  static Future<String?> show({
    Key? key,
    required BuildContext context,
    bool barrierDismissible = true,
    required String title,
    required String currentOptionKey,
    required Map<String, String> options,
  }) async {
    return await showDialog<String?>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) {
          return RadioDialog(
            key: key,
            title: title,
            currentOptionKey: currentOptionKey,
            options: options,
          );
        });
  }

  @override
  _RadioDialogState createState() => _RadioDialogState();
}

class _RadioDialogState extends State<RadioDialog> {
  String? _currentOptionKey;

  @override
  void initState() {
    super.initState();
    _currentOptionKey = widget.currentOptionKey;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[];
    widget.options.forEach((k, v) {
      Widget child = GestureDetector(
        onTap: () {
          setState(() {
            _currentOptionKey = k;
          });
        },
        child: ListTile(
          horizontalTitleGap: 0.0,
          contentPadding: EdgeInsets.zero,
          leading: Radio(
            value: k,
            groupValue: _currentOptionKey,
            onChanged: (value) {
              setState(() {
                _currentOptionKey = value as String?;
              });
            },
          ),
          title: Text(
            v,
          ),
        ),
      );
      children.add(child);
    });

    return AlertDialog(
      backgroundColor: Vingo.ThemeUtil.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(Vingo.ThemeUtil.borderRadius)),
      ),
      title: Text(
        widget.title,
      ),
      content: StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.only(
              top: Vingo.ThemeUtil.paddingHalf,
              bottom: Vingo.ThemeUtil.paddingHalf,
              left: Vingo.ThemeUtil.padding,
              right: Vingo.ThemeUtil.padding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          );
        },
      ),
      contentPadding: EdgeInsets.only(
        top: Vingo.ThemeUtil.padding,
        bottom: 0.0,
      ),
      actions: [
        Vingo.Button(
          text: Vingo.LocalizationsUtil.of(context).cancel.toUpperCase(),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        Vingo.Button(
          text: Vingo.LocalizationsUtil.of(context).ok.toUpperCase(),
          type: Vingo.ButtonType.PRIMARY,
          onPressed: () {
            Navigator.of(context).pop(_currentOptionKey);
          },
        ),
      ],
    );
  }
}
