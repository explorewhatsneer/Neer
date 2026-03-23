## BÖLÜM 2: GLASS PANEL SİSTEMİ — `glass_panel.dart`

### 2.1 Blur ve Alpha Değerleri Güncelleme

```dart
// GlassPanel default
blurSigma = 28,   // 45'ten düşürüldü
darkAlpha = 0.08, // 0.14'ten düşürüldü
lightAlpha = 0.38, // 0.22'den artırıldı

// GlassPanel.sheet
blurSigma = 32,
darkAlpha = 0.10,
lightAlpha = 0.45,

// GlassPanel.appBar
blurSigma = 40,
darkAlpha = 0.06,
lightAlpha = 0.30,

// GlassPanel.card
blurSigma = 24,
darkAlpha = 0.08,
lightAlpha = 0.38,

// GlassPanel.bento
blurSigma = 20,
darkAlpha = 0.10,
lightAlpha = 0.35,
```

### 2.2 Border Güncelleme
Hem dark hem light modda aynı border rengi:
```dart
Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1)
```

### 2.3 GlassCard ve NeerGlass Kaldır
`neer_design_system.dart` içindeki `GlassCard` widget'ı ve `NeerGlass` sınıfı kaldırılacak.
Tüm `GlassCard(...)` kullanımlarını `GlassPanel.card(child: ...)` ile replace et.
Tüm `NeerGlass.card(isDark: isDark)` decoration kullanımlarını `GlassPanel.card` ile replace et.

---

## BÖLÜM 3: CUSTOM NAVBAR — `custom_navbar.dart`

### 3.1 Tab Sırası Değişiyor
```dart
// ESKİ
static const List<String> _labels = ['Profil', 'Chat', 'Harita', 'Feed', 'Catch'];
static const List<IconData> _icons = [person, chat_bubble, pin_drop, dynamic_feed, bolt];

// YENİ — Harita, Chat, Feed (ortada), Catch, Profil
static const List<String> _labels = ['Harita', 'Chat', 'Feed', 'Catch', 'Profil'];
static const List<IconData> _icons = [
  Icons.map_rounded,
  Icons.chat_bubble_rounded,
  Icons.dynamic_feed_rounded,
  Icons.bolt_rounded,
  Icons.person_rounded,
];
```

### 3.2 Görsel Değişiklikler
- Label'lar **kaldırılıyor** — sadece ikonlar
- Seçili state: `AnimatedContainer` kare bg kaldırılıyor → gradient alt çizgi (bar)
- Merkez buton (harita değil Feed): diğer ikonlarla **aynı boyut ve stil** — özel yükseltme yok
- Blur: `50 → 35`
- Dark alpha: `0.55 → 0.35`
- Font weight: kaldırıldı (label yok)

```dart
// _NavItem içinde yeni seçili gösterge
// Eski: AnimatedContainer with background color
// Yeni: gradient alt çizgi
Positioned(
  bottom: 6,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOutCubic,
    width: widget.isActive ? 16 : 0,
    height: 2.5,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(2),
      gradient: widget.isActive ? NeerGradients.purplePink : null,
    ),
  ),
)
```

### 3.3 Scroll Dot Animasyonu (KRİTİK)
`CustomNavBar` bir `ScrollController` alacak. Scroll davranışına göre nav bar küçük bir dot'a dönüşür.

```dart
class CustomNavBar extends StatefulWidget {
  final int activeIndex;
  final Function(int) onTabChange;
  final ScrollController? scrollController; // YENİ

  // ...
}

class _CustomNavBarState extends State<CustomNavBar>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animController;
  late Animation<double> _expandAnim; // 0.0 = dot, 1.0 = full
  bool _isDot = false;
  double _lastScrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _expandAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInCubic,
    );
    _animController.value = 1.0; // başlangıçta açık

    widget.scrollController?.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = widget.scrollController!.offset;
    final delta = offset - _lastScrollOffset;
    _lastScrollOffset = offset;

    if (delta > 8 && !_isDot) {
      // Scroll aşağı → dot'a küçül
      _collapseToDoc();
    } else if (delta < -4 && _isDot) {
      // Scroll yukarı → aç
      _expandToBar();
    }
  }

  void _collapseToDoc() {
    if (_isDot) return;
    setState(() => _isDot = true);
    _animController.reverse();
  }

  void _expandToBar() {
    if (!_isDot) return;
    setState(() => _isDot = false);
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPad + 8),
      child: AnimatedBuilder(
        animation: _expandAnim,
        builder: (context, child) {
          // Genişlik: dot=36, full=screenWidth-32
          final screenW = MediaQuery.of(context).size.width - 32;
          final width = 36.0 + (_expandAnim.value * (screenW - 36));
          final height = 36.0 + (_expandAnim.value * (58.0 - 36.0));
          final radius = 18.0 + (_expandAnim.value * (28.0 - 18.0));

          return GestureDetector(
            onTap: _isDot ? _expandToBar : null,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                  child: AnimatedContainer(
                    duration: Duration.zero,
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: _isDot
                          ? null
                          : (isDark
                              ? NeerColors.darkSurface.withValues(alpha: 0.35)
                              : Colors.white.withValues(alpha: 0.35)),
                      gradient: _isDot
                          ? NeerGradients.purplePink
                          : null,
                      borderRadius: BorderRadius.circular(radius),
                      border: Border.all(
                        color: _isDot
                            ? Colors.white.withValues(alpha: 0.22)
                            : Colors.white.withValues(alpha: 0.12),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isDot
                              ? NeerColors.primary.withValues(alpha: 0.35)
                              : Colors.black.withValues(alpha: 0.40),
                          blurRadius: _isDot ? 16 : 28,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: _isDot
                        ? Center(
                            child: Text(
                              _getActiveIcon(),
                              style: const TextStyle(fontSize: 13),
                            ),
                          )
                        : Opacity(
                            opacity: _expandAnim.value.clamp(0.0, 1.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(5, (i) => _NavItem(
                                icon: _icons[i],
                                isActive: i == widget.activeIndex,
                                isDark: isDark,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  widget.onTabChange(i);
                                },
                              )),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getActiveIcon() {
    const emojis = ['🗺️', '💬', '⚡', '🎯', '👤'];
    return emojis[widget.activeIndex];
  }
}
```

### 3.4 Bildirim Dot
Chat ve Catch sekmeleri için bildirim noktası — mevcut sistemle entegre:

```dart
// _NavItem içine ekle
if (hasNotification)
  Positioned(
    top: 6, right: 4,
    child: Container(
      width: 6, height: 6,
      decoration: BoxDecoration(
        color: NeerColors.secondary,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? NeerColors.darkSurface : Colors.white,
          width: 1.5,
        ),
      ),
    ),
  ),
```

### 3.5 main_layout.dart Güncelleme
`main_layout.dart` içinde her sekme için `ScrollController` oluştur ve `CustomNavBar`'a geç:

```dart
// Her tab için ScrollController
final Map<int, ScrollController> _scrollControllers = {
  0: ScrollController(), // Harita
  1: ScrollController(), // Chat
  2: ScrollController(), // Feed
  3: ScrollController(), // Catch
  4: ScrollController(), // Profil
};

// CustomNavBar çağrısında
CustomNavBar(
  activeIndex: _activeIndex,
  onTabChange: _onTabChange,
  scrollController: _scrollControllers[_activeIndex],
)
```

---

