import 'package:flutter/material.dart';

class AppColors {
  // --- ANA MARKA RENKLERİ (Glass Morphism Palette) ---
  static const Color primary = Color(0xFFD4849A);     // Soft Rose
  static const Color primaryDark = Color(0xFFB8627D);  // Deep Rose
  static const Color accent = Color(0xFFB8A9C9);       // Lavender
  static const Color accentLight = Color(0xFFD5C8E6);  // Light Lavender

  // --- GRADIENT RENKLERİ ---
  static const Color gradientStart = Color(0xFFF5D5E0);  // Soft Pink
  static const Color gradientMiddle = Color(0xFFE8D5F0);  // Pink-Lavender
  static const Color gradientEnd = Color(0xFFD5DEF5);     // Soft Blue-Lavender

  // --- DARK GRADIENT ---
  static const Color darkGradientStart = Color(0xFF1A1020);  // Deep Purple-Black
  static const Color darkGradientMiddle = Color(0xFF15101E); // Dark Purple
  static const Color darkGradientEnd = Color(0xFF0D0F1A);    // Deep Navy-Black

  // --- AYDINLIK MOD (LIGHT) ---
  static const Color lightBackground = Color(0xFFF8F0F5); // Warm pink-tinted white
  static const Color lightSurface = Colors.white;
  static const Color lightTextHeading = Color(0xFF2D2035); // Soft dark purple
  static const Color lightTextBody = Color(0xFF4A3F52);    // Medium dark purple
  static const Color lightTextSub = Color(0xFF9B8FA6);     // Muted lavender
  static const Color lightDivider = Color(0xFFEDE5F0);     // Light lavender divider

  // --- KARANLIK MOD (DARK) ---
  static const Color darkBackground = Color(0xFF0D0A12);   // Deep purple-black
  static const Color darkSurface = Color(0xFF1A1520);      // Dark purple surface
  static const Color darkTextHeading = Color(0xFFF5F0F8);  // Warm white
  static const Color darkTextBody = Color(0xFFBEB5C8);     // Light lavender
  static const Color darkTextSub = Color(0xFF6B5F78);      // Muted purple
  static const Color darkDivider = Color(0xFF2A2035);      // Dark purple divider

  // --- CAM (GLASS) EFEKTLERİ ---
  static final Color shadow = Colors.black.withValues(alpha: 0.06);
  static final Color glassBorder = Colors.white.withValues(alpha: 0.25);
  static const Color glassWhite = Color(0xCCFFFFFF);      // 80% white
  static const Color glassDark = Color(0xB3151020);        // 70% dark purple

  // --- DURUM RENKLERİ ---
  static const Color success = Color(0xFF7BC67E);   // Soft green
  static const Color error = Color(0xFFE87B8A);     // Soft red/rose
  static const Color warning = Color(0xFFE8C97B);   // Soft gold
  static const Color info = Color(0xFF7BA8E8);       // Soft blue

  // --- GRADIENT HELPERS ---
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientMiddle, gradientEnd],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkGradientStart, darkGradientMiddle, darkGradientEnd],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8A0BF), Color(0xFFD4849A)],
  );

  static const LinearGradient navBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4849A), Color(0xFFC07A90)],
  );

  static const LinearGradient darkNavBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A1F35), Color(0xFF1F1828)],
  );
}
