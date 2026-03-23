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

