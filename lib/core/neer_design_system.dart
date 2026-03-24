import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Re-export GradientScaffold (PremiumBackground kullanan versiyon)
export '../widgets/common/gradient_scaffold.dart';

// ══════════════════════════════════════════════════════════════════
// NEER DESIGN SYSTEM v2.0
// Referans: Glassmorphism + Soft Gradients + Premium iOS Aesthetic
// ══════════════════════════════════════════════════════════════════

// ─── 1. RENK PALETİ ─────────────────────────────────────────────

class NeerColors {
  NeerColors._();

  // Ana Marka Renkleri
  static const Color primary = Color(0xFF8B5CF6);       // Canlı Mor
  static const Color primaryLight = Color(0xFFB794F6);   // Açık Mor
  static const Color primaryDark = Color(0xFF6D28D9);    // Koyu Mor

  static const Color secondary = Color(0xFFEC4899);      // Pembe
  static const Color secondaryLight = Color(0xFFF9A8D4); // Açık Pembe

  static const Color accent = Color(0xFFFF8C42);         // Sıcak Turuncu
  static const Color accentLight = Color(0xFFFFB88C);    // Açık Turuncu

  // Gradient Setleri
  static const Color gradientStart = Color(0xFFD8B4FE);  // Lavanta
  static const Color gradientMid = Color(0xFFFBCFE8);    // Pembe Şeftali
  static const Color gradientEnd = Color(0xFFFED7AA);     // Kayısı

  // Durum Renkleri
  static const Color success = Color(0xFF34D399);    // Yeşil
  static const Color warning = Color(0xFFFBBF24);    // Sarı
  static const Color error = Color(0xFFEF4444);      // Kırmızı
  static const Color info = Color(0xFF60A5FA);        // Mavi

  // Pin Durumları (Harita)
  static const Color pinLow = Color(0xFF34D399);     // Sakin - Yeşil
  static const Color pinMedium = Color(0xFFFBBF24);  // Hareketli - Sarı
  static const Color pinHigh = Color(0xFFEF4444);    // Yoğun - Kırmızı
  static const Color pinEmpty = Color(0xFF9CA3AF);   // Veri yok - Gri
  static const Color pinNeon = Color(0xFFD946EF);    // Premium - Neon Mor

  // Nötr Tonlar
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF0F0F0F);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Cam Efekti (Glassmorphism)
  static Color glassWhite = Colors.white.withValues(alpha: 0.15);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);
  static Color glassWhiteDark = Colors.white.withValues(alpha: 0.08);
  static Color glassBorderDark = Colors.white.withValues(alpha: 0.12);

  // Dark Mode Yüzeyler
  static const Color darkSurface  = Color(0xFF1A0F1A);
  static const Color darkCard     = Color(0xFF241220);
  static const Color darkElevated = Color(0xFF2C1A2C);
}

// ─── 2. GRADIENT TANIMLARI ──────────────────────────────────────

class NeerGradients {
  NeerGradients._();

  // Ana Arka Plan Gradienti (Referans görsellerden)
  static const LinearGradient backgroundLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDFBFF), Color(0xFFFDFBFF)],
  );

  static const LinearGradient backgroundDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A0F1A),
      Color(0xFF1F0F20),
    ],
  );

  // Kart Gradienti
  static LinearGradient cardGlassLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.6),
      Colors.white.withValues(alpha: 0.3),
    ],
  );

  static LinearGradient cardGlassDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.08),
      Colors.white.withValues(alpha: 0.03),
    ],
  );

  // Mor → Pembe (Butonlar, Başlıklar)
  static const LinearGradient purplePink = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
  );

  // Pembe → Turuncu (Aksiyonlar, Check-in)
  static const LinearGradient pinkOrange = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFFF8C42)],
  );

  // Navbar Gradienti
  static LinearGradient navbarLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white.withValues(alpha: 0.7),
      Colors.white.withValues(alpha: 0.9),
    ],
  );

  static LinearGradient navbarDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      const Color(0xFF1A1A2E).withValues(alpha: 0.7),
      const Color(0xFF1A1A2E).withValues(alpha: 0.95),
    ],
  );

  // Shimmer / Dekoratif
  static const LinearGradient shimmer = LinearGradient(
    colors: [
      Color(0x00FFFFFF),
      Color(0x33FFFFFF),
      Color(0x00FFFFFF),
    ],
    stops: [0.0, 0.5, 1.0],
  );
}

// ─── 4. TİPOGRAFİ ──────────────────────────────────────────────

class NeerTypography {
  NeerTypography._();

  static const String _fontFamily = 'SFPro'; // iOS native

