import 'package:vingo/util/sqlite.dart' as Vingo;

class Commandline {
  final List<String> arguments;

  const Commandline({
    required this.arguments,
  });

  Future<void> parse() async {
    await Vingo.SqliteUtil.getInstance().open();
    print("Commandline support not implemented.");
  }
}
