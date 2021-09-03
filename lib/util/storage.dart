import 'dart:io' as Io;
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vingo/util/util.dart' as Vingo;

class StorageUtil {
  /// Shared Preferences supports Android/iOS/Web
  ///
  /// Windows: C:/Users//AppData/Local/vingo
  /// MacOS: ~/Library/Application Support/vingo
  /// Linux: ~/.local/share/vingo
  ///
  /// @see https://pub.dev/packages/shared_preferences
  static late SharedPreferences sharedPrefs;

  /// Keys
  static const keyLocaleName = "locale_name";
  static const keyTheme = "theme";
  static const keyTextScaleFactor = "text_scale_factor";

  /// Class initialization
  ///
  /// ```dart
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await StorageUtil.init();
  ///   runApp(MyApp());
  /// }
  /// ```
  static Future<void> init() async {
    if (kIsWeb ||
        Io.Platform.isAndroid ||
        Io.Platform.isIOS ||
        Io.Platform.isLinux ||
        Io.Platform.isWindows ||
        Io.Platform.isMacOS) {
      sharedPrefs = await SharedPreferences.getInstance();
    } else {
      assert(false, 'StorageUtil does not support $defaultTargetPlatform');
    }
  }

  //----------------------------------------------------------------------------

  /// Store a key/value pair in plain text format.
  static Future<void> setString({
    required String key,
    required String value,
  }) async {
    if (kIsWeb ||
        Io.Platform.isAndroid ||
        Io.Platform.isIOS ||
        Io.Platform.isLinux ||
        Io.Platform.isWindows ||
        Io.Platform.isMacOS) {
      await sharedPrefs.setString(key, value);
    }
  }

  /// Retrieve a key/value pair which is stored as a plain text.
  static String? getStringSync({required String key}) {
    if (kIsWeb ||
        Io.Platform.isAndroid ||
        Io.Platform.isIOS ||
        Io.Platform.isLinux ||
        Io.Platform.isWindows ||
        Io.Platform.isMacOS) {
      return sharedPrefs.getString(key);
    }
    return null;
  }

  /// Retrieve a key/value pair which is stored as a plain text.
  static Future<String?> getString({required String key}) async {
    if (kIsWeb ||
        Io.Platform.isAndroid ||
        Io.Platform.isIOS ||
        Io.Platform.isLinux ||
        Io.Platform.isWindows ||
        Io.Platform.isMacOS) {
      return sharedPrefs.getString(key);
    }
    return null;
  }

  //----------------------------------------------------------------------------

  /// Set app locale name.
  /// @param locale - e.g. "en_US", "fa_IR", etc.
  static Future<String> setLocaleName(String localeName) async {
    if (!Vingo.LocalizationsUtil.getSupportedLocalesNames()
        .contains(localeName)) {
      localeName = Vingo.LocalizationsUtil.sys;
    }
    await setString(key: keyLocaleName, value: localeName);
    return localeName;
  }

  /// Get app locale name stored in the settings.
  /// @return e.g. "en_US", "fa_IR", etc.
  static String getLocaleName() {
    String? localeName = getStringSync(key: keyLocaleName);
    if (!Vingo.LocalizationsUtil.getSupportedLocalesNames()
        .contains(localeName)) {
      return Vingo.LocalizationsUtil.sys;
    }
    return localeName!;
  }

  /// Get locale based on the provided locale name, e.g. "en_US".
  ///
  /// ```dart
  /// Locale locale = StorageUtil.toLocale(StorageUtil.getLocaleName());
  /// ```
  static Locale? toLocale(String? localeName) {
    if (localeName == null || localeName == Vingo.LocalizationsUtil.sys) {
      Vingo.PlatformUtil.log('Use device locale instead of "$localeName"');
      return null;
    }
    String languageCode = localeName.substring(0, 2); // e.g. "en"
    String countryCode = localeName.substring(3); // e.g. "US"
    return Locale(languageCode, countryCode);
  }

  /// Get locale stored in shared preferences.
  static Locale? getLocale() {
    return toLocale(getLocaleName());
  }

  //----------------------------------------------------------------------------

  /// Store app theme.
  static Future<String> setTheme(String theme) async {
    if (!Vingo.ThemeUtil.supportedThemes.contains(theme)) {
      theme = Vingo.ThemeUtil.sys;
    }
    await setString(key: keyTheme, value: theme);
    return theme;
  }

  /// Retrieve app theme.
  static String getTheme() {
    String? theme = getStringSync(key: keyTheme);
    if (!Vingo.ThemeUtil.supportedThemes.contains(theme)) {
      return Vingo.ThemeUtil.sys;
    }
    return theme!;
  }

  //----------------------------------------------------------------------------

  static Future<double> setTextScaleFactor(double textScaleFactor) async {
    if (!Vingo.ThemeUtil.textScaleFactors.contains(textScaleFactor)) {
      textScaleFactor = 1.0;
    }
    await setString(key: keyTextScaleFactor, value: textScaleFactor.toString());
    return textScaleFactor;
  }

  static double getTextScaleFactor() {
    String value = getStringSync(key: keyTextScaleFactor) ?? "1.0";
    double textScaleFactor = double.tryParse(value) ?? 1.0;
    if (!Vingo.ThemeUtil.textScaleFactors.contains(textScaleFactor)) {
      textScaleFactor = 1.0;
    }
    return textScaleFactor;
  }
}
