import 'dart:io' as Io;
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class PlatformUtil {
  /// Update pubspec.yaml
  static String appName = "Vingo";
  static String packageName = "com.mirbostani.vingo";
  static String version = "1.0.5";
  static String buildNumber = "6";
  static String authorLink = "https://mirbostani.com";
  static String licenseLink =
      "https://github.com/mirbostani/vingo-app/blob/main/LICENSE";
  static String githubLink = "https://github.com/mirbostani/vingo-app";

  static String getAppName() {
    String name = appName;
    if (kIsWeb) {
      name += ' for Web';
    } else if (Io.Platform.isAndroid) {
      name += ' for Android';
    } else if (Io.Platform.isIOS) {
      name += ' for iOS';
    } else if (Io.Platform.isLinux) {
      name += ' for Linux';
    } else if (Io.Platform.isWindows) {
      name += ' for Windows';
    } else if (Io.Platform.isMacOS) {
      name += ' for MacOS';
    }
    return name;
  }

  static String getVersion() {
    return 'v$version';
  }

  /// Log method does not show output in debug mode.
  /// Use `--release` option while building the app to suppress the output.
  static void log(Object o) {
    assert(() {
      print(o);
      return true;
    }());
  }

  /// Launch a URL on the platform's default browser
  static Future<void> launchUrl(String url) async {
    if (await UrlLauncher.canLaunch(url)) {
      await UrlLauncher.launch(url);
    }
  }
}
