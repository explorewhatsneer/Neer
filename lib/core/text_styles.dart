import 'package:flutter/material.dart';

class AppTextStyles {
  // 🔥 APPLE FONTU (NATIVE iOS DENGESİ)
  static const String _fontFamily = 'SFPro'; 

  // 1. BAŞLIKLAR (İsimler, Sayfa Başlıkları)
  // w900 çok kaba durur, w700 (Bold) ideal tokluktur.
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700, // Bold
    letterSpacing: -0.8, 
    height: 1.1,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600, // Semibold (Daha kibar başlık)
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600, 
    letterSpacing: -0.5,
    height: 1.25,
  );

  // 2. GÖVDE (Açıklamalar, Mesajlar)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17, 
    fontWeight: FontWeight.w400, // Regular (İnce ve net)
    letterSpacing: -0.4,
    height: 1.4, 
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.3,
  );
  
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: Colors.white,
  );
}