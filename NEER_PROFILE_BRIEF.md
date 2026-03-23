# NEER — Profil Yeniden Tasarım Brief v2.0

Bu doküman Claude Code'a verilecek tek referans kaynaktır. Tüm kararlar burada yazılı olduğu şekilde uygulanacaktır. Kodlamaya başlamadan önce bu dokümanı tamamen oku.

---

## GENEL KURALLAR

- Flutter + Dart, iOS hedefli
- Backend: Supabase (proje ID: `celkzibnupgacoesaxse`)
- Tasarım sistemi: `lib/core/neer_design_system.dart` — tek referans
- `.withOpacity()` **ASLA** kullanma → her zaman `.withValues(alpha: ...)`
- `GlassCard` ve `NeerGlass.card()` artık **kullanılmıyor** → her yerde `GlassPanel` kullan
- Tüm string değişiklikleri `lib/core/app_strings.dart` üzerinden

---

## BÖLÜM 1: ARKA PLAN SİSTEMİ — `premium_background.dart`

### 1.1 Orb Pozisyonları (KRİTİK)
Mevcut `basePositions` değerleri orb'ları merkeze sıkıştırıyor. Düzelt:

```dart
// ESKİ
final basePositions = [
  const Alignment(-0.7, -0.5),
  const Alignment(0.8, -0.4),
  const Alignment(-0.4, 0.6),
  const Alignment(0.5, 0.7),
  const Alignment(0.0, 0.0),
];

// YENİ — köşelere yay
final basePositions = [
  const Alignment(-1.1, -1.0),  // sol üst köşe dışı
  const Alignment(1.1, -0.9),   // sağ üst köşe dışı
  const Alignment(-1.0, 1.0),   // sol alt köşe dışı
  const Alignment(1.0, 1.0),    // sağ alt köşe dışı
  const Alignment(0.0, 0.1),    // merkez (sabit)
];

// ESKİ hareket — çok dar
final dx = math.sin(phase * 2 * math.pi) * 0.18;
final dy = math.cos(phase * 2 * math.pi) * 0.12;

// YENİ hareket — geniş, hissedilir
final dx = math.sin(phase * 2 * math.pi) * 0.35;
final dy = math.cos(phase * 2 * math.pi) * 0.30;
```

### 1.2 Dark Mode Orb Sayısı ve Alpha
Dark mode'da 5 orb yerine 3 orb, alpha değerleri düşük:

```dart
// _buildOrbs() içinde isDark kontrolü ekle
if (isDark) {
  // Sadece ilk 3 orb — alpha 0.20-0.28
  final darkAlphas = [0.26, 0.22, 0.20];
  // i > 2 ise skip
}

// Dark mode alpha değerleri
final alphas = isDark
    ? [0.26, 0.22, 0.20, 0.0, 0.0]   // 3 orb
    : [0.55, 0.45, 0.50, 0.40, 0.42]; // 5 orb
```

### 1.3 Ekrana Göre animate Parametresi
`GradientScaffold` çağrılarını güncelle:

| Ekran | animate |
|-------|---------|
| profile_screen | `true` |
| settings_screen | `true` |
| premium_screen | `true` |
| onboarding | `true` |
| chat_screen, group_chat_screen | `false` |
| feed_screen | `false` |
| notifications_screen | `false` |
| map_screen | arka plan **yok** — transparent scaffold |

---

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

## BÖLÜM 4: SECTION HEADER — `ranking_widgets.dart`

`SectionHeader` widget'ını güncelle:

