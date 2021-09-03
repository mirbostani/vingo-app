import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vingo/util/util.dart' as Vingo;
import 'package:vingo/widget/widget.dart' as Vingo;

class Dialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmText;
  final Vingo.ButtonType? confirmButtonType;
  final String? declineText;
  final Vingo.ButtonType? declineButtonType;

  const Dialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText,
    this.confirmButtonType,
    this.declineText,
    this.declineButtonType,
  }) : super(key: key);

  static Future<bool?> show({
    Key? key,
    required BuildContext context,
    bool barrierDismissible = true,
    required String title,
    required String message,
    String? confirmText,
    Vingo.ButtonType? confirmButtonType,
    String? declineText,
    Vingo.ButtonType? declineButtonType,
  }) async {
    return await showDialog<bool?>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) {
          return Dialog(
            key: key,
            title: title,
            message: message,
            confirmText: confirmText,
            confirmButtonType: confirmButtonType,
            declineText: declineText,
            declineButtonType: declineButtonType,
          );
        });
  }

  void onConfirm(BuildContext context) {
    Navigator.of(context).pop(true);
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
        title,
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
                    child: Text(message),
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
          text: declineText != null
              ? declineText!.toUpperCase()
              : Vingo.LocalizationsUtil.of(context).cancel.toUpperCase(),
          type: declineButtonType,
          onPressed: () {
            onDecline(context);
          },
        ),
        Vingo.Button(
          text: confirmText != null
              ? confirmText!.toUpperCase()
              : Vingo.LocalizationsUtil.of(context).ok.toUpperCase(),
          type: confirmButtonType ?? Vingo.ButtonType.PRIMARY,
          onPressed: () {
            onConfirm(context);
          },
        ),
      ],
    );
  }
}
