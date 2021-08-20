import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:vingo/page/home.dart' as Vingo;
import 'package:vingo/page/settings.dart' as Vingo;
import 'package:vingo/widget/app_license.dart' as Vingo;
import 'package:vingo/util/localizations.dart' as Vingo;
import 'package:vingo/util/theme.dart' as Vingo;
import 'package:vingo/util/platform.dart' as Vingo;

class AndroidDrawer extends StatefulWidget {
  const AndroidDrawer({Key? key}) : super(key: key);

  @override
  _AndroidDrawerState createState() => _AndroidDrawerState();
}

class _AndroidDrawerState extends State<AndroidDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //------------------------------------------------------------------
            DrawerHeader(
              child: Icon(
                Icons.account_circle,
                color: Vingo.ThemeUtil.of(context).buttonPrimaryColor,
                size: 96,
              ),
            ),
            //------------------------------------------------------------------
            ListTile(
                leading: Container(
                  height: double.infinity,
                  child: Vingo.HomePage.icon,
                ),
                title: Text(
                  Vingo.LocalizationsUtil.of(context).home,
                ),
                onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    Vingo.HomePage.route,
                  );
                }),
            //------------------------------------------------------------------
            ListTile(
                leading: Container(
                  height: double.infinity,
                  child: Vingo.SettingsPage.icon,
                ),
                title: Text(
                  Vingo.LocalizationsUtil.of(context).settings,
                ),
                onTap: () {
                  Navigator.pushReplacementNamed(
                    context,
                    Vingo.SettingsPage.route,
                  );
                }),
            //------------------------------------------------------------------
            Expanded(
              child: Container(),
            ),
            //------------------------------------------------------------------
            // Copyright & Licenses
            Container(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Directionality(
                  textDirection: TextDirection.ltr, // force direction
                  child: ListTile(
                    title: Text(
                      Vingo.PlatformUtil.getAppName(),
                      style: TextStyle(
                        color: Vingo.ThemeUtil.of(context).textMutedColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Text(
                      Vingo.PlatformUtil.getVersion(),
                      style: TextStyle(
                        color: Vingo.ThemeUtil.of(context).textMutedColor,
                        fontSize: Vingo.ThemeUtil.textFontSizeSmall,
                      ),
                    ),
                    onTap: () async {
                      Vingo.AppLicense.showDialog(context);
                    },
                  ),
                ),
              ),
            ),
            //------------------------------------------------------------------
          ],
        ),
      ),
    );
  }
}
