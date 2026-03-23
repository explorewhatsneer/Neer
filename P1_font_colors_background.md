# P1 — Font + Renkler + Arka Plan

Bu dosyayı uygula, sonra `flutter analyze` çalıştır.

---

## 1. FONT DÜZELTMESİ

`lib/core/neer_design_system.dart` içinde:

```dart
// BUNU BUL:
static const String _fontFamily = '.SF Pro Display';

// BUNUNLA DEĞİŞTİR:
static const String _fontFamily = 'SFPro';
```

Bu tek satır tüm tipografiyi düzeltir. `pubspec.yaml`'da font family adı `SFPro`.

---

## 2. DARK MODE — SICAK GECE RENKLERİ

`lib/core/neer_design_system.dart` içinde:

```dart
// NeerGradients içinde backgroundDark:
static const LinearGradient backgroundDark = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF1A0F1A),
    Color(0xFF1F0F20),
  ],
);

// NeerColors içinde:
static const Color darkSurface  = Color(0xFF1A0F1A);
static const Color darkCard     = Color(0xFF241220);
static const Color darkElevated = Color(0xFF2C1A2C);
```

`lib/widgets/common/premium_background.dart` içinde `_buildOrbs()` fonksiyonunu bul:

```dart
// DARK ORB RENKLERİ — sıcak pembe/kırmızı/mor
final colors = isDark
    ? [
        const Color(0xFFB42878), // sıcak pembe-kırmızı
        const Color(0xFFDC4632), // turuncu-kırmızı
        const Color(0xFF961AB4), // mor
        const Color(0xFFC83C50), // kırmızı-pembe
        const Color(0xFFB43264), // magenta
      ]
    : [
        const Color(0xFFB428B4),
        const Color(0xFF8B5CF6),
        const Color(0xFFDC4696),
        const Color(0xFFA080E0),
        const Color(0xFFD090E8),
      ];

// ALPHA DEĞERLERİ
final alphas = isDark
    ? [0.52, 0.34, 0.38, 0.28, 0.0]   // dark: 4 orb
    : [0.13, 0.12, 0.08, 0.10, 0.07]; // light: 5 orb çok hafif

// ORB SAYISI
final orbCount = isDark ? 4 : 5;
```

---

## 3. LIGHT MODE — L5

`lib/core/neer_design_system.dart` içinde:

```dart
// backgroundLight:
static const LinearGradient backgroundLight = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFDFBFF), Color(0xFFFDFBFF)],
);
```

`NeerTheme.light()` içinde:
```dart
scaffoldBackgroundColor: const Color(0xFFFDFBFF),
```

---

## KONTROL
- [ ] `flutter analyze` — sıfır hata
- [ ] Dark modda arka plan koyu kızıl-mor tonda
- [ ] Light modda arka plan neredeyse beyaz
- [ ] Fontlar SF Pro görünüyor (device'ta fark edilir)
