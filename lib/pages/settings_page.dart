import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/models/app_theme_mode.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  static final String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    AppThemeMode appThemeMode = Provider.of<AppThemeMode>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final name = snapshot.data.appName;
          final version = snapshot.data.version;
          final build = snapshot.data.buildNumber;

          return PreferencePage([
            DropdownPreference(
              'Theme',
              'theme',
              defaultVal: AppThemeMode.defaultThemeMode.index,
              displayValues: ['Light', 'Dark', 'System default'],
              values: [
                ThemeMode.light.index,
                ThemeMode.dark.index,
                ThemeMode.system.index
              ],
              onChange: appThemeMode.setModeFromIndex,
            ),
            PreferenceTitle('About this app'),
            ListTile(
              title: Text('Version'),
              trailing: Text('$version+$build'),
            ),
            ListTile(
              title: Text('GitHub repository'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => _openGitHub(context),
            ),
            ListTile(
              title: Text('Licenses'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => showLicensePage(
                context: context,
                applicationVersion: '$version+$build',
                applicationName: name,
                applicationIcon: Image.asset(
                  'assets/images/fullbleed_icon.png',
                  height: 120,
                  width: 120,
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

_openGitHub(context) async {
  const url = 'https://github.com/Jei/tormentedplayer';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Oops'),
          content:
          Text('There was an error while opening $url'),
          actions: [
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
