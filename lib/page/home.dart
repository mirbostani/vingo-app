import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:vingo/util/util.dart' as Vingo;
import 'package:vingo/widget/widget.dart' as Vingo;

class HomePage extends StatefulWidget {
  static const String route = '/home';
  static const String title = 'Home';
  static const Icon icon = Icon(Icons.home);
  final Widget? androidDrawer;

  const HomePage({
    Key? key,
    this.androidDrawer,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String>? futureBuilder() async {
    return HomePage.title;
  }

  Widget bodyBuilder(BuildContext context) {
    return FutureBuilder(
      future: futureBuilder(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.data == null || snapshot.data.isEmpty) {
          return Container(
            child: Center(
              child: Text(HomePage.route),
            ),
          );
        }
        return Container(
          child: Center(
            child: Text(snapshot.data),
          ),
        );
      },
    );
  }

  Widget androidBuilder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Vingo.LocalizationsUtil.of(context).home,
          style: TextStyle(
            color: Vingo.ThemeUtil.of(context).appBarTitleTextColor,
            fontWeight: FontWeight.w800,
          ),
        ),
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
