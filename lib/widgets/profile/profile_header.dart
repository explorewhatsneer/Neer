import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/neer_design_system.dart';
import '../../core/app_strings.dart';

// ==========================================
// PP BLUR ARKA PLAN (D2)
// ==========================================

/// PP blur (D2): dominant renk + PP doku + aşağı fade
class ProfileHeaderBackground extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1A0F1A) : const Color(0xFFFDFBFF);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Katman 1: PP blur doku
        if (imageUrl.isNotEmpty)
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Transform.scale(
                scale: 1.15,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),

        // Katman 2: Dominant renk tint
        Positioned.fill(
          child: Container(
            color: isDark
                ? Colors.black.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.22),
          ),
        ),

        // Katman 3: Aşağı fade — ekranla kaynaşıyor
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bgColor.withValues(alpha: 0.0),
                  bgColor.withValues(alpha: 0.65),
                  bgColor.withValues(alpha: 0.92),
                  bgColor,
                ],
                stops: const [0.0, 0.40, 0.70, 1.0],
              ),
            ),
          ),
        ),

        // Katman 4: Header içerik
        child,
      ],
    );
  }
}

// ==========================================
// PROFILE HEADER
// ==========================================

class ProfileHeader extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String username;
  final String bio;
  final String followersCount;
  final String followingCount;
  final double neerScore;
  final String neerScoreLabel;
  final VoidCallback? onEditTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onFriendsTap;

  const ProfileHeader({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.username,
    required this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.neerScore,
    required this.neerScoreLabel,
    this.onEditTap,
    this.onSettingsTap,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onFriendsTap,
  });

  static final List<Shadow> _shadows = [
    Shadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 8, offset: const Offset(0, 2)),
  ];
  static final List<Shadow> _shadowsLight = [
    Shadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 1)),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                _ProfileAvatar(imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://i.pravatar.cc/300'),
                const SizedBox(width: 12),

                // İsim + username + butonlar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: NeerTypography.h2.copyWith(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                shadows: _shadows,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _HeaderIconButton(icon: Icons.edit_rounded, onTap: onEditTap ?? () {}),
                          const SizedBox(width: 5),
                          _HeaderIconButton(icon: Icons.settings_rounded, onTap: onSettingsTap ?? () {}),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '@$username',
                        style: NeerTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.55),
                          shadows: _shadowsLight,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // NeerScore — edit buton satırıyla hizalı
                _NeerScoreRingHeader(
                  score: neerScore,
                  label: neerScoreLabel,
                  size: 44,
                  topOffset: 28,
                ),
              ],
            ),

            // Bio
            if (bio.isNotEmpty) ...[
              const SizedBox(height: 7),
              Text(
                bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: NeerTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                  shadows: _shadowsLight,
                ),
              ),
            ],

            // Stats — tıklanabilir
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); onFollowersTap?.call(); },
                  child: _StatChip(value: followersCount, label: AppStrings.followers),
                ),
                _StatSep(),
                GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); onFollowingTap?.call(); },
                  child: _StatChip(value: followingCount, label: 'takip'),
                ),
                _StatSep(),
                GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); onFriendsTap?.call(); },
                  child: const _StatChip(value: '—', label: 'arkadaş'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.20), width: 1),
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 14),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value, label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: NeerTypography.caption.copyWith(
          color: Colors.white.withValues(alpha: 0.90),
          fontWeight: FontWeight.w700, fontSize: 13,
          shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 6)],
        )),
        const SizedBox(width: 3),
        Text(label, style: NeerTypography.caption.copyWith(
          color: Colors.white.withValues(alpha: 0.45), fontSize: 11,
        )),
      ],
    );
  }
}

class _StatSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1, height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white.withValues(alpha: 0.22),
    );
  }
}

class _NeerScoreRingHeader extends StatelessWidget {
  final double score;
  final String label;
  final double size;
  final double topOffset;
  const _NeerScoreRingHeader({required this.score, required this.label, required this.size, this.topOffset = 0});

  Color _color() {
    if (score >= 8.0) return const Color(0xFF30D158);
    if (score >= 5.0) return const Color(0xFFFF9F0A);
    return const Color(0xFFFF453A);
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Padding(
      padding: EdgeInsets.only(top: topOffset),
      child: SizedBox(
        width: size, height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: 1.0, strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.12)),
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
                Text(score.toStringAsFixed(1), style: TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, height: 1.0,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4)],
                )),
                Text(label, style: TextStyle(color: color, fontSize: 6, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// PROFILE AVATAR — Hero animasyonu
// ==========================================

class _ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  const _ProfileAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.black.withValues(alpha: 0.85),
          barrierDismissible: true,
          pageBuilder: (_, __, ___) => _AvatarFullScreen(imageUrl: imageUrl),
        ));
      },
      child: Hero(
        tag: 'profile_avatar_$imageUrl',
        child: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: ClipOval(child: CachedNetworkImage(
            imageUrl: imageUrl, fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: Colors.grey.shade800),
            errorWidget: (_, __, ___) => Container(color: Colors.grey.shade800, child: const Icon(Icons.person, color: Colors.white54)),
          )),
        ),
      ),
    );
  }
}

class _AvatarFullScreen extends StatelessWidget {
  final String imageUrl;
  const _AvatarFullScreen({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(fit: StackFit.expand, children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.black.withValues(alpha: 0.75)),
          ),
          Center(
            child: Hero(
              tag: 'profile_avatar_$imageUrl',
              child: Container(
                width: 280, height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 40)],
                ),
                child: ClipOval(child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ==========================================
// GRADIENT TAB INDICATOR — custom painter
// ==========================================
class GradientTabIndicator extends Decoration {
  final double height;
  final BorderRadius borderRadius;
  const GradientTabIndicator({
    this.height = 2.5,
    this.borderRadius = const BorderRadius.all(Radius.circular(2)),
  });

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

// ==========================================
// PROFILE TAB BAR — left-aligned gradient underline
// ==========================================
class ProfileTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final ValueChanged<int>? onTap;

  const ProfileTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.onTap,
  });

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
        onTap: onTap,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.only(left: 16),
        labelPadding: const EdgeInsets.only(right: 20),
        indicator: const GradientTabIndicator(),
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.38),
        labelStyle: NeerTypography.caption.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
        unselectedLabelStyle: NeerTypography.caption.copyWith(fontWeight: FontWeight.w400, fontSize: 13),
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

// Keep PillTabBar as alias for backward compat (maps to ProfileTabBar)
typedef PillTabBar = ProfileTabBar;
