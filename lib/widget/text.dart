import 'dart:ui' as Ui;
import 'dart:async' as Async;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vingo/util/util.dart' as Vingo;
import 'package:vingo/widget/widget.dart' as Vingo;

class Text extends StatefulWidget {
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
  final bool? enabled;
  final bool? autofocus;
  final bool? autocorrect;
  final bool? enableSuggestions;
  final bool? obscureText;
  final bool? readOnly;
  final bool? enableInteractiveSelection;
  final int? changeDelayInMilliseconds;
  final ValueChanged<String>? onChange;
  final ValueChanged<String>? onDelayedChange;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final VoidCallback? onTap;
  final VoidCallback? onConfirmDetected; // shortcut
  final VoidCallback? onCloseDetected; // shortcut

  const Text({
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
    this.enabled = true,
    this.autofocus = false,
    this.autocorrect = false,
    this.enableSuggestions = false,
    this.obscureText = false,
    this.readOnly = false,
    this.enableInteractiveSelection = false,
    this.changeDelayInMilliseconds,
    this.onChange,
    this.onDelayedChange,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.onTap,
    this.onConfirmDetected,
    this.onCloseDetected,
  }) : super(key: key);

  @override
  _TextState createState() => _TextState();
}

class _TextState extends State<Text> {
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
    return Vingo.Shortcuts(
      autofocus: false,
      onCloseDetected: () {
        widget.onCloseDetected?.call();
      },
      onConfirmDetected: () {
        widget.onConfirmDetected?.call();
      },
      child: Column(
        children: [
          Container(
            child: Directionality(
              textDirection: getTextDirection(context),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    enabled: widget.enabled ?? true,
                    controller: widget.controller,
                    focusNode: widget.focuseNode,
                    autofocus: widget.autofocus ?? false,
                    autocorrect: widget.autocorrect ?? false,
                    enableSuggestions: widget.enableSuggestions ?? false,
                    obscureText: widget.obscureText ?? false,
                    readOnly: widget.readOnly ?? false,
                    enableInteractiveSelection:
                        widget.enableInteractiveSelection ?? false,
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
                      hintStyle: TextStyle(
                        color: Vingo.ThemeUtil.of(context)
                            .textPrimaryColor
                            .withAlpha(150),
                      ),
                      filled: true,
                      // fillColor: Vingo.ThemeUtil.of(context).inputFillColor,
                      focusColor: Vingo.ThemeUtil.of(context).inputFocusColor,
                      hoverColor: Vingo.ThemeUtil.of(context).inputHoverColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius),
                        borderSide: BorderSide(
                          color: Vingo.ThemeUtil.of(context).inputBorderColor,
                          // width: 0.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius),
                        borderSide: BorderSide(
                          color: Vingo.ThemeUtil.of(context)
                              .inputFocusedBorderColor,
                          // width: 0.0,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius),
                        borderSide: BorderSide(
                          color: Vingo.ThemeUtil.of(context).inputBorderColor,
                          // width: 0.0,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(radius),
                        borderSide: BorderSide(
                          color: Vingo.ThemeUtil.of(context).inputBorderColor,
                          // width: 0.0,
                        ),
                      ),
                    ),
                    keyboardType: widget.keyboardType,
                    maxLines: widget.maxLines,
                    maxLength: widget.maxLength,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    onChanged: (value) {
                      var td =
                          Vingo.LocalizationsUtil.textDirectionByStr(value);
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
                        widget.onDelayedChange?.call(value);
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
                      widget.onTap?.call();
                    },
                    onFieldSubmitted: (value) {
                      widget.onFieldSubmitted?.call(value);
                      widget.onConfirmDetected?.call();
                    },
                    onEditingComplete: () {
                      widget.onEditingComplete?.call();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
