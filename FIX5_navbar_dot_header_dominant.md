# FIX 5 — NavBar dot ikon/renk + Header dominant renk

---

## 5.1 NavBar dot — renk değişmesin + ikon göster

**`lib/screens/custom_navbar.dart`** içinde `AnimatedBuilder > builder`:

Dot halindeki `Container` decoration'ı bul ve güncelle:

```dart
// _isDot true iken Container:
decoration: BoxDecoration(
  // Gradient ve renk değişimi YOK — arka plan sabit kalıyor
  color: isDark
      ? NeerColors.darkSurface.withValues(alpha: 0.75)
      : Colors.white.withValues(alpha: 0.80),
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(
    color: isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.10),
    width: 1,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ],
),
// child — dot içinde aktif sekme ikonu
child: _isDot
    ? Center(
        child: Icon(
          _icons[widget.activeIndex],   // aktif sekmenin ikonu
          size: 18,
          color: isDark
              ? Colors.white.withValues(alpha: 0.75)
              : Colors.black.withValues(alpha: 0.60),
        ),
      )
    : Opacity(
        opacity: t,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) => _NavItem(...)),
        ),
      ),
```

`_icons` listesi zaten var — `_emojis` listesini kaldır, artık kullanılmıyor.

---

## 5.2 Header arka planı — Dominant renk (D1 stili, fade YOK)

**Sorun:** Şu an PP blur (D2) kullanılıyor. Bunu dominant renk (D1) — PP'den renk çıkar, solid renk blok, fade yok — ile değiştir.

**`pubspec.yaml`'a ekle** (yoksa):
```yaml
palette_generator: ^0.3.3
```

**`lib/widgets/profile/profile_header.dart`** içinde `ProfileHeaderBackground` widget'ını tamamen değiştir:

```dart
import 'package:palette_generator/palette_generator.dart';

/// D1: PP dominant rengi — solid blok, aşağı fade YOK
class ProfileHeaderBackground extends StatefulWidget {
  final String imageUrl;
  final bool isDark;
  final Widget child;

  const ProfileHeaderBackground({
    super.key,
    required this.imageUrl,
    required this.isDark,
    required this.child,
  });

  @override
  State<ProfileHeaderBackground> createState() =>
      _ProfileHeaderBackgroundState();
}

class _ProfileHeaderBackgroundState
    extends State<ProfileHeaderBackground> {
  Color? _dominantColor;

  @override
  void initState() {
    super.initState();
    _extractColor();
  }

  @override
  void didUpdateWidget(ProfileHeaderBackground old) {
    super.didUpdateWidget(old);
    if (old.imageUrl != widget.imageUrl) _extractColor();
  }

  Future<void> _extractColor() async {
    if (widget.imageUrl.isEmpty) return;
    try {
      final generator = await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.imageUrl),
        maximumColorCount: 5,
      );
      final color = generator.darkMutedColor?.color
          ?? generator.mutedColor?.color
          ?? generator.dominantColor?.color;
      if (color != null && mounted) {
        setState(() => _dominantColor = color);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // Fallback renk — dominant çekilene kadar
    final fallback = widget.isDark
        ? const Color(0xFF1A0F1A)
        : const Color(0xFFFDFBFF);

    final bgColor = _dominantColor != null
        ? (widget.isDark
            // Dark modda dominant rengi karart
            ? Color.lerp(_dominantColor!, Colors.black, 0.45)!
            // Light modda dominant rengi açıklaştır
            : Color.lerp(_dominantColor!, Colors.white, 0.60)!)
        : fallback;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Dominant renk — solid, fade yok
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            color: bgColor,
          ),
        ),
        // Hafif overlay — yazı okunabilirliği
        Positioned.fill(
          child: Container(
            color: widget.isDark
                ? Colors.black.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.15),
          ),
        ),
        // İçerik
        widget.child,
      ],
    );
  }
}
```

---

## KONTROL
- [ ] NavBar dot'a dönüşünce renk değişmiyor
- [ ] Dot içinde aktif sekmenin ikonu görünüyor
- [ ] PP'den dominant renk çıkarılıyor, header arka planı değişiyor
- [ ] Dominant renk dark'ta karanlık, light'ta açık
- [ ] Renk geçişi smooth animasyonlu (400ms)
- [ ] `flutter analyze` — sıfır hata
