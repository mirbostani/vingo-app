import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vingo/util/theme.dart' as Vingo;

enum ButtonType {
  NORMAL,
  PRIMARY,
  SECONDARY,
}

class Button extends StatelessWidget {
  final String? text;
  final double? textFontSize;
  final double? height;
  final double? minWidth;
  final BorderRadius? borderRadius;
  final ButtonType? type;
  final bool? progressIndicatorEnabled;
  final void Function()? onPressed;

  const Button({
    Key? key,
    this.text,
    this.textFontSize,
    this.height,
    this.minWidth,
    this.borderRadius,
    this.type,
    this.progressIndicatorEnabled,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child = Text(
      text ?? "",
      style: TextStyle(fontSize: textFontSize),
    );

    if (progressIndicatorEnabled ?? false) {
      child = SizedBox(
        height:
            height != null ? height! * 0.5 : Vingo.ThemeUtil.fabIconSizeTiny,
        width: height != null ? height! * 0.5 : Vingo.ThemeUtil.fabIconSizeTiny,
        child: CircularProgressIndicator(
          strokeWidth: 3.0,
          backgroundColor: () {
            switch (type ?? ButtonType.NORMAL) {
              case ButtonType.NORMAL:
                return Vingo.ThemeUtil.of(context)
                    .progressIndicatorBackgroundColor;
              case ButtonType.PRIMARY:
                return Vingo.ThemeUtil.of(context)
                    .buttonPrimaryProgressIndicatorBackgroundColor;
              case ButtonType.SECONDARY:
                return Vingo.ThemeUtil.of(context)
                    .buttonSecondaryProgressIndicatorBackgroundColor;
            }
          }(),
          valueColor: AlwaysStoppedAnimation<Color>(() {
            switch (type ?? ButtonType.NORMAL) {
              case ButtonType.NORMAL:
                return Vingo.ThemeUtil.of(context).progressIndicatorValueColor;
              case ButtonType.PRIMARY:
                return Vingo.ThemeUtil.of(context)
                    .buttonPrimaryProgressIndicatorValueColor;
              case ButtonType.SECONDARY:
                return Vingo.ThemeUtil.of(context)
                    .buttonSecondaryProgressIndicatorValueColor;
            }
          }()),
          value: null,
        ),
      );
    }

    var _onPressed = () {
      if (progressIndicatorEnabled ?? false) return;
      if (onPressed != null) onPressed!();
    };

    switch (type ?? ButtonType.NORMAL) {
      case ButtonType.NORMAL:
        return Container(
          child: TextButton(
            child: child,
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                  Vingo.ThemeUtil.of(context).buttonTextColor),
            ),
            onPressed: _onPressed,
          ),
        );
      case ButtonType.PRIMARY:
        return Container(
          child: TextButton(
            child: child,
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(
                  Vingo.ThemeUtil.of(context).buttonPrimaryTextColor,
                ),
                backgroundColor: MaterialStateProperty.all(
                  Vingo.ThemeUtil.of(context).buttonPrimaryColor,
                )),
            onPressed: _onPressed,
          ),
        );
      case ButtonType.SECONDARY:
        return Container(
          child: TextButton(
            child: child,
            style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(
                  Vingo.ThemeUtil.of(context).buttonSecondaryTextColor,
                ),
                backgroundColor: MaterialStateProperty.all(
                  Vingo.ThemeUtil.of(context).buttonSecondaryColor,
                )),
            onPressed: _onPressed,
          ),
        );
    }
  }
}