  // Başlıklar — Apple HIG SF Pro hiyerarşisi
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,           // Large Title
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,           // Title 1
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,           // Title 2
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,           // Title 3 (18'den 20'ye)
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,           // Headline (16'dan 17'ye)
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );

  // Gövde — Apple HIG Body/Callout/Subhead
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,           // Body
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,           // Callout (14'ten 16'ya)
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,           // Subhead (13'ten 15'e — kart içeriği için)
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.4,
  );

  // Yardımcı — Apple HIG Caption/Overline
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,           // Caption 1
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.3,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,           // Overline / label — pozitif spacing label için doğru
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    height: 1.2,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,           // Subhead ağırlığında — -0.15 negatif spacing
    fontWeight: FontWeight.w600,
    letterSpacing: -0.15,
  );

  static const TextStyle navLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,           // Caption 2
    fontWeight: FontWeight.w400,
    letterSpacing: 0.07,
  );
}

// ─── 5. BOYUTLAR VE SPACING ─────────────────────────────────────

class NeerSpacing {
  NeerSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

class NeerRadius {
  NeerRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double pill = 100; // Tam yuvarlak

  static BorderRadius get cardRadius => BorderRadius.circular(xxl);
  static BorderRadius get sheetRadius => const BorderRadius.vertical(top: Radius.circular(xxxl));
  static BorderRadius get buttonRadius => BorderRadius.circular(lg);
  static BorderRadius get chipRadius => BorderRadius.circular(pill);
  static BorderRadius get inputRadius => BorderRadius.circular(xl);
  static BorderRadius get avatarRadius => BorderRadius.circular(pill);
}

// ─── 6. ANİMASYON SABİTLERİ ─────────────────────────────────────

class NeerAnimation {
  NeerAnimation._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 400);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve bouncyCurve = Curves.easeOutBack;
  static const Curve sharpCurve = Curves.easeInOutCubic;
}

// ─── 7. GÖLGELER ────────────────────────────────────────────────

class NeerShadows {
  NeerShadows._();

