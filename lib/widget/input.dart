import 'dart:ui' as Ui;
import 'dart:async' as Async;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vingo/util/localizations.dart' as Vingo;
import 'package:vingo/util/theme.dart' as Vingo;

class Input extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focuseNode;
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? maxLength;
  final double? fontSize;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final bool? autofocus;
  final bool? autocorrect;
  final bool? enableSuggestions;
  final bool? obscureText;
  final int? changeDelayInMilliseconds;
  final ValueChanged<String>? onChange;
  final ValueChanged<String>? onDelayedChange;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;

  const Input({
    Key? key,
    this.controller,
    this.focuseNode,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.keyboardType = TextInputType.text,
    this.maxLines,
    this.maxLength,
    this.fontSize,
    this.maxLengthEnforcement = MaxLengthEnforcement.enforced,
    this.autofocus = false,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.obscureText = false,
    this.changeDelayInMilliseconds,
    this.onChange,
    this.onDelayedChange,
    this.onFieldSubmitted,
    this.onTap,
  }) : super(key: key);

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  static const double radius = 4.0;
  Ui.TextDirection textDirection = Ui.TextDirection.ltr;
  Async.Timer? changeDelayTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Ui.TextDirection getTextDirection(BuildContext context) {
    if (widget.controller != null && widget.controller!.text.isNotEmpty) {
      textDirection = Vingo.LocalizationsUtil.textDirectionByStr(
        widget.controller!.text,
      );
    } else if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      textDirection = Vingo.LocalizationsUtil.textDirectionByStr(
        widget.initialValue!,
      );
    } else if (widget.hintText != null && widget.hintText!.isNotEmpty) {
      textDirection = Vingo.LocalizationsUtil.textDirectionByStr(
        widget.hintText!,
      );
    } else {
      textDirection = Vingo.LocalizationsUtil.textDirection(context);
    }
    return textDirection;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Directionality(
            textDirection: getTextDirection(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: widget.controller,
                  focusNode: widget.focuseNode,
                  autofocus: widget.autofocus ?? false,
                  autocorrect: widget.autocorrect ?? false,
                  enableSuggestions: widget.enableSuggestions ?? false,
                  obscureText: widget.obscureText ?? false,
                  initialValue: widget.initialValue,
                  cursorColor: Vingo.ThemeUtil.of(context).inputCursorColor,
                  cursorWidth: 2.0,
                  cursorRadius: Radius.circular(2.0),
                  style: TextStyle(
                    fontSize: widget.fontSize ?? Vingo.ThemeUtil.textFontSize,
                  ),
                  decoration: InputDecoration(
                    isDense: false,
                    contentPadding: EdgeInsets.only(
                      left: Vingo.ThemeUtil.padding,
                      right: Vingo.ThemeUtil.padding,
                      top: Vingo.ThemeUtil.padding,
                      bottom: Vingo.ThemeUtil.padding,
                    ),
                    labelText: widget.labelText,
                    hintText: widget.hintText,
                    filled: true,
                    fillColor: Vingo.ThemeUtil.of(context).inputFillColor,
                    focusColor: Vingo.ThemeUtil.of(context).inputFocusColor,
                    hoverColor: Vingo.ThemeUtil.of(context).inputHoverColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius),
                      borderSide: BorderSide(
                        color: Vingo.ThemeUtil.of(context).inputBorderColor,
                        width: 0.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius),
                      borderSide: BorderSide(
                        color:
                            Vingo.ThemeUtil.of(context).inputFocusedBorderColor,
                        width: 0.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius),
                      borderSide: BorderSide(
                        color: Vingo.ThemeUtil.of(context).inputBorderColor,
                        width: 0.0,
                      ),
                    ),
                  ),
                  keyboardType: widget.keyboardType,
                  maxLines: widget.maxLines,
                  maxLength: widget.maxLength,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  onChanged: (value) {
                    var td = Vingo.LocalizationsUtil.textDirectionByStr(value);
                    if (td != textDirection) {
                      setState(() {
                        textDirection = td;
                      });
                    }
                    // Callback without delay
                    if (widget.onChange != null) {
                      widget.onChange!(value);
                    }
                    // Callback without delay
                    if (widget.changeDelayInMilliseconds == null) {
                      if (widget.onDelayedChange != null) {
                        widget.onDelayedChange!(value);
                      }
                    }
                    // Callback with delay
                    else {
                      var callback = () {
                        if (widget.onDelayedChange != null) {
                          widget.onDelayedChange!(value);
                        }
                        changeDelayTimer = null;
                      };
                      if (changeDelayTimer == null) {
                        changeDelayTimer = Async.Timer(
                          Duration(
                            milliseconds: widget.changeDelayInMilliseconds!,
                          ),
                          callback,
                        );
                      }
                      if (changeDelayTimer != null &&
                          changeDelayTimer!.isActive) {
                        changeDelayTimer!.cancel();
                        changeDelayTimer = Async.Timer(
                          Duration(
                            milliseconds: widget.changeDelayInMilliseconds!,
                          ),
                          callback,
                        );
                      }
                    }
                  },
                  onTap: () {
                    if (widget.onTap != null) {
                      widget.onTap!();
                    }
                  },
                  onFieldSubmitted: (value) {
                    if (widget.onFieldSubmitted != null) {
                      widget.onFieldSubmitted!(value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
