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

  const Shortcuts({
    Key? key,
    required this.child,
    this.focusNode,
    this.autofocus = false,
    this.onConfirmDetected,
    this.onNewDetected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      autofocus: autofocus,
      focusNode: focusNode,
      shortcuts: {
        ConfirmIntent.key: ConfirmIntent(),
        NewIntent.key: NewIntent(),
      },
      actions: {
        ConfirmIntent: CallbackAction(
          onInvoke: (intent) => onConfirmDetected?.call(),
        ),
        NewIntent: CallbackAction(
          onInvoke: (intent) => onNewDetected?.call(),
        ),
      },
      child: child,
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

class ConfirmIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(
    LogicalKeyboardKey.enter,
  );
}

class NewIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(
    Io.Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyN,
  );
}
