import 'dart:io' as Io;
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart' as PathProvider;

class FileUtil {
  static const String assetsDirName = "assets";

  /// Private directory which is hidden from the user (not user-generated).
  static Future<String> getAppSupportDir() async {
    if (kIsWeb) {
      assert(false, "FileUtil does not support $defaultTargetPlatform");
    } else if (Io.Platform.isAndroid) {
      // Android: "/data/data/com.mirbostani.vingo/files"
      Io.Directory dir = await PathProvider.getApplicationSupportDirectory();
      return dir.path;
    } else if (Io.Platform.isIOS) {
      // iOS: ?
      Io.Directory dir = await PathProvider.getApplicationSupportDirectory();
      return dir.path;
    } else if (Io.Platform.isLinux || Io.Platform.isWindows || Io.Platform.isMacOS) {
      // Linux: "/home/morteza/.local/share/vingo"
      // Windows: "C:/Users//AppData/Local/vingo"
      // MacOS: "~/Library/Application Support/vingo"
      Io.Directory dir = await PathProvider.getApplicationSupportDirectory();
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      return dir.path;
    }
    assert(false, "FileUtil does not support $defaultTargetPlatform");
    return "";
  }

  static Future<bool> exists(String path) async {
    return Io.File(path).exists();
  }
}