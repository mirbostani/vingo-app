import 'dart:io' as Io;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Shortcuts extends StatelessWidget {
  final Widget child;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onConfirmDetected;
  final VoidCallback? onNewDetected;
  final VoidCallback? onCloseDetected;
  final VoidCallback? onHelpDetected;
  final VoidCallback? onNavUpDetected;
  final VoidCallback? onNavDownDetected;
  final VoidCallback? onNavLeftDetected;
  final VoidCallback? onNavRightDetected;

  const Shortcuts({
    Key? key,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.onConfirmDetected,
    this.onNewDetected,
    this.onCloseDetected,
    this.onHelpDetected,
    this.onNavUpDetected,
    this.onNavDownDetected,
    this.onNavLeftDetected,
    this.onNavRightDetected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: autofocus,
      focusNode: focusNode,
      shortcuts: {
        ConfirmIntent.key: ConfirmIntent(),
        NewIntent.key: NewIntent(),
        CloseIntent.key: CloseIntent(),
        HelpIntent.key: HelpIntent(),
      },
      actions: {
        ConfirmIntent: CallbackAction(
          onInvoke: (intent) => onConfirmDetected?.call(),
        ),
        NewIntent: CallbackAction(
          onInvoke: (intent) => onNewDetected?.call(),
        ),
        CloseIntent: CallbackAction(
          onInvoke: (intent) => onCloseDetected?.call(),
        ),
        HelpIntent: CallbackAction(
          onInvoke: (intent) => onHelpDetected?.call(),
        ),
        ArrowUpIntent: CallbackAction(
          onInvoke: (intent) => onNavUpDetected?.call(),
        ),
        ArrowDownIntent: CallbackAction(
          onInvoke: (intent) => onNavDownDetected?.call(),
        ),
        ArrowLeftIntent: CallbackAction(
          onInvoke: (intent) => onNavLeftDetected?.call(),
        ),
        ArrowRightIntent: CallbackAction(
          onInvoke: (intent) => onNavRightDetected?.call(),
        ),
      },
      child: child,
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

class ConfirmIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(LogicalKeyboardKey.enter);
}

class NewIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(
    Io.Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyN,
  );
}

class CloseIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(LogicalKeyboardKey.escape);
}

class HelpIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(LogicalKeyboardKey.f1);
}

class ArrowUpIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(LogicalKeyboardKey.arrowUp);
}

class ArrowDownIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(LogicalKeyboardKey.arrowDown);
}

class ArrowLeftIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(LogicalKeyboardKey.arrowLeft);
}

class ArrowRightIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(LogicalKeyboardKey.arrowRight);
}