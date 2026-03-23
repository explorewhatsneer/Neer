# P3 — Nav Bar Dot + Rozet Preview

P1 ve P2 tamamlandıktan sonra uygula.

---

## 1. NAV BAR — Dot halinde renk değişmesin

`lib/screens/custom_navbar.dart` içinde `AnimatedBuilder > builder` içindeki `Container` decoration:

```dart
// _isDot true iken:
decoration: BoxDecoration(
  // gradient KALDIRILDI — renk değişmiyor
  color: isDark
      ? NeerColors.darkSurface.withValues(alpha: 0.80)
      : Colors.white.withValues(alpha: 0.80),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(
    color: Colors.white.withValues(alpha: 0.15),
    width: 1,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.28),
      blurRadius: 14,
      offset: const Offset(0, 5),
    ),
  ],
),
// child: dot halinde boş (emoji yok)
child: _isDot ? const SizedBox.shrink() : Opacity( ... ),
```

Tam if-else bloğu:
```dart
child: _isDot
    ? const SizedBox.shrink()
    : Opacity(
        opacity: t,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) => _NavItem( ... )),
        ),
      ),
```

---

## 2. ROZET PREVİEW — ??? kaldırıldı

`profile_screen.dart` içindeki `_BadgeVitrin` > `Row` > `all.map()` içinde:

```dart
// İkon — kazanılmışsa renkli, kilitliyse grayscale
Container(
  width: 44, height: 44,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    color: isEarned
        ? Theme.of(context).primaryColor.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.04),
    border: Border.all(
      color: isEarned
          ? Theme.of(context).primaryColor.withValues(alpha: 0.45)
          : Colors.white.withValues(alpha: 0.08),
    ),
  ),
  child: Center(
    child: isEarned
        ? Text(badge['icon'] ?? '🏅', style: const TextStyle(fontSize: 20))
        : ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0, 0, 0, 0.30, 0,
            ]),
            child: Text(badge['icon'] ?? '🏅', style: const TextStyle(fontSize: 20)),
          ),
  ),
),

// İsim — her zaman görünür
Text(
  badge['name_tr'] ?? badge['name_en'] ?? '',
  style: NeerTypography.caption.copyWith(
    color: isEarned
        ? Theme.of(context).primaryColor
        : Theme.of(context).disabledColor.withValues(alpha: 0.45),
    fontSize: 9,
  ),
),
```

---

## KONTROL
- [ ] `flutter analyze` — sıfır hata
- [ ] Nav bar dot'a dönünce renk değişmiyor
- [ ] Dot içinde emoji/ikon yok — sade pill
- [ ] Rozet vitrininde ??? yok, ikon her zaman görünür
- [ ] Kazanılmış rozetler renkli, kilitliler grayscale soluk
