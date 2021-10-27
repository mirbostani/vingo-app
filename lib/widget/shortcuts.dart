import 'dart:io' as Io;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

LogicalKeySet testKey = LogicalKeySet(
  Io.Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
  LogicalKeyboardKey.keyN,
);

class Shortcuts extends StatelessWidget {
  final Widget child;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onConfirmDetected;
  final VoidCallback? onNewDetected;
  final VoidCallback? onEditDetected;
  final VoidCallback? onCloseDetected;
  final VoidCallback? onHelpDetected;
  final VoidCallback? onSearchDetected;
  final VoidCallback? onStudyDetected;
  final VoidCallback? onSaveDetected;
  final VoidCallback? onBackDetected;
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
    this.onEditDetected,
    this.onCloseDetected,
    this.onHelpDetected,
    this.onSearchDetected,
    this.onStudyDetected,
    this.onSaveDetected,
    this.onBackDetected,
    this.onNavUpDetected,
    this.onNavDownDetected,
    this.onNavLeftDetected,
    this.onNavRightDetected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<ShortcutActivator, Intent> shortcuts = {};
    Map<Type, Action<Intent>> actions = {};
    if (onConfirmDetected != null) {
      shortcuts[ConfirmIntent.key] = ConfirmIntent();
      actions[ConfirmIntent] = CallbackAction(
        onInvoke: (intent) => onConfirmDetected?.call(),
      );
    }
    if (onNewDetected != null) {
      shortcuts[NewIntent.key] = NewIntent();
      actions[NewIntent] = CallbackAction(
        onInvoke: (intent) => onNewDetected?.call(),
      );
    }
    if (onEditDetected != null) {
      shortcuts[EditIntent.key] = EditIntent();
      actions[EditIntent] = CallbackAction(
        onInvoke: (intent) => onEditDetected?.call(),
      );
    }
    if (onCloseDetected != null) {
      shortcuts[CloseIntent.key] = CloseIntent();
      actions[CloseIntent] = CallbackAction(
        onInvoke: (intent) => onCloseDetected?.call(),
      );
    }
    if (onHelpDetected != null) {
      shortcuts[HelpIntent.key] = HelpIntent();
      actions[HelpIntent] = CallbackAction(
        onInvoke: (intent) => onHelpDetected?.call(),
      );
    }
    if (onSearchDetected != null) {
      shortcuts[SearchIntent.key] = SearchIntent();
      actions[SearchIntent] = CallbackAction(
        onInvoke: (intent) => onSearchDetected?.call(),
      );
    }
    if (onStudyDetected != null) {
      shortcuts[StudyIntent.key] = StudyIntent();
      actions[StudyIntent] = CallbackAction(
        onInvoke: (intent) => onStudyDetected?.call(),
      );
    }
    if (onSaveDetected != null) {
      shortcuts[SaveIntent.key] = SaveIntent();
      actions[SaveIntent] = CallbackAction(
        onInvoke: (intent) => onSaveDetected?.call(),
      );
    }
    if (onBackDetected != null) {
      shortcuts[BackIntent.key] = BackIntent();
      actions[BackIntent] = CallbackAction(
        onInvoke: (intent) => onBackDetected?.call(),
      );
    }
    if (onNavUpDetected != null) {
      shortcuts[ArrowUpIntent.key] = ArrowUpIntent();
      actions[ArrowUpIntent] = CallbackAction(
        onInvoke: (intent) => onNavUpDetected?.call(),
      );
    }
    if (onNavDownDetected != null) {
      shortcuts[ArrowDownIntent.key] = ArrowDownIntent();
      actions[ArrowDownIntent] = CallbackAction(
        onInvoke: (intent) => onNavDownDetected?.call(),
      );
    }
    if (onNavLeftDetected != null) {
      shortcuts[ArrowLeftIntent.key] = ArrowLeftIntent();
      actions[ArrowLeftIntent] = CallbackAction(
        onInvoke: (intent) => onNavLeftDetected?.call(),
      );
    }
    if (onNavRightDetected != null) {
      shortcuts[ArrowRightIntent.key] = ArrowRightIntent();
      actions[ArrowRightIntent] = CallbackAction(
        onInvoke: (intent) => onNavRightDetected?.call(),
      );
    }

    return FocusableActionDetector(
      autofocus: autofocus,
      focusNode: focusNode,
      shortcuts: shortcuts,
      actions: actions,
      child: child,
    );
  }

  //----------------------------------------------------------------------------

  static String _prepareKeyLabel(LogicalKeySet key) {
    return key.keys.map((k) => k.keyLabel).join(' + ');
  }

  static String helpShortcut = _prepareKeyLabel(HelpIntent.key);
  static String closeShortcut = _prepareKeyLabel(CloseIntent.key);
  static String backShortcut = _prepareKeyLabel(BackIntent.key);
  static String newShortcut = _prepareKeyLabel(NewIntent.key);
  static String editShortcut = _prepareKeyLabel(EditIntent.key);
  static String searchShortcut = _prepareKeyLabel(SearchIntent.key);
  static String studyShortcut = _prepareKeyLabel(StudyIntent.key);
  static String saveShortcut = _prepareKeyLabel(SaveIntent.key);
}

////////////////////////////////////////////////////////////////////////////////

class ConfirmIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(
    Io.Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    LogicalKeyboardKey.enter,
  );
}

class NewIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(
    Io.Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyN,
  );
}

class EditIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(
    Io.Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyE,
  );
}

class CloseIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(LogicalKeyboardKey.escape);
}

class HelpIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(LogicalKeyboardKey.f1);
}

class SearchIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(
    Io.Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyF,
  );
}

class StudyIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(
    Io.Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyL,
  );
}

class SaveIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(
    Io.Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyS,
  );
}

class BackIntent extends Intent {
  static LogicalKeySet key = LogicalKeySet(
    Io.Platform.isMacOS ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control,
    LogicalKeyboardKey.escape,
  );
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