```dart
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onActionTap;

  const SectionHeader({super.key, required this.title, this.onActionTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        children: [
          // Sol gradient accent çizgi
          Container(
            width: 3, height: 16,
            decoration: BoxDecoration(
              gradient: NeerGradients.purplePink,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: NeerTypography.h3.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (onActionTap != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onActionTap!();
              },
              child: Text(
                AppStrings.seeAll,
                style: NeerTypography.caption.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

## BÖLÜM 5: PROFILE HEADER — `profile_header.dart`

### 5.1 ProfileHeader — Compact Identity (C Tasarımı)
Mevcut ProfileHeader'ı tamamen yeniden yaz:

**Expanded hal:**
- Satır 1: Avatar (72px, frosted ring) + İsim/username + NeerScoreRing(size: 52)
- Satır 2: Bio (varsa)
- Satır 3: Stats pill'ler (takipçi sayısı, mekan sayısı, aktif gün)
- Ambient blur arka plan **KALDIRILDI** — sadece GradientScaffold arka planı

```dart
class ProfileHeader extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String username;
  final String bio;
  final String followersCount;
  final String followingCount;
  final int checkInCount;     // YENİ
  final int activeDays;       // YENİ
  final double neerScore;     // trust_score yerine
  final String neerScoreLabel; // YENİ

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ROW 1: Avatar + Meta + NeerScore
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AvatarRing(imageUrl: imageUrl, size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: NeerTypography.h2.copyWith(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700,
                      shadows: _shadows,
                    )),
                    const SizedBox(height: 2),
                    Text('@$username', style: NeerTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      shadows: _shadows,
                    )),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _NeerScoreRing(score: neerScore, label: neerScoreLabel, size: 52),
            ],
          ),
          
          // ROW 2: Bio
          if (bio.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(bio, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: NeerTypography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
                shadows: _shadowsLight,
              ),
            ),
          ],

          // ROW 3: Stat pill'ler
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: [
              _StatPill(value: followersCount, label: AppStrings.followers),
              _StatPill(value: checkInCount.toString(), label: 'mekan'),
              _StatPill(value: activeDays.toString(), label: 'gün'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value, label;
  const _StatPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: NeerTypography.caption.copyWith(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12,
          )),
          const SizedBox(width: 3),
          Text(label, style: NeerTypography.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.55), fontSize: 11,
          )),
        ],
      ),
    );
  }
}
```

### 5.2 _NeerScoreRing — Trust Score → Neer Score

```dart
class _NeerScoreRing extends StatelessWidget {
  final double score;
  final String label;  // YENİ
  final double size;
  
