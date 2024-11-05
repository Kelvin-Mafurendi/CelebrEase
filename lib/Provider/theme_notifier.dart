// theme_notifier.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // Initialize the theme notifier
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    
    // Load saved theme mode
    final savedTheme = _prefs?.getString(_themeKey);
    if (savedTheme != null) {
      _themeMode = _themeModeFromString(savedTheme);
    }
    _isInitialized = true;
    notifyListeners();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners(); // Notify before saving to ensure immediate UI update
    
    // Save the theme mode
    await _prefs?.setString(_themeKey, _themeModeToString(mode));
  }

  // Convert ThemeMode to string for storage
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  // Convert stored string back to ThemeMode
  ThemeMode _themeModeFromString(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}