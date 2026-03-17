import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'text_styles.dart';

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
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: Colors.white.withValues(alpha: 0.70),
    dividerColor: AppColors.lightDivider,

    fontFamily: 'SFPro',

    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.lightTextHeading),
      displayMedium: AppTextStyles.h2.copyWith(color: AppColors.lightTextHeading),
      displaySmall: AppTextStyles.h3.copyWith(color: AppColors.lightTextHeading),

      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.lightTextHeading),
      bodyMedium: AppTextStyles.bodySmall.copyWith(color: AppColors.lightTextBody),
      labelSmall: AppTextStyles.caption.copyWith(color: AppColors.lightTextSub),
    ),

    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.lightTextHeading),
      titleTextStyle: TextStyle(
        fontFamily: 'SFPro',
        color: AppColors.lightTextHeading,
        fontWeight: FontWeight.w700,
        fontSize: 17,
        letterSpacing: -0.5,
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSurface: AppColors.lightTextHeading,
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
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkSurface.withValues(alpha: 0.55),
    dividerColor: AppColors.darkDivider,

    fontFamily: 'SFPro',

    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.darkTextHeading),
      displayMedium: AppTextStyles.h2.copyWith(color: AppColors.darkTextHeading),
      displaySmall: AppTextStyles.h3.copyWith(color: AppColors.darkTextHeading),

      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkTextHeading),
      bodyMedium: AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextBody),
      labelSmall: AppTextStyles.caption.copyWith(color: AppColors.darkTextSub),
    ),

    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.darkTextHeading),
      titleTextStyle: TextStyle(
        fontFamily: 'SFPro',
        color: AppColors.darkTextHeading,
        fontWeight: FontWeight.w700,
        fontSize: 17,
        letterSpacing: -0.5,
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.darkSurface,
      onPrimary: Colors.white,
      onSurface: AppColors.darkTextHeading,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface.withValues(alpha: 0.90),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
  );
}
