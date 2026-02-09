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
      if (savedTheme == 'ThemeMode.light') _themeMode = ThemeMode.light;
      else if (savedTheme == 'ThemeMode.dark') _themeMode = ThemeMode.dark;
      else _themeMode = ThemeMode.system;
      notifyListeners();
    }
  }

// --- LIGHT THEME ---
  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: const Color(0xFFF2F2F7), 
    cardColor: Colors.white,
    dividerColor: const Color(0xFFE5E5EA),
    
    fontFamily: 'SFPro', 

    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(color: Colors.black),
      displayMedium: AppTextStyles.h2.copyWith(color: Colors.black),
      displaySmall: AppTextStyles.h3.copyWith(color: Colors.black),
      
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF1C1C1E)), 
      bodyMedium: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF3A3A3C)),
      labelSmall: AppTextStyles.caption.copyWith(color: const Color(0xFF8E8E93)),
    ),
    
    // 🔥 APPBAR GÜNCELLEMESİ
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        fontFamily: 'SFPro',
        color: Colors.black, 
        fontWeight: FontWeight.w600, // 🔥 Bold(700) yerine Semibold(600)
        fontSize: 17,
        letterSpacing: -0.5
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: Colors.white,
      background: Colors.white,
      onPrimary: Colors.white,
      onSurface: Color(0xFF262626),
    ),
  );

// --- DARK THEME ---
  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: Colors.black,
    cardColor: const Color(0xFF1C1C1E),
    dividerColor: const Color(0xFF38383A),
    
    fontFamily: 'SFPro',

    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(color: Colors.white),
      displayMedium: AppTextStyles.h2.copyWith(color: Colors.white),
      displaySmall: AppTextStyles.h3.copyWith(color: Colors.white),
      
      bodyLarge: AppTextStyles.bodyLarge.copyWith(color: Colors.white), 
      bodyMedium: AppTextStyles.bodySmall.copyWith(color: const Color(0xFFE5E5EA)),
      labelSmall: AppTextStyles.caption.copyWith(color: const Color(0xFF8E8E93)),
    ),

    // 🔥 APPBAR GÜNCELLEMESİ
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontFamily: 'SFPro',
        color: Colors.white, 
        fontWeight: FontWeight.w600, // 🔥 Bold(700) yerine Semibold(600)
        fontSize: 17,
        letterSpacing: -0.5
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: Color(0xFF121212),
      background: Colors.black,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
  );
}