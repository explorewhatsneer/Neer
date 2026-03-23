import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'neer_design_system.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeManager() {
    _loadTheme();
  }

  void toggleTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme_mode', mode.toString());
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedTheme = prefs.getString('theme_mode');
    if (savedTheme != null) {
      if (savedTheme == 'ThemeMode.light') {
        _themeMode = ThemeMode.light;
      } else if (savedTheme == 'ThemeMode.dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    }
  }

  // --- LIGHT THEME (Glass Morphism) ---
  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: NeerColors.primary,
    scaffoldBackgroundColor: NeerColors.gray50,
    cardColor: Colors.white.withValues(alpha: 0.70),
    dividerColor: NeerColors.gray200,

    fontFamily: 'SFPro',

    textTheme: TextTheme(
      displayLarge: NeerTypography.h1.copyWith(color: NeerColors.gray900),
      displayMedium: NeerTypography.h2.copyWith(color: NeerColors.gray900),
      displaySmall: NeerTypography.h3.copyWith(color: NeerColors.gray900),

      bodyLarge: NeerTypography.bodyLarge.copyWith(color: NeerColors.gray900),
      bodyMedium: NeerTypography.bodySmall.copyWith(color: NeerColors.gray600),
      labelSmall: NeerTypography.caption.copyWith(color: NeerColors.gray400),
    ),

    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: NeerColors.gray900),
      titleTextStyle: TextStyle(
        fontFamily: 'SFPro',
        color: NeerColors.gray900,
        fontWeight: FontWeight.w700,
        fontSize: 17,
        letterSpacing: -0.5,
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: NeerColors.primary,
      secondary: NeerColors.accent,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: NeerColors.gray900,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.90),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
  );

  // --- DARK THEME (Glass Morphism) ---
  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: NeerColors.primary,
    scaffoldBackgroundColor: NeerColors.darkSurface,
    cardColor: NeerColors.darkSurface.withValues(alpha: 0.65),
    dividerColor: NeerColors.gray700,

    fontFamily: 'SFPro',

    textTheme: TextTheme(
      displayLarge: NeerTypography.h1.copyWith(color: Colors.white),
      displayMedium: NeerTypography.h2.copyWith(color: Colors.white),
      displaySmall: NeerTypography.h3.copyWith(color: Colors.white),

      bodyLarge: NeerTypography.bodyLarge.copyWith(color: Colors.white),
      bodyMedium: NeerTypography.bodySmall.copyWith(color: NeerColors.gray300),
      labelSmall: NeerTypography.caption.copyWith(color: NeerColors.gray500),
    ),

    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontFamily: 'SFPro',
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 17,
        letterSpacing: -0.5,
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: NeerColors.primary,
      secondary: NeerColors.accent,
      surface: NeerColors.darkSurface,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: NeerColors.darkSurface.withValues(alpha: 0.90),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
  );
}
