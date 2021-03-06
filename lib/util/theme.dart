import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:vingo/util/util.dart' as Vingo;

class ThemeUtil {
  static const String sys = "sys";
  static const List<String> supportedThemes = ["light", "dark"];
  static const List<double> textScaleFactors = [1.0, 1.15, 1.30];
  static Map<BuildContext, ThemeUtil> instances = <BuildContext, ThemeUtil>{};
  BuildContext? _context;

  //----------------------------------------------------------------------------

  static const double borderRadius = 8.0;
  static const double borderRadiusQuarter = borderRadius * 0.25;
  static const double borderRadiusHalf = borderRadius * 0.5;
  static const double borderRadiusDouble = borderRadius * 2.0;

  static const double padding = 12.0;
  static const double paddingQuarter = padding * 0.25;
  static const double paddingHalf = padding * 0.5;
  static const double paddingDouble = padding * 2.0;

  static const double elevation = 4.0;
  static const double elevationHalf = elevation * 0.5;
  static const double elevationQuarter = elevation * 0.25;

  static const double textFontSizeSmall = 12.0;
  static const double textFontSize = 16.0;
  static const double textFontSizeMedium = 20.0;
  static const double textFontSizeLarge = 32.0;
  static const List<double> headingFontSize = <double>[
    textFontSizeLarge, // 32.0
    28.0,
    24.0,
    textFontSizeMedium, // 20.0
    18.0,
    textFontSize, // 16.0
  ];

  static const double fieldHeight = 40.0;
  static const double fabIconSizeTiny = 12.0;
  static const double fabIconSizeSmall = 24.0;
  static const double fabIconSize = 28.0;
  static const double fabButtonHeight = 48.0;

  static const double iconSizeSmall = 18.0;
  static const double iconSizeSmallSplashRadius = 24.0;

  //----------------------------------------------------------------------------

  // Raw Colors
  static Color whiteColor = Colors.white;
  static Color whiteLightColor = Colors.grey[100]!;
  static Color blackColor = Color(0xFF333230);
  static Color blackLightColor = Colors.grey[700]!;
  static Color tealColor = Color(0xFF009898);
  static Color tealColor10 = Color(0xFFE5F4F4);
  static Color tealLightColor = Colors.tealAccent;
  static Color tealBackgroundColor = Color(0xFF98D4D4);
  static Color redColor = Color(0xFFFF553E);
  static Color redLightColor = Colors.red[100]!;

  // Primary, Accent, Secondary Colors
  static Color lightPrimaryColor = tealColor;
  static Color lightPrimaryColor10 = tealColor.withAlpha(10); // tealColor10
  static Color darkPrimaryColor = tealColor;
  static Color lightPrimaryAccentColor = tealLightColor;
  static Color darkPrimaryAccentColor = tealLightColor;
  static Color lightSecondaryColor = redColor;
  static Color darkSecondaryColor = redColor;
  static Color lightSecondaryAccentColor = redLightColor;
  static Color darkSecondaryAccentColor = redLightColor;

  // Text Colors
  static Color lightTextColor = Colors.black54;
  static Color darkTextColor = Colors.white70;
  static Color lightTextPrimaryColor = lightPrimaryColor;
  static Color darkTextPrimaryColor = darkTextColor; // darkPrimaryAccentColor;
  static Color lightTextMutedColor = Colors.grey[600]!;
  static Color darkTextMutedColor = Colors.grey[400]!;
  static Color lightTagSelectedTextColor = lightPrimaryColor;
  static Color darkTagSelectedTextColor = darkPrimaryAccentColor;

  // SnackBar Colors
  static Color lightSnackBarFormBackgroundColor = Colors.grey[800]!;
  static Color darkSnackBarFormBackgroundColor = whiteLightColor;
  static Color lightSnackBarTextColor = Colors.white70;
  static Color darkSnackBarTextColor = Colors.black54;

  // Icon Colors
  static Color lightIconColor = Colors.black;
  static Color darkIconColor = Colors.white;
  static Color lightIconMutedColor = Colors.grey.shade400;
  static Color darkIconMutedColor = Colors.grey.shade400;

  // Background Colors
  static Color lightBackgroundColor = whiteColor;
  static Color darkBackgroundColor = blackColor;
  static Color lightFormBackgroundColor = whiteLightColor;
  static Color darkFormBackgroundColor = Colors.grey[800]!;
  static Color lightDialogBackgroundColor = whiteColor;
  static Color darkDialogBackgroundColor = Colors.grey[800]!;

