import 'package:flutter/material.dart';

class AppColors {
  // --- ANA MARKA RENKLERİ ---
  static const Color primary = Color(0xFF8C003A); // Bordo (RGB: 140, 0, 58)
  static const Color primaryDark = Color(0xFF42001E); // Koyu Bordo
  static const Color accent = Color(0xFFD4AF37); // Altın Sarısı

  // --- AYDINLIK MOD (LIGHT) ---
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightSurface = Colors.white;
  static const Color lightTextHeading = Color(0xFF1C1C1E);
  static const Color lightTextBody = Color(0xFF3A3A3C);
  static const Color lightTextSub = Color(0xFF8E8E93); // Eksikti, eklendi
  static const Color lightDivider = Color(0xFFE5E5EA);

  // --- KARANLIK MOD (DARK) ---
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkTextHeading = Color(0xFFFFFFFF);
  static const Color darkTextBody = Color(0xFFAEAEB2);
  static const Color darkTextSub = Color(0xFF636366); // Eksikti, eklendi
  static const Color darkDivider = Color(0xFF38383A);

  // --- EFEKTLER (Global) ---
  static final Color shadow = Colors.black.withOpacity(0.08);
  static final Color glassBorder = Colors.white.withOpacity(0.2);
}