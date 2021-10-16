import 'dart:io' as Io;
import 'package:vingo/util/util.dart' as Vingo;

class ImageUtil {
  /// Get image stored in Linux clipboard and save it to the assets folder.
  static Future<String?> getImageFromClipboardLinux() async {
    if (!Io.Platform.isLinux) return null;
    String fileName = Vingo.FileUtil.generateRandomImageFileName();
    String? filePath = await Vingo.FileUtil.getImageFilePath(fileName);

    Vingo.PlatformUtil.log("Image file path: $filePath");
    Io.ProcessResult? result = await Vingo.FileUtil.run(
      command: "sh",
      arguments: [
        "-c",
        "xclip -selection clipboard -target 'image/png' -out > '$filePath'"
      ],
      runInShell: true,
    );
    if (result != null && result.stderr.toString().isNotEmpty) return null;
    return fileName;
  }
}