  // AppBar Colors
  static Color lightAppBarBackgroundColor = Colors.white;
  static Color darkAppBarBackgroundColor = darkBackgroundColor;
  static Color lightAppBarNavIconColor = Colors.black;
  static Color darkAppBarNavIconColor = Colors.white;
  static Color lightAppBarTitleTextColor = Colors.black;
  static Color darkAppBarTitleTextColor = Colors.white;

  // Radio Colors
  static Color lightRadioActiveColor = lightPrimaryColor;
  static Color darkRadioActiveColor = darkPrimaryAccentColor;

  // FAB Colors
  static Color lightFabBackgroundColor = lightPrimaryColor;
  static Color darkFabBackgroundColor = darkPrimaryColor;
  static Color lightFabIconColor = Colors.white;
  static Color darkFabIconColor = Colors.white;

  // FAB Secondary Colors
  static Color lightFabSecondaryBackgroundColor = lightSecondaryColor;
  static Color darkFabSecondaryBackgroundColor = darkSecondaryColor;
  static Color ligthFabSecondaryIconColor = Colors.white;
  static Color darkFabSecondaryIconColor = Colors.white;

  // FAB Alternative Colors
  static Color lightFabAltBackgroundColor = Colors.grey[50]!;
  static Color darkFabAltBackgroundColor = Colors.grey[700]!;
  static Color lightFabAltIconColor = lightPrimaryColor;
  static Color darkFabAltIconColor = darkPrimaryAccentColor;

  // Flat Button Primary Colors
  static Color lightButtonPrimaryColor = lightPrimaryColor;
  static Color darkButtonPrimaryColor = darkPrimaryColor;
  static Color lightButtonPrimaryTextColor = Colors.white;
  static Color darkButtonPrimaryTextColor = Colors.white;
  static Color lightButtonPrimaryBoxShadowColor = Colors.black.withOpacity(0.1);
  static Color darkButtonPrimaryBoxShadowColor = Colors.black.withOpacity(0.1);
  static Color lightButtonPrimaryProgressIndicatorBackgroundColor =
      lightPrimaryColor;
  static Color darkButtonPrimaryProgressIndicatorBackgroundColor =
      darkPrimaryColor;
  static Color lightButtonPrimaryProgressIndicatorValueColor = Colors.white;
  static Color darkButtonPrimaryProgressIndicatorValueColor =
      darkPrimaryAccentColor;

  // Flat Button Secondary Colors
  static Color lightButtonSecondaryColor = lightSecondaryColor;
  static Color darkButtonSecondaryColor = darkSecondaryColor;
  static Color lightButtonSecondaryTextColor = Colors.white;
  static Color darkButtonSecondaryTextColor = Colors.white;
  static Color lightButtonSecondaryBoxShadowColor =
      Colors.black.withOpacity(0.1);
  static Color darkButtonSecondaryBoxShadowColor =
      Colors.black.withOpacity(0.1);
  static Color lightButtonSecondaryProgressIndicatorBackgroundColor =
      lightSecondaryColor;
  static Color darkButtonSecondaryProgressIndicatorBackgroundColor =
      darkSecondaryColor;
  static Color lightButtonSecondaryProgressIndicatorValueColor =
      lightSecondaryAccentColor;
  static Color darkButtonSecondaryProgressIndicatorValueColor =
      darkSecondaryAccentColor;

  // Flat Button Again Colors
  static Color lightButtonAgainColor = lightSecondaryColor;
  static Color darkButtonAgainColor = darkSecondaryColor;
  static Color lightButtonAgainTextColor = Colors.white;
  static Color darkButtonAgainTextColor = Colors.white;

  // Flat Button Hard Colors
  static Color lightButtonHardColor = const Color(0xFFAA6B5C);
  static Color darkButtonHardColor = const Color(0xFFAA6B5C);
  static Color lightButtonHardTextColor = Colors.white;
  static Color darkButtonHardTextColor = Colors.white;

  // Flat Button Good Colors
  static Color lightButtonGoodColor = const Color(0xFF55827A);
  static Color darkButtonGoodColor = const Color(0xFF55827A);
  static Color lightButtonGoodTextColor = Colors.white;
  static Color darkButtonGoodTextColor = Colors.white;

  // Flat Button Easy Colors
  static Color lightButtonEasyColor = lightPrimaryColor;
  static Color darkButtonEasyColor = darkPrimaryColor;
  static Color lightButtonEasyTextColor = Colors.white;
  static Color darkButtonEasyTextColor = Colors.white;