  static List<BoxShadow> soft({Color? color}) => [
    BoxShadow(
      color: (color ?? NeerColors.primary).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> medium({Color? color}) => [
    BoxShadow(
      color: (color ?? NeerColors.primary).withValues(alpha: 0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> elevated({Color? color}) => [
    BoxShadow(
      color: (color ?? NeerColors.primary).withValues(alpha: 0.15),
      blurRadius: 32,
      offset: const Offset(0, 12),
      spreadRadius: -6,
    ),
  ];

  // Glow efekti (Premium, Aktif durumlar)
  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  // Buzlu cam gölgesi — ClipRRect DIŞINDA kullanılmalı
  static List<BoxShadow> glass({bool isDark = true}) => isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -6,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
}

// ─── 8. TEMA OLUŞTURUCU ─────────────────────────────────────────

class NeerTheme {
  NeerTheme._();

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: NeerColors.primary,
      scaffoldBackgroundColor: const Color(0xFFFDFBFF),
      cardColor: Colors.white,
      dividerColor: NeerColors.gray200,
      disabledColor: NeerColors.gray400,

      colorScheme: const ColorScheme.light(
        primary: NeerColors.primary,
        secondary: NeerColors.secondary,
        tertiary: NeerColors.accent,
        surface: Colors.white,
        error: NeerColors.error,
        onPrimary: Colors.white,
        onSurface: NeerColors.gray900,
        onError: Colors.white,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withValues(alpha: 0.8),
        foregroundColor: NeerColors.gray900,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: NeerTypography.h2.copyWith(color: NeerColors.gray900),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Bottom Nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.85),
        selectedItemColor: NeerColors.primary,
        unselectedItemColor: NeerColors.gray400,
        selectedLabelStyle: NeerTypography.navLabel,
        unselectedLabelStyle: NeerTypography.navLabel,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Butonlar
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeerColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: NeerRadius.buttonRadius),
          textStyle: NeerTypography.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: NeerColors.primary,
          side: const BorderSide(color: NeerColors.primaryLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: NeerRadius.buttonRadius),
          textStyle: NeerTypography.button,
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: NeerRadius.inputRadius,
          borderSide: BorderSide(color: NeerColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: NeerRadius.inputRadius,
          borderSide: BorderSide(color: NeerColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: NeerRadius.inputRadius,
          borderSide: const BorderSide(color: NeerColors.primary, width: 1.5),
        ),
        hintStyle: NeerTypography.bodyMedium.copyWith(color: NeerColors.gray400),
      ),

      // Diğer
      textTheme: _textTheme(NeerColors.gray900),
      iconTheme: const IconThemeData(color: NeerColors.gray700, size: 24),
      chipTheme: ChipThemeData(
        backgroundColor: NeerColors.primary.withValues(alpha: 0.08),
        labelStyle: NeerTypography.caption.copyWith(color: NeerColors.primary),
        shape: RoundedRectangleBorder(borderRadius: NeerRadius.chipRadius),
        side: BorderSide(color: NeerColors.primary.withValues(alpha: 0.15)),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: NeerColors.primary,
      scaffoldBackgroundColor: NeerColors.darkSurface,
      cardColor: NeerColors.darkCard,
      dividerColor: Colors.white.withValues(alpha: 0.08),
      disabledColor: NeerColors.gray500,

      colorScheme: const ColorScheme.dark(
        primary: NeerColors.primaryLight,
        secondary: NeerColors.secondaryLight,
        tertiary: NeerColors.accentLight,
        surface: NeerColors.darkCard,
        error: NeerColors.error,
        onPrimary: NeerColors.gray900,
        onSurface: Colors.white,
        onError: Colors.white,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: NeerColors.darkSurface.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: NeerTypography.h2.copyWith(color: Colors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: NeerColors.darkSurface.withValues(alpha: 0.85),
        selectedItemColor: NeerColors.primaryLight,
        unselectedItemColor: NeerColors.gray500,
        selectedLabelStyle: NeerTypography.navLabel,
        unselectedLabelStyle: NeerTypography.navLabel,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeerColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: NeerRadius.buttonRadius),
          textStyle: NeerTypography.button,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: NeerRadius.inputRadius,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: NeerRadius.inputRadius,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: NeerRadius.inputRadius,
          borderSide: const BorderSide(color: NeerColors.primaryLight, width: 1.5),
        ),
        hintStyle: NeerTypography.bodyMedium.copyWith(color: NeerColors.gray500),
      ),

      textTheme: _textTheme(Colors.white),
      iconTheme: const IconThemeData(color: Colors.white70, size: 24),
      chipTheme: ChipThemeData(
        backgroundColor: NeerColors.primary.withValues(alpha: 0.15),
        labelStyle: NeerTypography.caption.copyWith(color: NeerColors.primaryLight),
        shape: RoundedRectangleBorder(borderRadius: NeerRadius.chipRadius),
        side: BorderSide(color: NeerColors.primary.withValues(alpha: 0.2)),
      ),
    );
  }

  static TextTheme _textTheme(Color textColor) {
    return TextTheme(
      displayLarge: NeerTypography.displayLarge.copyWith(color: textColor),
      displayMedium: NeerTypography.displayMedium.copyWith(color: textColor),
      headlineLarge: NeerTypography.h1.copyWith(color: textColor),
      headlineMedium: NeerTypography.h2.copyWith(color: textColor),
      headlineSmall: NeerTypography.h3.copyWith(color: textColor),
      bodyLarge: NeerTypography.bodyLarge.copyWith(color: textColor),
      bodyMedium: NeerTypography.bodyMedium.copyWith(color: textColor),
      bodySmall: NeerTypography.bodySmall.copyWith(color: textColor.withValues(alpha: 0.7)),
      labelLarge: NeerTypography.button.copyWith(color: textColor),
      labelSmall: NeerTypography.caption.copyWith(color: textColor.withValues(alpha: 0.5)),
    );
  }
}

// ─── 9. REUSABLE GLASSMORPHISM WIDGET'LARI ──────────────────────

/// Gradient buton (Check-in, Premium, Ana aksiyonlar)
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;
  final Gradient? gradient;
  final double height;
  final double borderRadius;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
    this.gradient,
    this.height = 56,
    this.borderRadius = 16,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: isLoading ? null : (gradient ?? NeerGradients.purplePink),
        color: isLoading ? NeerColors.gray300 : null,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isLoading ? [] : NeerShadows.medium(color: NeerColors.primary),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : () { HapticFeedback.mediumImpact(); onTap(); },
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                      ],
                      Text(text, style: NeerTypography.button.copyWith(color: Colors.white)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Avatar widget (Cam çerçeveli)
class NeerAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool isOnline;
  final bool isPremium;

  const NeerAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 24,
    this.isOnline = false,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isPremium ? NeerColors.accent : Colors.white.withValues(alpha: 0.3),
              width: isPremium ? 2.5 : 2,
            ),
            boxShadow: isPremium
                ? NeerShadows.glow(NeerColors.accent)
                : NeerShadows.soft(),
          ),
          child: CircleAvatar(
            radius: radius - 2,
            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            backgroundColor: NeerColors.gray200,
            child: imageUrl.isEmpty
                ? Icon(Icons.person, size: radius * 0.8, color: NeerColors.gray400)
                : null,
          ),
        ),
        if (isOnline)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                color: NeerColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
