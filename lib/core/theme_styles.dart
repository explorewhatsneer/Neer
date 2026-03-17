import 'package:flutter/material.dart';
import 'constants.dart';

class AppThemeStyles {
  // Yuvarlak Köşeler
  static BorderRadius radius8 = BorderRadius.circular(8);
  static BorderRadius radius16 = BorderRadius.circular(16);
  static BorderRadius radius24 = BorderRadius.circular(24);
  static BorderRadius radius32 = BorderRadius.circular(32);
  static BorderRadius radiusFull = BorderRadius.circular(999);

  // Gölgeler (Soft Pastel Shadows)
  static List<BoxShadow> shadowLow = [
    BoxShadow(color: AppColors.primary.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(color: AppColors.primary.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 8), spreadRadius: -2),
  ];

  static List<BoxShadow> shadowHigh = [
    BoxShadow(color: AppColors.primary.withValues(alpha: 0.20), blurRadius: 32, offset: const Offset(0, 12), spreadRadius: -4),
  ];

  // Glass Card Decoration (Light)
  static BoxDecoration glassDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.70),
    borderRadius: radius24,
    border: Border.all(color: Colors.white.withValues(alpha: 0.50), width: 1),
    boxShadow: shadowLow,
  );

  // Glass Card Decoration (Dark)
  static BoxDecoration glassDarkDecoration = BoxDecoration(
    color: AppColors.darkSurface.withValues(alpha: 0.60),
    borderRadius: radius24,
    border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
    boxShadow: [
      BoxShadow(color: Colors.black.withValues(alpha: 0.20), blurRadius: 24, offset: const Offset(0, 8)),
    ],
  );

  // Helper: Glass decoration from context
  static BoxDecoration glassCard(BuildContext context, {double borderRadius = 24}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark
          ? AppColors.darkSurface.withValues(alpha: 0.55)
          : Colors.white.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.60),
        width: 1,
      ),
      boxShadow: isDark
          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 4))]
          : shadowLow,
    );
  }
}