  // Flat Button Colors
  static Color lightButtonTextColor = lightTextPrimaryColor;
  static Color darkButtonTextColor = darkTextPrimaryColor;
  // static Color lightButtonMutedColor = lightTextMutedColor;
  // static Color darkButtonMutedColor = darkTextMutedColor;

  // Input Colors
  static Color lightInputCursorColor = tealColor;
  static Color darkInputCursorColor = Colors.white;
  static Color lightInputFillColor = whiteColor; // lightPrimaryColor10;
  static Color darkInputFillColor = Colors.grey[800]!;
  static Color lightInputFocusColor = Colors.white;
  static Color darkInputFocusColor = Colors.grey[700]!;
  static Color lightInputHoverColor = lightPrimaryColor.withAlpha(10);
  static Color darkInputHoverColor = Colors.grey[700]!;
  static Color lightInputBorderColor = lightPrimaryColor.withAlpha(30);
  static Color darkInputBorderColor = Colors.transparent;
  static Color lightInputFocusedBorderColor = lightPrimaryColor.withAlpha(150);
  static Color darkInputFocusedBorderColor = lightPrimaryColor.withAlpha(150);
  static Color lightInputBoxShadowColor = Colors.grey.withOpacity(0.1);
  static Color darkInputBoxShadowColor = Colors.black.withOpacity(0.1);

  // Progress Indicator Colors
  static Color lightProgressIndicatorBackgroundColor = Colors.grey[50]!;
  static Color darkProgressIndicatorBackgroundColor = Colors.grey[700]!;
  static Color lightProgressIndicatorValueColor = lightPrimaryColor;
  static Color darkProgressIndicatorValueColor = darkPrimaryAccentColor;

  // Refresh Indicator Colors
  static Color lightRefreshIndicatorBackgroundColor = whiteLightColor;
  static Color darkRefreshIndicatorBackgroundColor = blackLightColor;
  static Color lightRefreshIndicatorColor = lightPrimaryColor;
  static Color darkRefreshIndicatorColor = darkPrimaryAccentColor;

  static Color lightDividerColor = Colors.grey.shade200;
  static Color darkDividerColor = Colors.grey.shade800;
  static Color lightDividerSelectedColor = lightPrimaryColor.withAlpha(30);
  static Color darkDividerSelectedColor = darkPrimaryColor.withAlpha(30);

  // ListView Colors
  static Color lightListViewBackgroundColor = Colors.grey[200]!;
  static Color darkListViewBackgroundColor = Colors.grey[800]!;
  static Color lightListViewPrimaryTextColor = lightPrimaryColor;
  static Color darkListViewPrimaryTextColor = darkPrimaryAccentColor;
  static Color lightListViewMutedTextColor = lightTextMutedColor;
  static Color darkListViewMutedTextColor = darkTextMutedColor;

  // ListTile
  static Color lightListTileTextColor = lightPrimaryColor;
  static Color darkListTileTextColor = darkPrimaryColor;
  static Color lightListTileBackgroundColor = lightPrimaryColor.withAlpha(30);
  static Color darkListTileBackgroundColor = darkPrimaryColor.withAlpha(30);

  // Checkbox
  static Color lightCheckboxActiveColor = lightPrimaryColor;
  static Color darkCheckboxActiveColor = darkPrimaryColor;

  // Switch
  static Color lightSwitchActiveColor = lightPrimaryColor;
  static Color darkSwitchActiveColor = darkPrimaryColor;

  // Stats
  static Color lightStatTotalColor = Colors.grey[500]!;
  static Color darkStatTotalColor = Colors.grey[400]!;
  static Color lightStatNewColor = lightPrimaryColor; // Colors.blue[600]
  static Color darkStatNewColor = darkPrimaryColor; // Colors.lightBlue[600]
  static Color lightStatReviewColor = Colors.yellow[600]!; // Colors.green[400]
  static Color darkStatReviewColor = Colors.yellow[600]!;
  static Color lightStatLearningColor = lightSecondaryColor; // Colors.red[400]
  static Color darkStatLearningColor = darkSecondaryColor; // Colors.red[600]

  // Fonts
  static String font = "Roboto";
  static String codeFont = "RobotoMono";

  //----------------------------------------------------------------------------

  static ThemeUtil of(BuildContext context) {
    if (instances[context] == null) {
      instances[context] = new ThemeUtil();
    }
    instances[context]!._context = context;
    return instances[context]!;
  }

