import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tormentedplayer/resources/preferences.dart';

class AppThemeMode extends ChangeNotifier {
  static final _prefKey = 'theme_mode';
  ThemeMode _currentMode;
  bool _loading = true;
  Preferences _prefs = Preferences();

  AppThemeMode() {
    _loadFromPreferences().then((mode) {
      _loading = false;
      _setMode(mode);
    });
  }

  Future<ThemeMode> _loadFromPreferences() async {
    int pref = await _prefs.loadInt(_prefKey, 0);
    return ThemeMode.values[max(0, min(pref, ThemeMode.values.length))];
  }

  Future<void> _saveToPreferences(ThemeMode mode) async {
    return _prefs.saveInt(_prefKey, mode.index);
  }

  void _setMode(ThemeMode mode) {
    _currentMode = mode;
    _saveToPreferences(mode);
    notifyListeners();
  }

  void nextMode() {
    _setMode(ThemeMode.values[(_currentMode.index + 1) % 3]);
  }

  ThemeMode get currentMode => _currentMode;

  bool get loading => _loading;
}