  // ...

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size, height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1.0, strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.10)),
              ),
              CircularProgressIndicator(
                value: (score / 10.0).clamp(0.0, 1.0),
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(color),
                strokeCap: StrokeCap.round,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    score.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.white, fontSize: size < 40 ? 10 : 12,
                      fontWeight: FontWeight.w800, height: 1.0,
                    ),
                  ),
                  if (size >= 44) // sadece büyük halinde label göster
                    Text(
                      label,
                      style: TextStyle(
                        color: color, fontSize: 7,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

### 5.3 SliverAppBar Collapsed Hali

```dart
SliverAppBar(
  expandedHeight: 300.0,
  pinned: true,
  backgroundColor: Colors.transparent,
  elevation: 0,
  // Collapsed header
  title: AnimatedOpacity(
    opacity: innerBoxIsScrolled ? 1.0 : 0.0,
    duration: const Duration(milliseconds: 200),
    child: Row(
      children: [
        _AvatarRing(imageUrl: displayImage, size: 28),
        const SizedBox(width: 10),
        Text(user?.name ?? '', style: NeerTypography.bodySmall.copyWith(
          color: Colors.white, fontWeight: FontWeight.w600,
        )),
        const Spacer(),
        // NeerScoreRing küçük boyut
        _NeerScoreRing(
          score: user?.trustScore ?? 5.0,
          label: user?.neerScoreLabel ?? 'Standart',
          size: 32,
        ),
      ],
    ),
  ),
  flexibleSpace: FlexibleSpaceBar(
    background: ProfileHeader(...),
  ),
  // TAB BAR — sol hizalı gradient underline
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(44),
    child: _ProfileTabBar(controller: _mainTabController),
  ),
)

// TAB BAR WIDGET
class _ProfileTabBar extends StatelessWidget {
  final TabController controller;
  const _ProfileTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.20)
            : Colors.white.withValues(alpha: 0.10),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.10), width: 0.5),
        ),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,   // SOL HİZALI
        padding: const EdgeInsets.only(left: 16),
        labelPadding: const EdgeInsets.only(right: 20),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: 2,
            color: NeerColors.primary,
          ),
          insets: const EdgeInsets.only(bottom: 0),
        ),
        // Gradient indicator için custom
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.38),
        labelStyle: NeerTypography.caption.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
        unselectedLabelStyle: NeerTypography.caption.copyWith(fontWeight: FontWeight.w400, fontSize: 13),
        tabs: [
          Tab(text: AppStrings.profileTab),
          Tab(text: AppStrings.activityTab),
          Tab(text: AppStrings.galleryTab),
        ],
        // Gradient underline için custom indicator painter — GradientTabIndicator class yaz
      ),
    );
  }
}
```

**GradientTabIndicator yazılacak:**
```dart
class GradientTabIndicator extends Decoration {
  final double height;
  final BorderRadius borderRadius;
  const GradientTabIndicator({this.height = 2.5, this.borderRadius = const BorderRadius.all(Radius.circular(2))});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChange]) =>
      _GradientTabPainter(height: height, borderRadius: borderRadius);
}

class _GradientTabPainter extends BoxPainter {
  final double height;
  final BorderRadius borderRadius;
  _GradientTabPainter({required this.height, required this.borderRadius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = Rect.fromLTWH(
      offset.dx, offset.dy + (configuration.size?.height ?? 0) - height,
      configuration.size?.width ?? 0, height,
    );
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
      ).createShader(rect);
    canvas.drawRRect(borderRadius.toRRect(rect), paint);
  }
}
```

---

## BÖLÜM 6: PROFILE SCREEN TAB 1 — `profile_screen.dart`

### 6.1 İçerik Hiyerarşisi (SIRAYA UYMAK ZORUNLU)
1. Bento Dashboard (quest + not + yorum)
2. Neer Kimliği kartı
3. Rozet Vitrini
4. Görevler Preview
5. Favoriler (Stacked Carousel)
6. Sık Uğrananlar (A Tasarımı)

### 6.2 SupabaseService Yeni Metodlar
`supabase_service.dart`'a ekle:

```dart
// Kullanıcı rozetleri
Future<List<Map<String, dynamic>>> getUserBadges(String uid) async {
  try {
    final response = await _supabase
        .from('user_badges')
        .select('*, badge_definitions(*)')
        .eq('user_id', uid)
        .order('earned_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  } catch (e) { return []; }
}

// Tüm rozet tanımları
Future<List<Map<String, dynamic>>> getAllBadgeDefinitions() async {
  try {
    final response = await _supabase
        .from('badge_definitions')
        .select()
        .order('sort_order');
    return List<Map<String, dynamic>>.from(response);
  } catch (e) { return []; }
}

// Aktif görevler
Future<List<Map<String, dynamic>>> getUserActiveQuests(String uid) async {
  try {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    final weekNum = _getWeekNumber(today);
    final weekStr = '${today.year}-W${weekNum.toString().padLeft(2,'0')}';

    final response = await _supabase
        .from('quest_definitions')
        .select('*, user_quests!left(progress, is_completed, period)')
        .order('sort_order');
    return List<Map<String, dynamic>>.from(response);
  } catch (e) { return []; }
}

// Neer Kimliği istatistikleri
Future<Map<String, dynamic>> getUserIdentityStats(String uid) async {
  try {
    final result = await _supabase.rpc('get_user_identity_stats', params: {'target_uid': uid});
    return Map<String, dynamic>.from(result as Map);
  } catch (e) { return {'total_places': 0, 'total_photos': 0, 'active_days': 0}; }
}

// Isı haritası
Future<List<Map<String, dynamic>>> getUserHeatmapPoints(String uid, {String period = 'all'}) async {
  try {
    final result = await _supabase.rpc('get_user_heatmap_points', params: {
      'target_uid': uid,
      'period_filter': period,
    });
    return List<Map<String, dynamic>>.from(result);
  } catch (e) { return []; }
}

// Quest ilerleme güncelle
Future<Map<String, dynamic>> updateQuestProgress(String uid, String questId, {int increment = 1}) async {
  try {
    final result = await _supabase.rpc('update_quest_progress', params: {
      'p_user_id': uid,
      'p_quest_id': questId,
      'p_increment': increment,
    });
    return Map<String, dynamic>.from(result as Map);
  } catch (e) { return {}; }
}

int _getWeekNumber(DateTime date) {
  final startOfYear = DateTime(date.year, 1, 1);
  final dayOfYear = date.difference(startOfYear).inDays;
  return ((dayOfYear + startOfYear.weekday - 1) / 7).ceil();
}
```

### 6.3 Neer Kimliği Kartı (YENİ Widget)

```dart
class _NeerIdentityCard extends StatelessWidget {
  final Future<Map<String, dynamic>> statsFuture;
  final int photoCount;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: statsFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data;
        return AnimatedPress(
          onTap: () {},
          child: GlassPanel.card(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Neer Kimliği',
                  style: NeerTypography.overline.copyWith(
                    color: Theme.of(context).disabledColor,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _IdentityStat(
                      value: stats?['total_places']?.toString() ?? '—',
                      label: 'mekan',
                    ),
                    _IdentityStat(
                      value: photoCount.toString(),
                      label: 'kare',
                    ),
                    _IdentityStat(
                      value: stats?['total_cities']?.toString() ?? '—',
                      label: 'şehir',
                    ),
                    _IdentityStat(
                      value: stats?['active_days']?.toString() ?? '—',
                      label: 'gün',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _IdentityStat extends StatelessWidget {
  final String value, label;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: NeerTypography.h2.copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: NeerTypography.overline.copyWith(color: Theme.of(context).disabledColor)),
        ],
      ),
    );
  }
}
```

### 6.4 Rozet Vitrini (YENİ Widget)

```dart
class _BadgeVitrin extends StatelessWidget {
  final List<Map<String, dynamic>> earnedBadges;
  final List<Map<String, dynamic>> allBadges;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return GlassPanel.card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Rozetler', onActionTap: onSeeAll),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: allBadges.map((badge) {
                final isEarned = earnedBadges.any((e) => e['badge_id'] == badge['id']);
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _BadgePill(badge: badge, isEarned: isEarned),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final Map<String, dynamic> badge;
  final bool isEarned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedPress(
      onTap: () => _showBadgeDetail(context),
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEarned
                  ? theme.primaryColor.withValues(alpha: 0.18)
                  : Colors.white.withValues(alpha: 0.04),
              border: Border.all(
                color: isEarned
                    ? theme.primaryColor.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                badge['icon'] ?? '🏅',
                style: TextStyle(
                  fontSize: 20,
                  color: isEarned ? null : Colors.transparent,
                ).merge(isEarned ? null : const TextStyle()),
              ),
            ),
          ).also((_) => isEarned ? null : ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0.2126, 0.7152, 0.0722, 0, 0,
              0, 0, 0, 0.3, 0,
            ]),
          )),
          const SizedBox(height: 4),
          Text(
            isEarned ? (badge['name_tr'] ?? '') : '???',
            style: NeerTypography.overline.copyWith(
              color: isEarned
                  ? theme.primaryColor
                  : theme.disabledColor,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetail(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BadgeDetailSheet(badge: badge, isEarned: isEarned),
    );
  }
}
```

### 6.5 Görevler Preview (YENİ Widget)

```dart
class _QuestPreview extends StatelessWidget {
  final List<Map<String, dynamic>> quests;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Günlük görevler (ilk 2), en ilerlemiş haftalık (1 tane), aktif epik (1 tane)
    final dailyQuests = quests.where((q) => q['type'] == 'daily').take(2).toList();
    final weeklyTop = quests.where((q) => q['type'] == 'weekly').toList()
      ..sort((a, b) => ((b['user_quests']?.first?['progress'] ?? 0) as int)
          .compareTo((a['user_quests']?.first?['progress'] ?? 0) as int));
    final epicActive = quests.where((q) =>
        q['type'] == 'epic' &&
        (q['user_quests']?.first?['is_completed'] != true)).take(1).toList();

    return GlassPanel.card(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: AppStrings.questsTitle, onActionTap: onSeeAll),
          const SizedBox(height: 8),
          // Günlük
          ...dailyQuests.map((q) => _QuestRow(quest: q, type: 'daily')),
          // Haftalık
          if (weeklyTop.isNotEmpty) _QuestRow(quest: weeklyTop.first, type: 'weekly'),
          // Epik
          if (epicActive.isNotEmpty) ...[
            const SizedBox(height: 6),
            _EpicQuestCard(quest: epicActive.first),
          ],
        ],
      ),
    );
  }
}

class _QuestRow extends StatelessWidget {
  final Map<String, dynamic> quest;
  final String type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (quest['user_quests']?.first?['progress'] ?? 0) as int;
    final target = (quest['target_count'] ?? 1) as int;
    final isCompleted = quest['user_quests']?.first?['is_completed'] == true;
    final ratio = target > 0 ? progress / target : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Check circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 18, height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? theme.primaryColor.withValues(alpha: 0.25)
                  : Colors.transparent,
              border: Border.all(
                color: isCompleted
                    ? theme.primaryColor
                    : Colors.white.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: isCompleted
                ? Icon(Icons.check, size: 10, color: theme.primaryColor)
                : null,
          ),
          const SizedBox(width: 10),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.lang == 'tr'
                      ? (quest['title_tr'] ?? '')
                      : (quest['title_en'] ?? ''),
                  style: NeerTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted
                        ? theme.disabledColor
                        : null,
                  ),
                ),
                const SizedBox(height: 3),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    minHeight: 2,
                    backgroundColor: Colors.white.withValues(alpha: 0.07),
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted ? NeerColors.success : theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // TS reward
          Text(
            isCompleted ? '+${quest['ts_reward']} ✓' : '+${quest['ts_reward']}',
            style: NeerTypography.caption.copyWith(
              color: isCompleted ? NeerColors.success : NeerColors.success.withValues(alpha: 0.65),
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _EpicQuestCard extends StatelessWidget {
  final Map<String, dynamic> quest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (quest['user_quests']?.first?['progress'] ?? 0) as int;
    final target = (quest['target_count'] ?? 1) as int;
    final ratio = target > 0 ? progress / target : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('EPİK', style: NeerTypography.overline.copyWith(
                  color: theme.primaryColor, fontSize: 9, letterSpacing: 0.8,
                )),
              ),
              const Spacer(),
              Text('+${quest['ts_reward']} TS',
                style: NeerTypography.caption.copyWith(
                  color: NeerColors.success.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                )),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.lang == 'tr' ? (quest['title_tr'] ?? '') : (quest['title_en'] ?? ''),
            style: NeerTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: Colors.white.withValues(alpha: 0.07),
              valueColor: AlwaysStoppedAnimation(theme.primaryColor),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$progress / $target',
            style: NeerTypography.overline.copyWith(color: theme.disabledColor),
          ),
        ],
      ),
    );
  }
}
```

### 6.6 Sık Uğrananlar — A Tasarımı

```dart
class _FrequentPlacesSection extends StatelessWidget {
  final List<Map<String, dynamic>> places;
  final VoidCallback onSeeAll;
  final Function(String id, String name, String img) onTap;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return FriendEmptyCard(
      icon: Icons.explore_off_rounded,
      title: 'Henüz mekan yok',
      subtitle: 'Sık ziyaretler burada listelenir.',
    );

    return Column(
      children: [
        SectionHeader(title: AppStrings.frequentPlacesTitle, onActionTap: onSeeAll),
        _FrequentCard(place: places[0], rank: 1, height: 72),
        const SizedBox(height: 5),
        if (places.length > 1) _FrequentCard(place: places[1], rank: 2, height: 52),
        if (places.length > 2) ...[
          const SizedBox(height: 5),
          _FrequentCard(place: places[2], rank: 3, height: 52),
        ],
      ],
    );
  }
}

class _FrequentCard extends StatelessWidget {
  final Map<String, dynamic> place;
  final int rank;
  final double height;

  @override
  Widget build(BuildContext context) {
    final name = place['place_name'] ?? place['name'] ?? '';
    final img = place['image_url'] ?? place['image'] ?? '';
    final visits = (place['visit_count'] as num?)?.toInt() ?? 0;

    return AnimatedPress(
      onTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rank == 1 ? 14 : 12),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Arka plan fotoğraf veya gradient
              img.isNotEmpty
                  ? AppCachedImage.cover(imageUrl: img)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _rankGradient(rank),
                        ),
                      ),
                    ),
              // Overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xAA000000), Color(0x22000000)],
                  ),
                ),
              ),
              // İçerik
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: rank == 1 ? 14 : 10,
                ),
                child: Row(
                  children: [
                    // Rank
                    Text(
                      rank == 1 ? '1' : rank.toString(),
                      style: TextStyle(
                        color: rank == 1
                            ? const Color(0xFFFFD700).withValues(alpha: 0.9)
                            : Colors.white.withValues(alpha: 0.4),
                        fontSize: rank == 1 ? 22 : 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Thumbnail
                    if (img.isNotEmpty)
                      Container(
                        width: rank == 1 ? 36 : 28,
                        height: rank == 1 ? 36 : 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: AppCachedImage.cover(imageUrl: img),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // İsim + ziyaret
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: rank == 1 ? 0.9 : 0.8),
                              fontSize: rank == 1 ? 14 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (rank == 1) ...[
                            const SizedBox(height: 2),
                            Text('$visits ziyaret',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.45),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Visit pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: rank == 1
                            ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.11),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: rank == 1
                              ? const Color(0xFFFFD700).withValues(alpha: 0.28)
                              : Colors.white.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Text(
                        visits.toString(),
                        style: TextStyle(
                          color: rank == 1
                              ? const Color(0xFFFFD700).withValues(alpha: 0.9)
                              : Colors.white.withValues(alpha: 0.65),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _rankGradient(int rank) {
    switch (rank) {
      case 1: return [const Color(0xFF8B5CF6).withValues(alpha: 0.55), const Color(0xFFEC4899).withValues(alpha: 0.38)];
      case 2: return [const Color(0xFF3B82F6).withValues(alpha: 0.42), const Color(0xFF8B5CF6).withValues(alpha: 0.28)];
      default: return [const Color(0xFFEC4899).withValues(alpha: 0.38), const Color(0xFFFF8C42).withValues(alpha: 0.25)];
    }
  }
}
```

---

## BÖLÜM 7: YENİ EKRANLAR

### 7.1 Quest + Rozet Ekranı — `quests_badges_screen.dart`
Profildeki "Tümünü gör" / "Tümü" tıklamalarından açılır. 2 tab:

**Tab 1 — Görevler:**
- Filtre pill'leri: Tümü, Günlük, Haftalık, Epik, Tamamlanan
- Her quest kartı: İsim, açıklama, progress bar, `X / Y` sayaç, TS ödülü, rozet bağlantısı
- Tamamlananlar soluk (opacity: 0.45)
- Epik → aktif olan vurgulu (primary color border), diğerleri kilitli

**Tab 2 — Rozetler:**
- 3 sütun grid
- Kazanılmış: renkli, border primary
- Kilitli: grayscale, opacity 0.3, isim "???"
- Tıklanınca `showModalBottomSheet` — rozet adı, açıklama, nasıl kazanılır, kategori (kalıcı/haftalık/epik/trust)

### 7.2 Notlarım Ekranı — `notes_screen.dart`
Bento'daki "son not" kartına tıklanınca açılır.
- Liste: Tarih + mekan adı + not içeriği (ilk 2 satır)
- Tıklanınca full not görünür (bottom sheet)
- Boşsa zero state: "Not Defteri Boş"

### 7.3 Puanlarım Ekranı — `reviews_screen.dart`
Bento'daki "son yorum" kartına tıklanınca açılır.
- Her kart: `DetailedReviewCard` (zaten genişleyip kapanabiliyor)
- Skor rengi (yeşil/sarı/kırmızı) ile sıralama
- Boşsa zero state: "Değerlendirme Yok"

### 7.4 Sık Uğrananlar Tam Ekran — `frequent_places_screen.dart`
- Aynı A tasarımı — 1. kart büyük, 2-10 orta boy, opacity soluklaşıyor
- Sağ üstte toplam sayı: "10 mekan"

### 7.5 Isı Haritası Widget — `heatmap_widget.dart`
Profile Tab 1'de Sık Uğrananlar'ın altına eklenir.

```dart
class HeatmapWidget extends StatefulWidget {
  final String userId;
}

class _HeatmapWidgetState extends State<HeatmapWidget> {
  String _period = '30d';
  final _periods = ['7d', '30d', '6m', 'all'];
  final _periodLabels = {'7d': '7 gün', '30d': '30 gün', '6m': '6 ay', 'all': 'Tümü'};

  @override
  Widget build(BuildContext context) {
    return GlassPanel.card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + filtre pills
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                Text('Şehir Haritam', style: NeerTypography.h3),
                const Spacer(),
                ..._periods.map((p) => GestureDetector(
                  onTap: () => setState(() => _period = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _period == p
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _period == p
                            ? Theme.of(context).primaryColor.withValues(alpha: 0.45)
                            : Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      _periodLabels[p]!,
                      style: NeerTypography.overline.copyWith(
                        color: _period == p
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
          // Harita
          FutureBuilder<List<Map<String, dynamic>>>(
            future: SupabaseService().getUserHeatmapPoints(widget.userId, period: _period),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _HeatmapEmpty();
              }
              return _HeatmapMap(points: snapshot.data!);
            },
          ),
        ],
      ),
    );
  }
}

// flutter_map ile MapTiler üzerinde çizim
class _HeatmapMap extends StatelessWidget {
  final List<Map<String, dynamic>> points;

  @override
  Widget build(BuildContext context) {
    // En yoğun mekan center olarak kullan
    final center = points.first;
    final maxVisit = points.map((p) => (p['visit_count'] as num).toInt()).reduce(math.max);

    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(
              (center['latitude'] as num).toDouble(),
              (center['longitude'] as num).toDouble(),
            ),
            initialZoom: 13,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://api.maptiler.com/maps/dataviz-dark/{z}/{x}/{y}.png?key={api_key}',
              additionalOptions: const {'api_key': 'YOUR_MAPTILER_KEY'},
            ),
            // Isı noktaları — büyüklük visit_count'a göre
            CircleLayer(
              circles: points.map((p) {
                final visits = (p['visit_count'] as num).toInt();
                final intensity = visits / maxVisit;
                return CircleMarker(
                  point: LatLng(
                    (p['latitude'] as num).toDouble(),
                    (p['longitude'] as num).toDouble(),
                  ),
                  radius: 15 + (intensity * 35),
                  color: Color.lerp(
                    const Color(0x448B5CF6),
                    const Color(0xCC8B5CF6),
                    intensity,
                  )!,
                  borderColor: const Color(0x668B5CF6),
                  borderStrokeWidth: 1,
                  useRadiusInMeter: true,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## BÖLÜM 8: ZERO STATES

Her bölüm için zero state mesajları (AppStrings'e ekle):

| Bölüm | TR | EN |
|-------|----|----|
| Isı haritası | Check-in yaptıkça şehirdeki ayak izin burada belirmeye başlar. | Your city footprint will appear here as you check in. |
| Rozetler | Görevleri tamamla, ilk rozetini kazan. | Complete quests to earn your first badge. |
| Görevler | İlk check-in'ini yapınca günlük görevler başlıyor. | Complete your first check-in to start daily quests. |
| Neer Kimliği | Dışarı çık, check-in yap. Bu sayılar seninle büyür. | Go out, check in. These numbers grow with you. |
| Favoriler | Gittiğin yerlerden favori ekle, burada saklansın. | Add favorites from venues you visit. |
| Sık Gidilenler | Bir mekana tekrar tekrar git — liste kendiliğinden oluşur. | Visit a venue repeatedly — the list builds itself. |

---

## BÖLÜM 9: APPSTRINGS GÜNCELLEMELERİ

`lib/core/app_strings.dart`'a ekle/güncelle:

```dart
// Trust Score → Neer Score
static String get neerScore => lang == 'tr' ? "Neer Score" : "Neer Score";
static String get neerScoreLabel => lang == 'tr' ? "Neer Skoru" : "Neer Score";
static String get neerScoreElite => "Elite";
static String get neerScoreExpert => lang == 'tr' ? "Uzman" : "Expert";
static String get neerScoreTrusted => lang == 'tr' ? "Güvenilir" : "Trusted";
static String get neerScoreStandard => lang == 'tr' ? "Standart" : "Standard";
static String get neerScoreLimited => lang == 'tr' ? "Kısıtlı" : "Limited";

// Yeni ekranlar
static String get badgesTitle => lang == 'tr' ? "Rozetler" : "Badges";
static String get questsBadgesTitle => lang == 'tr' ? "Görevler & Rozetler" : "Quests & Badges";
static String get myNotesTitle => lang == 'tr' ? "Notlarım" : "My Notes";
static String get myReviewsTitle => lang == 'tr' ? "Puanlarım" : "My Reviews";
static String get frequentPlacesFullTitle => lang == 'tr' ? "Sık Uğradıklarım" : "My Frequent Places";
static String get cityMapTitle => lang == 'tr' ? "Şehir Haritam" : "My City Map";
static String get neerIdentityTitle => lang == 'tr' ? "Neer Kimliği" : "Neer Identity";

// Zero states
static String get zeroHeatmap => lang == 'tr' ? "Check-in yaptıkça şehirdeki ayak izin burada belirmeye başlar." : "Your city footprint will appear here as you check in.";
static String get zeroBadges => lang == 'tr' ? "Görevleri tamamla, ilk rozetini kazan." : "Complete quests to earn your first badge.";
static String get zeroQuests => lang == 'tr' ? "İlk check-in'ini yapınca günlük görevler başlıyor." : "Complete your first check-in to start daily quests.";
static String get zeroIdentity => lang == 'tr' ? "Dışarı çık, check-in yap. Bu sayılar seninle büyür." : "Go out, check in. These numbers grow with you.";
static String get zeroFrequent => lang == 'tr' ? "Bir mekana tekrar tekrar git — liste kendiliğinden oluşur." : "Visit a venue repeatedly — the list builds itself.";

// Nav bar (label kaldırıldı ama routing için)
static String get navMap => lang == 'tr' ? "Harita" : "Map";
// navChat, navFeed, navProfile zaten var
// navCatch zaten var — sıra değişti: index 3
```

---

## BÖLÜM 10: ROUTING — `app_router.dart`

Yeni route'lar ekle:

```dart
static const String questsBadges = '/quests-badges';
static const String myNotes = '/my-notes';
static const String myReviews = '/my-reviews';
static const String frequentPlacesFull = '/frequent-places';
static const String heatmapFull = '/heatmap';
```

---

## BÖLÜM 11: USERMODEL GÜNCELLEMESİ

`lib/models/user_model.dart`'a ekle:

```dart
// Yeni alanlar
final String neerScoreLabel;
final int totalUniquePlaces;
final int totalCities;
final int activeDays;

// fromMap içine
neerScoreLabel: map['neer_score_label'] ?? 'Standart',
totalUniquePlaces: map['total_unique_places'] ?? 0,
totalCities: map['total_cities'] ?? 0,
activeDays: map['active_days'] ?? 0,
```

---

## KONTROL LİSTESİ

Kodlamayı bitirdikten sonra her maddeyi kontrol et:

- [ ] `premium_background.dart` — orb pozisyonları güncellendi, dark mode 3 orb
- [ ] `glass_panel.dart` — blur/alpha değerleri güncellendi
- [ ] `GlassCard` / `NeerGlass.card()` kullanımları `GlassPanel` ile replace edildi
- [ ] `custom_navbar.dart` — tab sırası, gradient bar, dot animasyonu, label kaldırıldı
- [ ] `profile_header.dart` — Compact Identity C, NeerScoreRing küçülme
- [ ] `profile_screen.dart` — Tab 1 hiyerarşisi 1→6 sıralaması
- [ ] `_NeerIdentityCard` widget yazıldı
- [ ] `_BadgeVitrin` widget yazıldı
- [ ] `_QuestPreview` widget yazıldı
- [ ] `_FrequentPlacesSection` A tasarımı yazıldı
- [ ] `HeatmapWidget` MapTiler ile yazıldı
- [ ] `quests_badges_screen.dart` oluşturuldu (2 tab)
- [ ] `notes_screen.dart` oluşturuldu
- [ ] `reviews_screen.dart` oluşturuldu
- [ ] `frequent_places_screen.dart` oluşturuldu
- [ ] `SectionHeader` widget güncellendi (gradient accent çizgi)
- [ ] `supabase_service.dart` yeni metodlar eklendi
- [ ] `app_strings.dart` Neer Score + yeni string'ler eklendi
- [ ] `user_model.dart` yeni alanlar eklendi
- [ ] `app_router.dart` yeni route'lar eklendi
- [ ] `flutter analyze` — sıfır hata
- [ ] Zero state'ler tüm bölümlerde mevcut

---

## ÖNEMLİ NOTLAR

1. **Neer Score**: `trust_score` alanı DB'de kaldı, `neer_score` sync trigger ile güncelleniyor. Flutter'da hem `trustScore` hem `neerScore` model alanı var — UI'da sadece `neerScore` ve `neerScoreLabel` kullan.

2. **DB Migration**: `badge_quest_heatmap_system` migration zaten uygulandı. `badge_definitions`, `user_badges`, `quest_definitions`, `user_quests` tabloları ve RPC fonksiyonları (`get_user_heatmap_points`, `get_user_identity_stats`, `update_quest_progress`) hazır.

3. **MapTiler key**: `lib/core/constants.dart` veya `.env`'den alınacak — hardcode etme.

4. **GradientTabIndicator**: `profile_header.dart` içinde tanımla — ayrı dosya gerekmez.

5. **`RankingPodium` kaldırıldı**: `ranking_widgets.dart`'tan `RankingPodium` ve `_RankAvatar` class'ları silinecek. `SimpleRankRow` da kaldırılacak. Bunların yerine yeni `_FrequentCard` kullanılıyor.

6. **main_layout.dart**: `activeIndex` referansları güncellenmeli — eski `0=Profil` artık `4=Profil`.