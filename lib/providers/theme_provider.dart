// lib/providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:caminho_do_saber/ui/theme/app_colors.dart';

class ThemeProvider with ChangeNotifier {
  // Padronização de Cores Educlass Aura
  static const Color eduBlue = AppColors.primary;
  static const Color eduPurple = AppColors.tertiary; // Lavender
  static const Color eduSeafoam = AppColors.secondary;
  static const Color eduYellow = AppColors.yellow;
  static const Color eduGold = AppColors.gold;
  static const Color eduOrange = AppColors.orange;
  static const Color eduGreen = AppColors.success;

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
    final baseTextTheme = GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: baseTextTheme.copyWith(
        titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
        titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
        titleSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
        labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
        labelMedium: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        bodyLarge: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.poppins(fontWeight: FontWeight.w400),
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        contentTextStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.black),
        contentTextStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black87),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 2,
        color: Colors.white,
      ),
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        tertiary: AppColors.tertiary,
        onTertiary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black87,
        error: Colors.red.shade700,
        onError: Colors.white,
      ),
    );
  }

  ThemeData _darkTheme() {
    final baseTextTheme = GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: baseTextTheme.copyWith(
        titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        titleSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        labelMedium: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        bodyLarge: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        bodyMedium: GoogleFonts.poppins(fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.poppins(fontWeight: FontWeight.w400),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: AppColors.primary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        contentTextStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20, color: Colors.white),
        contentTextStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white70),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 2,
      ),
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        tertiary: AppColors.tertiary,
        onTertiary: Colors.white,
        surface: AppColors.backgroundDark,
        onSurface: Colors.white,
        error: Colors.red.shade400,
        onError: Colors.black,
      ),
    );
  }
}
