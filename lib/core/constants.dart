import 'package:flutter/material.dart';

class AppColors {
  // --- ANA MARKA RENKLERİ (Glass Morphism Palette) ---
  static const Color primary = Color(0xFFD4849A);     // Soft Rose
  static const Color primaryDark = Color(0xFFB8627D);  // Deep Rose
  static const Color accent = Color(0xFFB8A9C9);       // Lavender
  static const Color accentLight = Color(0xFFD5C8E6);  // Light Lavender

  // --- GRADIENT RENKLERİ ---
  static const Color gradientStart = Color(0xFFF5D5E0);  // Soft Pink
  static const Color gradientMiddle = Color(0xFFE8D5F0); // Pink-Lavender
  static const Color gradientEnd = Color(0xFFD5DEF5);    // Soft Blue-Lavender

  // --- DARK GRADIENT (derin, zengin renkler) ---
  static const Color darkGradientStart = Color(0xFF1A0E2E);  // Deep purple-black
  static const Color darkGradientMiddle = Color(0xFF140D24); // Dark plum
  static const Color darkGradientEnd = Color(0xFF0E0A1E);     // Near-black indigo

  // --- AYDINLIK MOD (LIGHT) ---
  static const Color lightBackground = Color(0xFFF8F0F5);
  static const Color lightSurface = Colors.white;
  static const Color lightTextHeading = Color(0xFF2D2035);
  static const Color lightTextBody = Color(0xFF4A3F52);
  static const Color lightTextSub = Color(0xFF9B8FA6);
  static const Color lightDivider = Color(0xFFEDE5F0);

  // --- KARANLIK MOD (DARK) — daha kontrast ---
  static const Color darkBackground = Color(0xFF120E1C);
  static const Color darkSurface = Color(0xFF221A30);     // Daha belirgin surface
  static const Color darkTextHeading = Color(0xFFF5F0F8);
  static const Color darkTextBody = Color(0xFFCCC2D8);
  static const Color darkTextSub = Color(0xFF7E7290);
  static const Color darkDivider = Color(0xFF342A45);

  // --- CAM (GLASS) EFEKTLERİ ---
  static final Color shadow = Colors.black.withValues(alpha: 0.06);
  static final Color glassBorder = Colors.white.withValues(alpha: 0.25);
  static const Color glassWhite = Color(0xCCFFFFFF);
  static const Color glassDark = Color(0xB3221A30);

  // --- DURUM RENKLERİ ---
  static const Color success = Color(0xFF7BC67E);
  static const Color error = Color(0xFFE87B8A);
  static const Color warning = Color(0xFFE8C97B);
  static const Color info = Color(0xFF7BA8E8);

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

  static final LinearGradient navBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.45),
      Colors.white.withValues(alpha: 0.35),
    ],
  );

  static final LinearGradient darkNavBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      const Color(0xFF221A30).withValues(alpha: 0.55),
      const Color(0xFF1A1228).withValues(alpha: 0.50),
    ],
  );

  // --- GÖLGE YARDIMCILARI ---
  /// Light modda soft rose, dark modda siyah bazlı gölgeler
  static List<BoxShadow> adaptiveShadow(bool isDark, {double blur = 16, double alpha = 0.08}) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: alpha * 2.5)
            : primary.withValues(alpha: alpha),
        blurRadius: blur,
        offset: const Offset(0, 4),
        spreadRadius: -2,
      ),
    ];
  }
}
