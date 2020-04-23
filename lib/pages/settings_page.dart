import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/models/app_theme_mode.dart';

class SettingsPage extends StatelessWidget {
  static final String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    AppThemeMode appThemeMode = Provider.of<AppThemeMode>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: PreferencePage([
        DropdownPreference(
          'Theme',
          'theme',
          defaultVal: ThemeMode.system.index,
          displayValues: ['Light', 'Dark', 'System default'],
          values: [
            ThemeMode.light.index,
            ThemeMode.dark.index,
            ThemeMode.system.index
          ],
          onChange: appThemeMode.setModeFromIndex,
        ),
        ListTile(
          title: Text('About this app'),
          onTap: () => showLicensePage(context: context),
          trailing: Icon(Icons.chevron_right),
        ),
      ]),
    );
  }
}
