import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vingo/util/localizations.dart' as Vingo;
import 'package:vingo/util/theme.dart' as Vingo;
import 'package:vingo/util/platform.dart' as Vingo;

class AppLicenseEntry extends LicenseEntry {
  final Iterable<String> packages;
  final Iterable<LicenseParagraph> paragraphs;

  const AppLicenseEntry({
    required this.packages,
    required this.paragraphs,
  });
}

class AppLicense {
  static Stream<LicenseEntry> licenses() async* {
    final String license =
        await rootBundle.loadString('fonts/Roboto/LICENSE.txt');

    yield AppLicenseEntry(
      packages: <String>['googlefonts/roboto'],
      paragraphs: <LicenseParagraph>[
        LicenseParagraph(
          '''
        Copyright (c) 2004 Google, Inc.
        ''',
          0,
        ),
      ],
    );
    yield LicenseEntryWithLineBreaks(<String>['googlefonts/roboto'], license);
  }

  static Future<void> showDialog(BuildContext context) async {
    LicenseRegistry.addLicense(licenses);
    showAboutDialog(
      context: context,
      applicationName: Vingo.PlatformUtil.getAppName(),
      applicationVersion: Vingo.PlatformUtil.getVersion(),
      applicationLegalese: Vingo.LocalizationsUtil.of(context).developedBy,
      applicationIcon: null,
      children: <Widget>[
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "\n\n" +
                    Vingo.LocalizationsUtil.of(context).aboutSoftware +
                    "\n\n",
                style: TextStyle(
                  color: Vingo.ThemeUtil.of(context).textMutedColor,
                ),
              ),
              TextSpan(
                text: Vingo.LocalizationsUtil.of(context).licensedUnder1,
                style: TextStyle(
                  color: Vingo.ThemeUtil.of(context).textMutedColor,
                ),
              ),
              TextSpan(
                text: " " +
                    Vingo.LocalizationsUtil.of(context).licensedUnder2 +
                    " ",
                style: TextStyle(
                  color: Vingo.ThemeUtil.of(context).textPrimaryColor,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    await Vingo.PlatformUtil.launchUrl(
                      Vingo.PlatformUtil.licenseLink,
                    );
                  },
              ),
              TextSpan(
                text: Vingo.LocalizationsUtil.of(context).licensedUnder3 + "\n",
                style: TextStyle(
                  color: Vingo.ThemeUtil.of(context).textMutedColor,
                ),
              ),
              TextSpan(
                text: Vingo.LocalizationsUtil.of(context).sourceCodeAvail1,
                style: TextStyle(
                  color: Vingo.ThemeUtil.of(context).textMutedColor,
                ),
              ),
              TextSpan(
                text: " " +
                    Vingo.LocalizationsUtil.of(context).sourceCodeAvail2 +
                    " ",
                style: TextStyle(
                  color: Vingo.ThemeUtil.of(context).textPrimaryColor,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    await Vingo.PlatformUtil.launchUrl(
                      Vingo.PlatformUtil.githubLink,
                    );
                  },
              ),
              TextSpan(
                text: Vingo.LocalizationsUtil.of(context).sourceCodeAvail3,
                style: TextStyle(
                  color: Vingo.ThemeUtil.of(context).textMutedColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
