# FIX 2 — GlassPanel görünürlük + Light tema yazı renkleri

---

## 2.1 GlassPanel alpha değerleri

**`lib/widgets/common/glass_panel.dart`** içinde default değerleri güncelle.
NavBar'dan "bir tık açık" demiştin — NavBar `darkAlpha: 0.35`, kartlar `0.42` olacak:

```dart
// GlassPanel default constructor:
this.darkAlpha = 0.42,   // 0.08'den artırıldı
this.lightAlpha = 0.78,  // 0.38'den artırıldı

// GlassPanel.card:
this.darkAlpha = 0.42,
this.lightAlpha = 0.78,

// GlassPanel.bento:
this.darkAlpha = 0.38,
this.lightAlpha = 0.72,

// GlassPanel.sheet:
this.darkAlpha = 0.48,
this.lightAlpha = 0.85,

// GlassPanel.appBar:
this.darkAlpha = 0.35,
this.lightAlpha = 0.70,
```

Blur sigma'yı da artır — içerik daha net ayrışsın:

```dart
// default:
this.blurSigma = 35,   // 28'den artırıldı

// .card:
this.blurSigma = 30,

// .bento:
this.blurSigma = 26,

// .sheet:
this.blurSigma = 40,

// .appBar:
this.blurSigma = 45,
```

---

## 2.2 Light tema border güncelleme

Light'ta kartlar hâlâ beyaz border kullanıyor — görünmüyor:

```dart
// GlassPanel.build() içinde resolvedBorder:
// ESKİ:
final resolvedBorder = border ?? Border.all(
  color: Colors.white.withValues(alpha: 0.18),
  width: 1,
);

// YENİ — tema-aware border:
final resolvedBorder = border ?? Border.all(
  color: isDark
      ? Colors.white.withValues(alpha: 0.14)
      : Colors.black.withValues(alpha: 0.07),
  width: 0.8,
);
```

---

## 2.3 Light tema yazı renkleri — profile_screen.dart

Light modda beyaz yazılar okunmuyor. `profile_screen.dart` içinde sabit `Colors.white` yazı rengi kullanan tüm yerleri `theme.colorScheme.onSurface` ile değiştir:

```dart
// _NeerIdentityCard, _QuestRow, _EpicQuestCard, _FrequentCard içlerinde:
// Kart başlıkları (section overline):
style: NeerTypography.caption.copyWith(
  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
  letterSpacing: 0.8,
),

// Stat sayılar:
style: NeerTypography.h2.copyWith(
  color: Theme.of(context).colorScheme.onSurface,
  fontSize: 20, fontWeight: FontWeight.w700,
),

// Stat label:
style: NeerTypography.caption.copyWith(
  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
  fontSize: 10,
),
```

**İstisna:** `ProfileHeader` içindeki yazılar (isim, username, stat) beyaz kalacak — o PP blur arka plan üzerinde. Orada değişiklik yok.

---

## 2.4 Neer Kimliği başlık tipi düzeltme

`profile_screen.dart` içindeki `_NeerIdentityCard`'da başlık:

```dart
// ESKİ:
Text(AppStrings.neerIdentityTitle,
  style: NeerTypography.caption.copyWith(
    color: Theme.of(context).disabledColor,
    letterSpacing: 0.8,
  ),
),

// YENİ — SectionHeader ile aynı tip:
SectionHeader(title: AppStrings.neerIdentityTitle),
```

`SectionHeader`'ı `profile_components.dart`'tan veya `ranking_widgets.dart`'tan import et.

---

## KONTROL
- [ ] Dark'ta kartlar net görünüyor, arka plandan ayrışıyor
- [ ] Light'ta kartlar beyaz arka plan üstünde görünüyor (border var)
- [ ] Light'ta kart içi yazılar koyu renk — okunuyor
- [ ] Neer Kimliği başlığı diğer section'larla aynı tipte
- [ ] `flutter analyze` — sıfır hata