  static Map<String, String> getSupportedThemesOptions(BuildContext context) {
    return {
      sys: Vingo.LocalizationsUtil.of(context).systemDefault,
      "light": Vingo.LocalizationsUtil.of(context).light,
      "dark": Vingo.LocalizationsUtil.of(context).dark,
    };
  }

  static Map<String, String> getSupportedTextScaleFactorsOptions(
      BuildContext context) {
    return {
      textScaleFactors[0].toString(): Vingo.LocalizationsUtil.of(context).small,
      textScaleFactors[1].toString():
          Vingo.LocalizationsUtil.of(context).medium,
      textScaleFactors[2].toString(): Vingo.LocalizationsUtil.of(context).large,
    };
  }

  /// Set theme in MaterialApp class.
  ///
  /// ```dart
  /// class MyApp extends StatefulWidget {
  ///   @override
  ///   _MyAppState createState() => _MyAppState();
  /// }
  ///
  /// class _MyAppState extends State<MyApp> {
  ///   String _theme;
  ///
  ///   void onThemeChanged(String theme) {
  ///     setState(() {
  ///       _theme = theme;
  ///     });
  ///   }
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return MaterialApp(
  ///       title: "Vingo",
  ///       themeMode: Vingo.ThemeUtil.getThemeMode(_theme), // <<< set mode
  ///       theme: Vingo.ThemeUtil.lightTheme, // <<< provide light theme
  ///       darkTheme: Vingo.ThemeUtil.darkTheme, // <<< provide dark theme
  ///       home: Vingo.HomePage(
  ///         androidDrawer: Vingo.AndroidDrawer(),
  ///       ),
  ///       routes: {
  ///         ...
  ///         PageRoutes.settings: (context) => Vingo.SettingsPage(
  ///               androidDrawer: Vingo.AndroidDrawer(),
  ///               onLocalChanged: onLocaleChanged,
  ///               onThemeChanged: onThemeChanged, // <<< callback
  ///             ),
  ///       },
  ///     );
  ///   }
  /// }
  /// ```
  static ThemeMode getThemeMode(String? theme) {
    switch (theme) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      case sys:
      default:
        return ThemeMode.system;
    }
  }

  bool isDark() {
    if (_context != null &&
        Theme.of(_context!).brightness == ThemeData.dark().brightness) {
      return true;
    }
    return false;
  }

  Color getColor(Color lightThemeColor, Color darkThemeColor) {
    if (_context != null &&
        Theme.of(_context!).brightness == ThemeData.dark().brightness) {
      return darkThemeColor;
    }
    return lightThemeColor;
  }

  //----------------------------------------------------------------------------

