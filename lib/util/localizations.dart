import 'dart:ui' as Ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vingo/util/localizations/all.dart';

/// Localizations Utility
///
/// ## Installation
///
/// In `pubspec.yaml` file, add `intl` package or execute `flutter pub add intl`
/// command.
///
/// ```yaml
/// dependencies:
///   flutter_localizations:
///     sdk: flutter
///   intl: ^0.17.0
/// ```
///
/// ## iOS Configuration
///
/// For iOS to see supported locales, you have to update `info.plist` file
/// accordingly:
///
/// ```plist
/// <dict>
///   <key>CFBundleDevelopmentRegion</key>
///   <string>en</string>
///   <key>CFBundleLocalizations</key>
///   <array>
///     <string>en</string>
///     <string>fa</string>
///   </array>
///   <!-- ... -->
/// </dict>
/// ```
///
/// ## Initialization
///
/// In `main.dart` file
///
/// ```dart
/// class MyApp extends StatefulWidget {
///   @override
///   _MyAppState createState() => _MyAppState();
/// }
///
/// class MyAppState extends State<MyApp> {
///   Locale _locale;
///   Locale _deviceLocale;
///
///   void onLocalChanged(String localeName) {
///     Locale locale = Vingo.StorageUtil.toLocale(localeName);
///     if (locale == null) {
///       locale = _deviceLocale;
///     }
///     setState(() {
///       _locale = locale;
///     });
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       localizationsDelegates: [
///         const Vingo.LocalizationsUtilDelegate(),
///         GlobalMaterialLocalizations.delegate,
///         GlobalWidgetsLocalizations.delegate,
///       ],
///       supportedLocales: [
///         const Locale('en', 'US'),
///         const Locale('fa', 'IR'),
///       ],
///       locale: _locale,    /// <<< changes app locale on setState()
///       localeResolutionCallback:
///           (Locale locale, Iterable<Locale> supportedLocales) {
///         if (_deviceLocale == null) {
///           _deviceLocale = locale; // init one time only
///         }
///         _locale = Vingo.StorageUtil.getLocale();
///         if (_locale != null) {
///           return _locale;
///         }
///         for (final supportedLocale in supportedLocales) {
///           if (locale.languageCode == supportedLocale.languageCode) {
///             return locale;
///           }
///         }
///         return supportedLocales.first;
///       },
///       onGenerateTitle: (context) => Vingo.LocalizationsUtil.of(context).title,
///       title: "Vingo",
///       theme: ThemeData.dark(),
///       home: Vingo.HomePage(
///         androidDrawer: Vingo.AndroidDrawer(),
///       ),
///       routes: {
///         ...
///         PageRoutes.settings: (context) => Vingo.SettingsPage(
///               androidDrawer: Vingo.AndroidDrawer(),
///               onLocalChanged: onLocaleChanged,      /// <<< callback
///             ),
///       },
///     );
///   }
/// }
/// ```
class LocalizationsUtil {
  static const String sys = "sys";
  static const List<Locale> supportedLocales = [
    const Locale('en', 'US'), // is used as a fallback
    const Locale('fa', 'IR'),
  ];
  final String localeName;

  /// Constructor
  const LocalizationsUtil(
    this.localeName,
  );

  //----------------------------------------------------------------------------

  static Future<LocalizationsUtil> load(Locale locale) async {
    final String localeName =
        locale.countryCode == null || locale.countryCode!.isEmpty
            ? locale.languageCode
            : locale.toString();
    final String canonicalLocaleName = Intl.canonicalizedLocale(localeName);

    return initializeMessages(canonicalLocaleName).then((_) {
      /// Sets default locale. Overrides `locale` in `Intl.message()` method.
      Intl.defaultLocale = canonicalLocaleName;
      return LocalizationsUtil(canonicalLocaleName);
    });
  }

  static LocalizationsUtil of(BuildContext context) {
    return Localizations.of<LocalizationsUtil>(
        context, LocalizationsUtil)!; // CHECK ???
  }

  /// Check context direction
  static bool isLtr(BuildContext context) {
    return Directionality.of(context) == Ui.TextDirection.ltr;
  }

  /// Check provided string direction
  static bool isLtrByStr(
    String? str, {
    bool isHtml = true, // escape HTML
  }) {
    // Only use the firts character to determine the direciton; otherwise, it
    // determines the direction based on the language which is more dense in
    // the string.
    if (str == null) {
      return true;
    }
    if (str.length > 0) {
      str = str.substring(0, 1);
    }
    return !Bidi.detectRtlDirectionality(str, isHtml: isHtml);
  }

  static List<String> getSupportedLocalesNames() {
    return List<String>.generate(supportedLocales.length, (index) {
      Locale locale = supportedLocales[index];
      return "${locale.languageCode}_${locale.countryCode}"; // e.g "en_US"
    });
  }

  static Map<String, String> getSupportedLocalesOptions(BuildContext context) {
    return {
      sys: of(context).systemDefault,
      "en_US": of(context).english,
      "fa_IR": of(context).persian,
    };
  }

  //----------------------------------------------------------------------------

  /// You cannot access localization data before `MaterialApp` is constructed.
  /// You have to use `onGenerateTitle` property.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return MaterialApp(
  ///     localizationsDelegates: [
  ///       const Vingo.LocalizationsUtilDelegate(),
  ///       GlobalMaterialLocalizations.delegate,
  ///       GlobalWidgetsLocalizations.delegate,
  ///     ],
  ///     supportedLocales: [
  ///       const Locale('en'),
  ///       const Locale('fa'),
  ///     ],
  ///     onGenerateTitle: (context) =>
  ///       Vingo.LocalizationsUtil.of(context).title,
  ///     ...
  ///   );
  /// }
  /// ```
  ///
  /// To access localization data.
  ///
  /// ```dart
  /// Widget title = Text(LocalizationUtil.of(context).title);
  /// ```
  String get title => Intl.message("Vingo", name: "title", locale: localeName);
  String get aboutSoftware => Intl.message("A study helper application.", name: "aboutSoftware");
  String get developedBy => Intl.message("Developed by Morteza Mirbostani", name: "developedBy");
  String get licensedUnder1 => Intl.message("This software is licensed under", name: "licensedUnder1");
  String get licensedUnder2 => Intl.message("GNU GPL v2.0", name: "licensedUnder2");
  String get licensedUnder3 => Intl.message(".", name: "licensedUnder3");
  String get sourceCodeAvail1 => Intl.message("Source code is available on", name: "sourceCodeAvail1");
  String get sourceCodeAvail2 => Intl.message("GitHub", name: "sourceCodeAvail2");
  String get sourceCodeAvail3 => Intl.message(".", name: "sourceCodeAvail3");
  String get systemDefault =>
      Intl.message("System default", name: "systemDefault");
  String get dark => Intl.message("Dark", name: "dark");
  String get light => Intl.message("Light", name: "light");
  String get english => Intl.message("English", name: "english");
  String get persian => Intl.message("Persian", name: "persian");
  String get small => Intl.message("Small", name: "small");
  String get medium => Intl.message("Medium", name: "medium");
  String get large => Intl.message("Large", name: "large");
  String get ok => Intl.message("OK", name: "ok");
  String get cancel => Intl.message("Cancel", name: "cancel");
  String get language => Intl.message("Language", name: "language");
  String get theme => Intl.message("Theme", name: "theme");
  String get fontSize => Intl.message("Font Size", name: "fontSize");
  String get home => Intl.message("Home", name: "home");
  String get settings => Intl.message("Settings", name: "settings");
}

///////////////////////////////////////////////////////////////////////////////

class LocalizationsUtilDelegate
    extends LocalizationsDelegate<LocalizationsUtil> {
  const LocalizationsUtilDelegate();

  @override
  bool isSupported(Locale locale) {
    List<String> supportedLanguageCodes = List<String>.generate(
        LocalizationsUtil.supportedLocales.length,
        (index) => LocalizationsUtil.supportedLocales[index].languageCode);
    return supportedLanguageCodes.contains(locale.languageCode);
  }

  @override
  Future<LocalizationsUtil> load(Locale locale) =>
      LocalizationsUtil.load(locale);

  @override
  bool shouldReload(LocalizationsUtilDelegate old) => false;
}
