import 'package:flutter/material.dart';
import 'constants.dart';

class AppThemeStyles {
  // Yuvarlak Köşeler
  static BorderRadius radius8 = BorderRadius.circular(8);
  static BorderRadius radius16 = BorderRadius.circular(16);
  static BorderRadius radius24 = BorderRadius.circular(24);
  static BorderRadius radius32 = BorderRadius.circular(32);
  static BorderRadius radiusFull = BorderRadius.circular(999);

  // Gölgeler (Premium Shadow)
  static List<BoxShadow> shadowLow = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8), spreadRadius: 0),
  ];
  
  static List<BoxShadow> shadowHigh = [
    BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 30, offset: const Offset(0, 10), spreadRadius: -5),
  ];

  // Glassmorphism (Buzlu Cam) Dekorasyonu
  // Not: Rengi dinamik hale getirmek için widget içinde context ile kullanmak daha doğru olur, 
  // ama bu sabit bir başlangıç noktasıdır.
  static BoxDecoration glassDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.85),
    borderRadius: radius24,
    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
    boxShadow: shadowMedium,
  );
}