  /// Returns a custom dark theme
  static ThemeData getDarkTheme() {
    ThemeData theme = ThemeData(
      brightness: Brightness.dark,
      primaryColor: darkPrimaryColor,
      accentColor: darkPrimaryAccentColor,
      // colorScheme: ColorScheme(
      //   primary: darkPrimaryColor,
      //   secondary: darkPrimaryAccentColor,
      // ),
      scaffoldBackgroundColor: darkBackgroundColor,
      fontFamily: font,
      toggleableActiveColor: darkRadioActiveColor,
      // hoverColor: Colors.transparent, // IconButton or ListTile hoverColor
      iconTheme: IconThemeData(
        color: darkIconColor,
        size: 20.0 * Vingo.StorageUtil.getTextScaleFactor(), // default: 24
      ),
      appBarTheme: AppBarTheme(
        color: darkAppBarBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: darkAppBarNavIconColor,
          size: 20.0 * Vingo.StorageUtil.getTextScaleFactor(), // default: 24
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(darkButtonPrimaryColor),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: darkButtonTextColor,
        ),
      ),
    );
    return theme;
  }

  /// Returns a custom light theme
  static ThemeData getLightTheme() {
    ThemeData theme = ThemeData(
      brightness: Brightness.light,
      primaryColor: lightPrimaryColor,
      accentColor: lightPrimaryAccentColor,
      // colorScheme: ColorScheme(
      //   primary: lightPrimaryColor,
      //   secondary: lightPrimaryAccentColor,
      // ),
      scaffoldBackgroundColor: lightBackgroundColor,
      fontFamily: font,
      toggleableActiveColor: lightRadioActiveColor,
      // hoverColor: Colors.transparent, // IconButton or ListTile hoverColor
      iconTheme: IconThemeData(
        color: lightIconColor,
        size: 20.0 * Vingo.StorageUtil.getTextScaleFactor(), // default: 24
      ),
      appBarTheme: AppBarTheme(
        color: lightAppBarBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: lightAppBarNavIconColor,
          size: 20.0 * Vingo.StorageUtil.getTextScaleFactor(), // default: 24
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.all(lightButtonPrimaryColor),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          primary: lightButtonTextColor,
        ),
      ),
    );
    return theme;
  }

  //----------------------------------------------------------------------------

  // General Colors

  Color get backgroundColor => getColor(
        lightBackgroundColor,
        darkBackgroundColor,
      );
  Color get formBackgroundColor => getColor(
        lightFormBackgroundColor,
        darkFormBackgroundColor,
      );
  Color get dialogBackgroundColor => getColor(
        lightDialogBackgroundColor,
        darkDialogBackgroundColor,
      );

  // ListView Colors

  Color get listViewBackgroundColor => getColor(
        lightListViewBackgroundColor,
        darkListViewBackgroundColor,
      );
  Color get listViewPrimaryTextColor => getColor(
        lightListViewPrimaryTextColor,
        darkListViewPrimaryTextColor,
      );
  Color get listViewMutedTextColor => getColor(
        lightListViewMutedTextColor,
        darkListViewMutedTextColor,
      );

  // ListTile Colors

  Color get listTileTextColor => getColor(
        lightListTileTextColor,
        darkListTileTextColor,
      );
  Color get listTileBackgroundColor => getColor(
        lightListTileBackgroundColor,
        darkListTileBackgroundColor,
      );

  // AppBar Colors

  Color get appBarTitleTextColor => getColor(
        lightAppBarTitleTextColor,
        darkAppBarTitleTextColor,
      );
  Color get appBarBackgroundColor => getColor(
        lightAppBarBackgroundColor,
        darkAppBarBackgroundColor,
      );

  // Text Colors

  Color get textPrimaryColor => getColor(
        lightTextPrimaryColor,
        darkTextPrimaryColor,
      );
  Color get textMutedColor => getColor(
        lightTextMutedColor,
        darkTextMutedColor,
      );

  // Icon Colors

  Color get iconColor => getColor(
        lightIconColor,
        darkIconColor,
      );
  Color get iconColorReversed => getColor(
        darkIconColor,
        lightIconColor,
      );
  Color get iconMutedColor => getColor(
        lightIconMutedColor,
        darkIconMutedColor,
      );

  // Indicator Colors

  Color get refreshIndicatorBackgroundColor => getColor(
        lightRefreshIndicatorBackgroundColor,
        darkRefreshIndicatorBackgroundColor,
      );
  Color get refreshIndicatorColor => getColor(
        lightRefreshIndicatorColor,
        darkRefreshIndicatorColor,
      );
  Color get progressIndicatorBackgroundColor => getColor(
        lightProgressIndicatorBackgroundColor,
        darkProgressIndicatorBackgroundColor,
      );
  Color get progressIndicatorValueColor => getColor(
        lightProgressIndicatorValueColor,
        darkProgressIndicatorValueColor,
      );
  Color get progressIndicatorBackgroundColorReversed => getColor(
        darkProgressIndicatorBackgroundColor,
        lightProgressIndicatorBackgroundColor,
      );
  Color get progressIndicatorValueColorReversed => getColor(
        darkProgressIndicatorValueColor,
        lightProgressIndicatorValueColor,
      );

  // Divider Colors

  Color get dividerColor => getColor(
        lightDividerColor,
        darkDividerColor,
      );
  Color get dividerSelectedColor => getColor(
        lightDividerSelectedColor,
        darkDividerSelectedColor,
      );

  // FAB Colors

  Color get fabBackgroundColor => getColor(
        lightFabBackgroundColor,
        darkFabBackgroundColor,
      );

  Color get fabIconColor => getColor(
        lightFabIconColor,
        darkFabIconColor,
      );

  Color get fabSecondaryBackgroundColor => getColor(
        lightFabSecondaryBackgroundColor,
        darkFabSecondaryBackgroundColor,
      );
  Color get fabSecondaryIconColor => getColor(
        ligthFabSecondaryIconColor,
        darkFabSecondaryIconColor,
      );

  Color get fabAltBackgroundColor => getColor(
        lightFabAltBackgroundColor,
        darkFabAltBackgroundColor,
      );
  Color get fabAltIconColor => getColor(
        lightFabAltIconColor,
        darkFabAltIconColor,
      );

  // Button Colors

  Color get buttonTextColor => getColor(
        lightButtonTextColor,
        darkButtonTextColor,
      );
  Color get buttonPrimaryColor => getColor(
        lightButtonPrimaryColor,
        darkButtonPrimaryColor,
      );
  Color get buttonPrimaryTextColor => getColor(
        lightButtonPrimaryTextColor,
        darkButtonPrimaryTextColor,
      );
  Color get buttonPrimaryBoxShadowColor => getColor(
        lightButtonPrimaryBoxShadowColor,
        darkButtonPrimaryBoxShadowColor,
      );
  Color get buttonPrimaryProgressIndicatorBackgroundColor => getColor(
        lightButtonPrimaryProgressIndicatorBackgroundColor,
        darkButtonPrimaryProgressIndicatorBackgroundColor,
      );
  Color get buttonPrimaryProgressIndicatorValueColor => getColor(
        lightButtonPrimaryProgressIndicatorValueColor,
        darkButtonPrimaryProgressIndicatorValueColor,
      );
  Color get buttonSecondaryColor => getColor(
        lightButtonSecondaryColor,
        darkButtonSecondaryColor,
      );
  Color get buttonSecondaryTextColor => getColor(
        lightButtonSecondaryTextColor,
        darkButtonSecondaryTextColor,
      );
  Color get buttonSecondaryBoxShadowColor => getColor(
        lightButtonSecondaryBoxShadowColor,
        darkButtonSecondaryBoxShadowColor,
      );
  Color get buttonSecondaryProgressIndicatorBackgroundColor => getColor(
        lightButtonSecondaryProgressIndicatorBackgroundColor,
        darkButtonSecondaryProgressIndicatorBackgroundColor,
      );
  Color get buttonSecondaryProgressIndicatorValueColor => getColor(
        lightButtonSecondaryProgressIndicatorValueColor,
        darkButtonSecondaryProgressIndicatorValueColor,
      );

  Color get buttonAgainColor => getColor(
    lightButtonAgainColor,
    darkButtonAgainColor,
  );
  Color get buttonAgainTextColor => getColor(
    lightButtonAgainTextColor,
    darkButtonAgainTextColor,
  );

  Color get buttonHardColor => getColor(
    lightButtonHardColor,
    darkButtonHardColor,
  );
  Color get buttonHardTextColor => getColor(
    lightButtonHardTextColor,
    darkButtonHardTextColor,
  );

  Color get buttonGoodColor => getColor(
    lightButtonGoodColor,
    darkButtonGoodColor,
  );
  Color get buttonGoodTextColor => getColor(
    lightButtonGoodTextColor,
    darkButtonGoodTextColor,
  );

  Color get buttonEasyColor => getColor(
    lightButtonEasyColor,
    darkButtonEasyColor,
  );
  Color get buttonEasyTextColor => getColor(
    lightButtonEasyTextColor,
    darkButtonEasyTextColor,
  );

  // Input Colors

  Color get inputCursorColor => getColor(
        lightInputCursorColor,
        darkInputCursorColor,
      );
  Color get inputFillColor => getColor(
        lightInputFillColor,
        darkInputFillColor,
      );
  Color get inputFocusColor => getColor(
        lightInputFocusColor,
        darkInputFocusColor,
      );
  Color get inputHoverColor => getColor(
        lightInputHoverColor,
        darkInputHoverColor,
      );
  Color get inputBorderColor => getColor(
        lightInputBorderColor,
        darkInputBorderColor,
      );
  Color get inputFocusedBorderColor => getColor(
        lightInputFocusedBorderColor,
        darkInputFocusedBorderColor,
      );
  Color get inputBoxShadowColor => getColor(
        lightInputBoxShadowColor,
        darkInputBoxShadowColor,
      );

  // Checkbox & Switch Colors

  Color get checkboxActiveColor => getColor(
        lightCheckboxActiveColor,
        darkCheckboxActiveColor,
      );

  Color get switchActiveColor => getColor(
        lightSwitchActiveColor,
        darkSwitchActiveColor,
      );

  // Stats

  Color get statTotalColor => getColor(
        lightStatTotalColor,
        darkStatTotalColor,
      );
  Color get statNewColor => getColor(
        lightStatNewColor,
        darkStatNewColor,
      );
  Color get statReviewColor => getColor(
        lightStatReviewColor,
        darkStatReviewColor,
      );
  Color get statLearningColor => getColor(
        lightStatLearningColor,
        darkStatLearningColor,
      );
}
