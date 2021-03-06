import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vingo/util/util.dart' as Vingo;
import 'package:vingo/widget/widget.dart' as Vingo;

class TextDialog extends StatefulWidget {
  final String title;
  final String? currentValue;
  final String? labelText;
  final String? hintText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final String? description;
  final String? confirmText;
  final String? declineText;

  const TextDialog({
    Key? key,
    required this.title,
    this.currentValue,
    this.labelText,
    this.hintText,
    this.keyboardType,
    this.maxLines,
    this.maxLength,
    this.description,
    this.confirmText,
    this.declineText,
  }) : super(key: key);

  /// Show input dialog.
  ///
  /// ```dart
  /// String? result = await Vingo.TextDialog.show(
  ///     context: context,
  ///     currentValue: "",
  ///     hintText: ""
  ///   );
  /// ```
  static Future<String?> show({
    Key? key,
    required BuildContext context,
    bool barrierDismissible = true,
    required String title,
    String? currentValue,
    String? labelText,
    String? hintText,
    TextInputType? keyboardType,
    int? maxLines,
    int? maxLength,
    String? description,
    String? confirmText,
    String? declineText,
  }) async {
    return await showDialog<String?>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) {
          return TextDialog(
            key: key,
            title: title,
            currentValue: currentValue,
            labelText: labelText,
            hintText: hintText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            maxLength: maxLength,
            description: description,
            confirmText: confirmText,
            declineText: declineText,
          );
        });
  }

  @override
  _TextDialogState createState() => _TextDialogState();
}

class _TextDialogState extends State<TextDialog> {
  String currentValue = "";

  @override
  void initState() {
    super.initState();
    if (widget.currentValue != null && widget.currentValue!.isNotEmpty) {
      currentValue = widget.currentValue!;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onConfirm(BuildContext context) {
    Navigator.of(context).pop(currentValue);
  }

  void onDecline(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Vingo.ThemeUtil.of(context).dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.all(Radius.circular(Vingo.ThemeUtil.borderRadius)),
      ),
      title: Text(
        widget.title,
        style: TextStyle(
          fontSize: Vingo.ThemeUtil.textFontSizeMedium,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.only(
              top: Vingo.ThemeUtil.paddingHalf,
              bottom: Vingo.ThemeUtil.paddingHalf,
              left: Vingo.ThemeUtil.paddingDouble,
              right: Vingo.ThemeUtil.paddingDouble,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.description != null &&
                    widget.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: Vingo.ThemeUtil.paddingHalf,
                      bottom: Vingo.ThemeUtil.padding,
                      left: Vingo.ThemeUtil.paddingDouble,
                      right: Vingo.ThemeUtil.paddingDouble,
                    ),
                    child: Text(
                      widget.description ?? "",
                      style: TextStyle(
                        color: Vingo.ThemeUtil.of(context).textMutedColor,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: Vingo.ThemeUtil.paddingHalf,
                    bottom: Vingo.ThemeUtil.padding,
                    // left: Vingo.ThemeUtil.padding,
                    // right: Vingo.ThemeUtil.padding,
                  ),
                  child: Vingo.Shortcuts(
                    onConfirmDetected: () {
                      onConfirm(context);
                    },
                    onCloseDetected: () {
                      onDecline(context);
                    },
                    child: Vingo.TextFieldExtended(
                      autofocus: true,
                      initialValue: currentValue,
                      labelText: widget.labelText,
                      keyboardType: widget.keyboardType,
                      hintText: widget.hintText,
                      maxLines: widget.maxLines ?? 1,
                      maxLength: widget.maxLength,
                      maxLengthEnforcement: widget.maxLength != null
                          ? MaxLengthEnforcement.enforced
                          : MaxLengthEnforcement.none,
                      onConfirmDetected: () {
                        onConfirm(context);
                      },
                      onCloseDetected: () {
                        onDecline(context);
                      },
                      onChange: (value) {
                        currentValue = value;
                      },
                    ),
                  ),
                ),
              ],
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
          text: widget.declineText != null
              ? widget.declineText!.toUpperCase()
              : Vingo.LocalizationsUtil.of(context).cancel.toUpperCase(),
          onPressed: () {
            onDecline(context);
          },
        ),
        Vingo.Button(
          text: widget.confirmText != null
              ? widget.confirmText!.toUpperCase()
              : Vingo.LocalizationsUtil.of(context).ok.toUpperCase(),
          type: Vingo.ButtonType.PRIMARY,
          onPressed: () {
            onConfirm(context);
          },
        ),
      ],
    );
  }
}
