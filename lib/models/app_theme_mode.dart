import 'package:flutter/material.dart';

class AppThemeMode extends ChangeNotifier {
  ThemeMode _currentMode;

  static const defaultThemeMode = ThemeMode.dark;

  AppThemeMode({ ThemeMode initialValue = defaultThemeMode }) {
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
