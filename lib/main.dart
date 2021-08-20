import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vingo/page/home.dart' as Vingo;
import 'package:vingo/page/settings.dart' as Vingo;
import 'package:vingo/widget/android_drawer.dart' as Vingo;
import 'package:vingo/util/localizations.dart' as Vingo;
import 'package:vingo/util/theme.dart' as Vingo;
import 'package:vingo/util/storage.dart' as Vingo;
import 'package:vingo/util/sqlite.dart' as Vingo;
import 'package:vingo/util/platform.dart' as Vingo;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Vingo.StorageUtil.init();
  await Vingo.SqliteUtil.getInstance().open();

  runApp(
    new VingoApp(),
  );
}

////////////////////////////////////////////////////////////////////////////////

class PageRoutes {
  static const String home = Vingo.HomePage.route;
  static const String settings = Vingo.SettingsPage.route;
}

////////////////////////////////////////////////////////////////////////////////

class VingoApp extends StatefulWidget {
  @override
  _VingoAppState createState() => _VingoAppState();
}

class _VingoAppState extends State<VingoApp> {
  Locale? _locale;
  Locale? _deviceLocale;
  late double _textScaleFactor;
  late String _theme;

  @override
  void initState() {
    super.initState();
    _theme = Vingo.StorageUtil.getTheme();
    _textScaleFactor = Vingo.StorageUtil.getTextScaleFactor();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: [
          const Vingo.LocalizationsUtilDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: Vingo.LocalizationsUtil.supportedLocales,
        locale: _locale,
        localeResolutionCallback:
            (Locale? locale, Iterable<Locale> supportedLocales) {
          if (_deviceLocale == null) {
            _deviceLocale =
                locale; // system default locale initialized one time
          }
          _locale = Vingo.StorageUtil.getLocale();
          if (_locale != null) {
            return _locale;
          }
          for (final supportedLocale in supportedLocales) {
            if (locale?.languageCode == supportedLocale.languageCode) {
              return locale;
            }
          }
          return supportedLocales.first;
        },
        onGenerateTitle: (context) => Vingo.LocalizationsUtil.of(context).title,
        title: Vingo.PlatformUtil.appName,
        themeMode: Vingo.ThemeUtil.getThemeMode(_theme),
        theme: Vingo.ThemeUtil.getLightTheme(),
        darkTheme: Vingo.ThemeUtil.getDarkTheme(),
        builder: (BuildContext context, Widget? child) {
          final MediaQueryData data = MediaQuery.of(context);
          return MediaQuery(
            data: data.copyWith(
              textScaleFactor: _textScaleFactor,
            ),
            child: child ?? Container(),
          );
        },
        home: Vingo.HomePage(
          androidDrawer: Vingo.AndroidDrawer(),
        ),
        routes: {
          PageRoutes.home: (context) => Vingo.HomePage(
                androidDrawer: Vingo.AndroidDrawer(),
              ),
          PageRoutes.settings: (context) => Vingo.SettingsPage(
                androidDrawer: Vingo.AndroidDrawer(),
                onLocalChanged: (String localeName) {
                  Locale? locale = Vingo.StorageUtil.toLocale(localeName);
                  if (locale == null) {
                    locale = _deviceLocale;
                  }
                  setState(() {
                    _locale = locale;
                  });
                },
                onThemeChanged: (String theme) {
                  setState(() {
                    _theme = theme;
                  });
                },
                onTextScaleFactorChanged: (double textScaleFactor) {
                  setState(() {
                    _textScaleFactor = textScaleFactor;
                  });
                },
              ),
        });
  }
}
