import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vingo/util/util.dart' as Vingo;

enum ButtonType {
  NORMAL,
  PRIMARY,
  SECONDARY,
  AGAIN,
  HARD,
  GOOD,
  EASY,
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
              case ButtonType.AGAIN:
                return Vingo.ThemeUtil.of(context)
                    .buttonSecondaryProgressIndicatorBackgroundColor;
              case ButtonType.HARD:
                return Vingo.ThemeUtil.of(context)
                    .buttonSecondaryProgressIndicatorBackgroundColor;
              case ButtonType.GOOD:
                return Vingo.ThemeUtil.of(context)
                    .buttonSecondaryProgressIndicatorBackgroundColor;
              case ButtonType.EASY:
                return Vingo.ThemeUtil.of(context)
                    .buttonSecondaryProgressIndicatorBackgroundColor;
            }
          }(),
          valueColor: AlwaysStoppedAnimation<Color?>(() {
            switch (type ?? ButtonType.NORMAL) {
              case ButtonType.NORMAL:
                return Vingo.ThemeUtil.of(context).progressIndicatorValueColor;
              case ButtonType.PRIMARY:
                return Vingo.ThemeUtil.of(context)
                    .buttonPrimaryProgressIndicatorValueColor;
              case ButtonType.SECONDARY:
                return Vingo.ThemeUtil.of(context)
                    .buttonSecondaryProgressIndicatorValueColor;
              case ButtonType.AGAIN:
                return Vingo.ThemeUtil.of(context)
                    .buttonSecondaryProgressIndicatorValueColor;
              case ButtonType.HARD:
                return Vingo.ThemeUtil.of(context)
                    .buttonSecondaryProgressIndicatorValueColor;
              case ButtonType.GOOD:
                return Vingo.ThemeUtil.of(context)
                    .buttonSecondaryProgressIndicatorValueColor;
              case ButtonType.EASY:
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
              ),
            ),
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
              ),
            ),
            onPressed: _onPressed,
          ),
        );
      case ButtonType.AGAIN:
        return Container(
          child: TextButton(
            child: child,
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                Vingo.ThemeUtil.of(context).buttonAgainTextColor,
              ),
              backgroundColor: MaterialStateProperty.all(
                Vingo.ThemeUtil.of(context).buttonAgainColor,
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
                side: BorderSide.none,
              )),
            ),
            onPressed: _onPressed,
          ),
        );
      case ButtonType.HARD:
        return Container(
          child: TextButton(
            child: child,
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                Vingo.ThemeUtil.of(context).buttonHardTextColor,
              ),
              backgroundColor: MaterialStateProperty.all(
                Vingo.ThemeUtil.of(context).buttonHardColor,
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
                side: BorderSide.none,
              )),
            ),
            onPressed: _onPressed,
          ),
        );
      case ButtonType.GOOD:
        return Container(
          child: TextButton(
            child: child,
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                Vingo.ThemeUtil.of(context).buttonGoodTextColor,
              ),
              backgroundColor: MaterialStateProperty.all(
                Vingo.ThemeUtil.of(context).buttonGoodColor,
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
                side: BorderSide.none,
              )),
            ),
            onPressed: _onPressed,
          ),
        );
      case ButtonType.EASY:
        return Container(
          child: TextButton(
            child: child,
            style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(
                Vingo.ThemeUtil.of(context).buttonEasyTextColor,
              ),
              backgroundColor: MaterialStateProperty.all(
                Vingo.ThemeUtil.of(context).buttonEasyColor,
              ),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
                side: BorderSide.none,
              )),
            ),
            onPressed: _onPressed,
          ),
        );
    }
  }
}
