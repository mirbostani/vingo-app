import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; // kIsWeb

class Platform extends StatefulWidget {
  final WidgetBuilder defaultBuilder;
  final WidgetBuilder? webBuilder;
  final WidgetBuilder? androidBuilder;
  final WidgetBuilder? iosBuilder;
  final WidgetBuilder? linuxBuilder;
  final WidgetBuilder? windowsBuilder;
  final WidgetBuilder? macosBuilder;

  const Platform({
    Key? key,
    required this.defaultBuilder,
    this.androidBuilder,
    this.webBuilder,
    this.iosBuilder,
    this.linuxBuilder,
    this.windowsBuilder,
    this.macosBuilder,
  }) : super(key: key);

  @override
  _PlatformState createState() => _PlatformState();
}

class _PlatformState extends State<Platform> {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return (widget.webBuilder ?? widget.defaultBuilder)(context);
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return (widget.androidBuilder ?? widget.defaultBuilder)(context);
      case TargetPlatform.iOS:
        return (widget.iosBuilder ?? widget.defaultBuilder)(context);
      case TargetPlatform.linux:
        return (widget.linuxBuilder ?? widget.defaultBuilder)(context);
      case TargetPlatform.windows:
        return (widget.windowsBuilder ?? widget.defaultBuilder)(context);
      case TargetPlatform.macOS:
        return (widget.macosBuilder ?? widget.defaultBuilder)(context);
      default:
        assert(false, "Unknown platform: $defaultTargetPlatform");
        return Container();
    }
  }
}
