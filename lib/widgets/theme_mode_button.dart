import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tormentedplayer/models/app_theme_mode.dart';

const _icons = [
  Icons.brightness_auto,
  Icons.brightness_high,
  Icons.brightness_low,
];

class ThemeModeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppThemeMode appMode = Provider.of<AppThemeMode>(context);

    return IconButton(
      icon: Icon(
        _icons[appMode.currentMode?.index ?? 0],
      ),
      color: Theme.of(context).iconTheme.color,
      onPressed: () => appMode.nextMode(),
    );
  }
}
