import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/neer_design_system.dart';
import '../../core/app_strings.dart';

class ProfileHeader extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String username;
  final String bio;
  final String followersCount;
  final String followingCount;
  final double neerScore;
  final int checkInCount;
  final int activeDays;
  final String neerScoreLabel;

  const ProfileHeader({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.username,
    required this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.neerScore,
    this.checkInCount = 0,
    this.activeDays = 0,
    this.neerScoreLabel = 'Standart',
  });

  static final List<Shadow> _shadows = [
    Shadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static final List<Shadow> _shadowsLight = [
    Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 6, offset: Offset(0, 1)),
  ];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 72),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ROW 1: Avatar + Meta + NeerScore
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _AvatarRing(imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://i.pravatar.cc/300', size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: NeerTypography.h2.copyWith(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, shadows: _shadows,
                    )),
                    const SizedBox(height: 2),
                    Text('@$username', style: NeerTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.55), shadows: _shadows,
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
                color: Colors.white.withValues(alpha: 0.75), shadows: _shadowsLight,
              ),
            ),
          ],
          // ROW 3: Stat pills
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

class _AvatarRing extends StatelessWidget {
  final String imageUrl;
  final double size;
  const _AvatarRing({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.30), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.30), blurRadius: 16, offset: Offset(0, 4))],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl, fit: BoxFit.cover, width: size, height: size,
          placeholder: (_, __) => Container(color: Colors.grey.shade800),
          errorWidget: (_, __, ___) => Container(color: Colors.grey.shade800, child: const Icon(Icons.person, color: Colors.white54)),
        ),
      ),
    );
  }
}

class _NeerScoreRing extends StatelessWidget {
  final double score;
  final String label;
  final double size;
  const _NeerScoreRing({required this.score, required this.label, required this.size});

  Color _scoreColor() {
    if (score >= 8.0) return const Color(0xFF30D158);
    if (score >= 5.0) return const Color(0xFFFF9F0A);
    return const Color(0xFFFF453A);
  }

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
                  if (size >= 44)
                    Text(
                      label,
                      style: TextStyle(color: color, fontSize: 7, fontWeight: FontWeight.w600),
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
