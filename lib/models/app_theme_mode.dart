import 'package:flutter/material.dart';

class AppThemeMode extends ChangeNotifier {
  ThemeMode _currentMode;

  AppThemeMode({ ThemeMode initialValue = ThemeMode.system }) {
    _currentMode = initialValue;
  }

  void setMode(ThemeMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  void setModeFromIndex(int index) {
    setMode(ThemeMode.values[index]);
  }

  void nextMode() {
    setMode(ThemeMode.values[(_currentMode.index + 1) % 3]);
  }

  ThemeMode get currentMode => _currentMode;
}
