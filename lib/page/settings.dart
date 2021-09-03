import 'dart:io' as Io;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/services.dart';
import 'package:vingo/util/util.dart' as Vingo;
import 'package:vingo/widget/widget.dart' as Vingo;

class SettingsPage extends StatefulWidget {
  static const String route = '/settings';
  static const String title = 'Settings';
  static const Icon icon = Icon(Icons.settings);
  final Widget? androidDrawer;
  final void Function(String)? onLocalChanged;
  final void Function(String)? onThemeChanged;
  final void Function(double)? onTextScaleFactorChanged;

  const SettingsPage({
    Key? key,
    this.androidDrawer,
    this.onLocalChanged,
    this.onThemeChanged,
    this.onTextScaleFactorChanged,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _localName;
  late String _theme;
  late double _textScaleFactor;

  @override
  void initState() {
    super.initState();
    _localName = Vingo.StorageUtil.getLocaleName();
    _theme = Vingo.StorageUtil.getTheme();
    _textScaleFactor = Vingo.StorageUtil.getTextScaleFactor();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget bodyBuilder(BuildContext context) {
    return ListView(
      children: [
        //----------------------------------------------------------------------
        // Language
        Container(
          color: Vingo.ThemeUtil.of(context).formBackgroundColor,
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  height: double.infinity,
                  child: Icon(Icons.language),
                ),
                title: Text(
                  Vingo.LocalizationsUtil.of(context).language,
                ),
                trailing: Text(
                  Vingo.LocalizationsUtil.getSupportedLocalesOptions(
                          context)[_localName] ??
                      "",
                  style: TextStyle(
                    color: Vingo.ThemeUtil.of(context).textMutedColor,
                  ),
                ),
                onTap: () async {
                  String? localeName = await Vingo.RadioDialog.show(
                    context: context,
                    title: Vingo.LocalizationsUtil.of(context).language,
                    currentOptionKey: _localName,
                    options: Vingo.LocalizationsUtil.getSupportedLocalesOptions(
                        context),
                  );
                  if (localeName != null) {
                    Vingo.StorageUtil.setLocaleName(localeName).then((value) {
                      _localName = value;
                      if (widget.onLocalChanged != null) {
                        widget.onLocalChanged!(value);
                      }
                    });
                  }
                },
              ),
            ],
          ),
        ),
        //----------------------------------------------------------------------
        Container(
          height: Vingo.ThemeUtil.padding,
        ),
        //----------------------------------------------------------------------
        // Theme
        Container(
          color: Vingo.ThemeUtil.of(context).formBackgroundColor,
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  height: double.infinity,
                  child: Icon(Icons.brightness_medium),
                ),
                title: Text(
                  Vingo.LocalizationsUtil.of(context).theme,
                ),
                trailing: Text(
                  Vingo.ThemeUtil.getSupportedThemesOptions(context)[_theme] ??
                      "",
                  style: TextStyle(
                    color: Vingo.ThemeUtil.of(context).textMutedColor,
                  ),
                ),
                onTap: () async {
                  String? theme = await Vingo.RadioDialog.show(
                    context: context,
                    title: Vingo.LocalizationsUtil.of(context).theme,
                    currentOptionKey: _theme,
                    options: Vingo.ThemeUtil.getSupportedThemesOptions(context),
                  );
                  if (theme != null) {
                    Vingo.StorageUtil.setTheme(theme).then((value) {
                      _theme = value;
                      if (widget.onThemeChanged != null) {
                        widget.onThemeChanged!(value);
                      }
                    });
                  }
                },
              )
            ],
          ),
        ),
        //----------------------------------------------------------------------
        // Text Scale Factor
        Container(
          color: Vingo.ThemeUtil.of(context).formBackgroundColor,
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  height: double.infinity,
                  child: Icon(Icons.format_size),
                ),
                title: Text(
                  Vingo.LocalizationsUtil.of(context).fontSize,
                ),
                trailing: Text(
                  Vingo.ThemeUtil.getSupportedTextScaleFactorsOptions(
                          context)[_textScaleFactor.toString()] ??
                      "",
                  style: TextStyle(
                    color: Vingo.ThemeUtil.of(context).textMutedColor,
                  ),
                ),
                onTap: () async {
                  String? textScaleFactor = await Vingo.RadioDialog.show(
                    context: context,
                    title: Vingo.LocalizationsUtil.of(context).fontSize,
                    currentOptionKey: _textScaleFactor.toString(),
                    options:
                        Vingo.ThemeUtil.getSupportedTextScaleFactorsOptions(
                            context),
                  );
                  if (textScaleFactor != null) {
                    Vingo.StorageUtil.setTextScaleFactor(
                            double.tryParse(textScaleFactor) ?? 1.0)
                        .then((value) {
                      _textScaleFactor = value;
                      if (widget.onTextScaleFactorChanged != null) {
                        widget.onTextScaleFactorChanged!(value);
                      }
                    });
                  }
                },
              )
            ],
          ),
        ),
        //----------------------------------------------------------------------
      ],
    );
  }

  Widget androidBuilder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Vingo.LocalizationsUtil.of(context).settings,
          style: TextStyle(
            color: Vingo.ThemeUtil.of(context).appBarTitleTextColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [],
      ),
      drawer: widget.androidDrawer,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            // statusBarColor: Colors.white,
            // systemNavigationBarColor: Colors.white,
            ),
        child: bodyBuilder(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Vingo.Platform(
      defaultBuilder: androidBuilder,
    );
  }
}
