// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData.light();
  bool _isBlueLightFilterEnabled = false;

  ThemeProvider() {
    _loadTheme();
    _loadBlueLightFilter();
  }

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _themeData.brightness == Brightness.dark;
  bool get isBlueLightFilterEnabled => _isBlueLightFilterEnabled;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme') ?? false;
    _themeData = isDark ? _darkTheme() : _lightTheme();
    notifyListeners();
  }

  Future<void> _loadBlueLightFilter() async {
    final prefs = await SharedPreferences.getInstance();
    _isBlueLightFilterEnabled = prefs.getBool('isBlueLightFilterEnabled') ?? false;
    notifyListeners();
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (_themeData.brightness == Brightness.light) {
      _themeData = _darkTheme();
      await prefs.setBool('isDarkTheme', true);
    } else {
      _themeData = _lightTheme();
      await prefs.setBool('isDarkTheme', false);
    }
    notifyListeners();
  }

  void toggleBlueLightFilter() async {
    final prefs = await SharedPreferences.getInstance();
    _isBlueLightFilterEnabled = !_isBlueLightFilterEnabled;
    await prefs.setBool('isBlueLightFilterEnabled', _isBlueLightFilterEnabled);
    notifyListeners();
  }

  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Colors.blue.shade800,
        onPrimary: Colors.white,
        secondary: Colors.orange.shade800,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black,
        error: Colors.red.shade700,
        onError: Colors.white,
        primaryContainer: Colors.blue.shade100,
        onPrimaryContainer: Colors.blue.shade900,
        secondaryContainer: Colors.orange.shade100,
        onSecondaryContainer: Colors.orange.shade900,
        tertiary: Colors.green.shade800,
        onTertiary: Colors.white,
        tertiaryContainer: Colors.green.shade100,
        onTertiaryContainer: Colors.green.shade900,
        errorContainer: Colors.red.shade100,
        onErrorContainer: Colors.red.shade900,
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Colors.blue.shade600,
        onPrimary: Colors.white,
        secondary: Colors.orange.shade600,
        onSecondary: Colors.white,
        surface: Colors.grey.shade800,
        onSurface: Colors.blue.shade800,
        error: Colors.red.shade400,
        onError: Colors.black,
        primaryContainer: Colors.blue.shade900,
        onPrimaryContainer: Colors.blue.shade100,
        secondaryContainer: Colors.orange.shade900,
        onSecondaryContainer: Colors.orange.shade100,
        tertiary: Colors.green.shade600,
        onTertiary: Colors.black,
        tertiaryContainer: Colors.green.shade900,
        onTertiaryContainer: Colors.green.shade100,
        errorContainer: Colors.red.shade900,
        onErrorContainer: Colors.red.shade100,
      ),
    );
  }
}
