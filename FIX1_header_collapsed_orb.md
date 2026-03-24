# FIX 1 — Header hizalama + Collapsed arka plan + Orb dağılımı

`flutter analyze` her bölüm sonrası çalıştır.

---

## 1.1 Header içerik tab bar'a karışıyor

**Sorun:** `ProfileHeader` içindeki `Align.bottomLeft` + `Padding.bottom: 12` tab bar yüksekliğini (~44px) hesaba katmıyor.

**Düzeltme — `profile_header.dart`:**

```dart
// ProfileHeader.build() içinde Padding'i bul:
// ESKİ:
padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),

// YENİ — tab bar yüksekliği (44) + boşluk (12) = 56
padding: const EdgeInsets.fromLTRB(16, 0, 16, 56),
```

---

## 1.2 Collapsed header arka planı şeffaf kalıyor

**Sorun:** `SliverAppBar.backgroundColor` tamamen şeffaf — scroll'da içerik görünüyor.

**Düzeltme — `profile_screen.dart`:**

```dart
// SliverAppBar'da şunu bul:
// backgroundColor: Colors.transparent,  ← bu var veya yoksa ekle
// BUNUNLA DEĞİŞTİR:

SliverAppBar(
  expandedHeight: 260,
  pinned: true,
  floating: false,
  automaticallyImplyLeading: false,
  // Collapsed halde opak blur arka plan
  backgroundColor: isDark
      ? const Color(0xFF1A0F1A)
      : const Color(0xFFFDFBFF),
  // Collapsed'da title opacity animasyonu — mevcut kod değişmiyor
  title: AnimatedOpacity(...), // değişmez

  // FlexibleSpaceBar'ı ClipRect + BackdropFilter ile sar:
  flexibleSpace: ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0), // expanded'da blur yok
      child: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: ProfileHeaderBackground(
          imageUrl: displayImage,
          isDark: isDark,
          child: ProfileHeader(...),
        ),
      ),
    ),
  ),
  bottom: PreferredSize(...), // tab bar değişmez
)
```

Collapsed halde arka planın görünmesi için `SliverAppBar`'ın `backgroundColor` zaten `isDark ? 0xFF1A0F1A : 0xFFFDFBFF` olarak set edilmiş yeterli. Ek olarak collapsed title satırına `BackdropFilter` ekle:

```dart
// title widget'ını sar:
title: AnimatedOpacity(
  opacity: innerBoxIsScrolled ? 1.0 : 0.0,
  duration: const Duration(milliseconds: 200),
  child: ClipRect(
    child: BackdropFilter(
      filter: innerBoxIsScrolled
          ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
      child: Row(
        children: [
          _AvatarRingSmall(imageUrl: displayImage),
          const SizedBox(width: 10),
          Expanded(child: Text(user?.name ?? '', ...)),
          _NeerScoreRingSmall(score: user?.neerScore ?? 5.0, label: ''),
        ],
      ),
    ),
  ),
),
```

---

## 1.3 Orb dağılımı hâlâ ortada birleşiyor

**Sorun:** `widthFactor/heightFactor: 0.75–0.90` çok büyük, orb'lar merkeze sarkıyor.

**Düzeltme — `premium_background.dart`:**

```dart
// _buildOrbs() içinde sizes listesini bul:
// ESKİ:
final sizes = [0.90, 0.75, 0.80, 0.70, 0.65];

// YENİ — daha küçük, köşelerde kalıyor:
final sizes = [0.65, 0.55, 0.60, 0.52, 0.48];

// basePositions'u daha dışarı taşı:
final basePositions = [
  const Alignment(-1.4, -1.3),   // sol üst — daha dışarıda
  const Alignment(1.4, -1.2),    // sağ üst
  const Alignment(-1.3, 1.3),    // sol alt
  const Alignment(1.3, 1.2),     // sağ alt
  const Alignment(0.0, 0.1),     // merkez
];

// Hareket menzili biraz azalt — çok geniş hareket ortada birleştiriyor:
final dx = math.sin(phase * 2 * math.pi) * 0.25;  // 0.35'ten düşürdük
final dy = math.cos(phase * 2 * math.pi) * 0.22;  // 0.30'dan düşürdük
```

---

## KONTROL
- [ ] Header içerik tab bar'ın üstünde duruyor
- [ ] Collapsed'da arka plan opak (içerik arkadan görünmüyor)
- [ ] Orb'lar köşelerde, ortada birleşmiyor
- [ ] `flutter analyze` — sıfır hata
