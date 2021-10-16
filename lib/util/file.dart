import 'dart:io' as Io;
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart' as PathProvider;
import 'package:vingo/util/util.dart' as Vingo;

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
    } else if (Io.Platform.isLinux ||
        Io.Platform.isWindows ||
        Io.Platform.isMacOS) {
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

  static Future<String> getAssetDir() async {
    String dir = await getAppSupportDir();
    String dirPath = Path.join(dir, assetsDirName);
    if (Io.FileSystemEntity.typeSync(dirPath) !=
        Io.FileSystemEntityType.directory) {
      Io.Directory(dirPath).createSync(recursive: true);
    }
    return dirPath;
  }

  static Future<bool> exists(String path) async {
    return Io.File(path).exists();
  }

  //----------------------------------------------------------------------------

  static Future<String> getImageDir() async {
    return await getAssetDir();
  }

  static String generateRandomImageFileName({
    String prefix = "image_",
    String ext = "png",
  }) {
    String fileBaseName = Uuid().v1().toString().replaceAll('-', '');
    String fileName = "$prefix$fileBaseName.$ext";
    return fileName;
  }

  static Future<String?> getImageFilePath(
    String fileName, {
    bool checkExists = false,
  }) async {
    String dir = await getImageDir();
    String filePath = Path.join(dir, fileName);
    if (!checkExists) {
      return filePath;
    }
    if (await exists(filePath)) {
      return filePath;
    }
    return null;
  }

  //----------------------------------------------------------------------------

  static Future<Io.ProcessResult?> run({
    required String command,
    required List<String> arguments,
    String? workingDirectory,
    Map<String, String>? environment,
    bool includeParentEnvironment = true,
    bool runInShell = false,
  }) async {
    if (Io.Platform.isLinux || Io.Platform.isWindows || Io.Platform.isMacOS) {
      Io.ProcessResult result = await Io.Process.run(
        command,
        arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        runInShell: runInShell,
      );
      Vingo.PlatformUtil.log("stderr: ${result.stderr}");
      Vingo.PlatformUtil.log("stdout: ${result.stdout}");
      return result;
    }
    assert(false, 'FileUtil does not support $defaultTargetPlatform');
    return null;
  }
}
