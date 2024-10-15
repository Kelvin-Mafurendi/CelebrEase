import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default theme is light

  ThemeMode get themeMode => _themeMode; // Getter to access current theme

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode; // Update the theme mode
    notifyListeners(); // Notify listeners to rebuild UI
  }
}
