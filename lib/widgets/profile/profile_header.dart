import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/text_styles.dart';
import '../../core/constants.dart';
import '../../core/app_strings.dart';

/// Premium Glassmorphism Profile Header — VisionOS style.
///
/// Features:
/// - Dynamic ambient background (blurred avatar at sigma 45)
/// - Boxless name & bio (text shadows + gradient shield)
/// - Compact stat pills on avatar row
/// - Trust score ring
class ProfileHeader extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String username;
  final String bio;
  final String followersCount;
  final String followingCount;
  final String friendsCount;
  final double trustScore;

  const ProfileHeader({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.username,
    required this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.friendsCount,
    required this.trustScore,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedImage = imageUrl.isNotEmpty ? imageUrl : "https://i.pravatar.cc/300";

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. AMBIENT BACKGROUND — Full-screen blurred avatar
        CachedNetworkImage(
          imageUrl: resolvedImage,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, __) => Container(color: AppColors.darkBackground),
          errorWidget: (_, __, ___) => Container(color: AppColors.darkBackground),
        ),

        // 2. HEAVY BLUR — sigma 45, ambient glow
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
            child: Container(color: Colors.transparent),
          ),
        ),

        // 3. GRADIENT SHIELD — top-down darkening for text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.05),
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.55),
                Colors.black.withValues(alpha: 0.75),
              ],
              stops: const [0.0, 0.35, 0.7, 1.0],
            ),
          ),
        ),

        // 4. CONTENT — avatar, stats, name/bio (boxless)
        Positioned(
          bottom: 75, // space for pill tabs
          left: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- ROW: Avatar + Stats + Trust Score ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // AVATAR with frosted ring
                  _AvatarRing(imageUrl: resolvedImage, size: 72),

                  const SizedBox(width: 16),

                  // STATS — 3 columns
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatColumn(count: followersCount, label: AppStrings.followers),
                        _StatColumn(count: followingCount, label: AppStrings.following),
                        _StatColumn(count: friendsCount, label: AppStrings.friends),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // TRUST SCORE ring
                  _TrustScoreRing(score: trustScore, size: 52),
                ],
              ),

              const SizedBox(height: 16),

              // --- NAME & BIO (boxless, directly on ambient bg) ---
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h2.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        shadows: _textShadows,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "@$username",
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        shadows: _textShadows,
                      ),
                    ),
                    if (bio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.80),
                          fontSize: 14,
                          height: 1.4,
                          shadows: _textShadowsLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static final List<Shadow> _textShadows = [
    Shadow(
      color: Colors.black.withValues(alpha: 0.6),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<Shadow> _textShadowsLight = [
    Shadow(
      color: Colors.black.withValues(alpha: 0.4),
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ];
}

// ==========================================
// AVATAR RING — frosted glass border
// ==========================================
class _AvatarRing extends StatelessWidget {
  final String imageUrl;
  final double size;

  const _AvatarRing({required this.imageUrl, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          width: size,
          height: size,
          placeholder: (_, __) => Container(color: Colors.grey.shade800),
          errorWidget: (_, __, ___) => Container(
            color: Colors.grey.shade800,
            child: const Icon(Icons.person, color: Colors.white54),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// STAT COLUMN — count + label
// ==========================================
class _StatColumn extends StatelessWidget {
  final String count;
  final String label;

  const _StatColumn({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: AppTextStyles.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4)],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// TRUST SCORE RING — circular progress
// ==========================================
class _TrustScoreRing extends StatelessWidget {
  final double score;
  final double size;

  const _TrustScoreRing({required this.score, required this.size});

  Color _scoreColor() {
    if (score >= 8.0) return const Color(0xFF30D158); // Green
    if (score >= 5.0) return const Color(0xFFFF9F0A); // Orange
    return const Color(0xFFFF453A); // Red
  }

  @override
  Widget build(BuildContext context) {
    final color = _scoreColor();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.10)),
            ),
          ),
          // Value ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: (score / 10.0).clamp(0.0, 1.0),
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Score text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_rounded, size: 12, color: color),
              Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PILL TAB BAR — VisionOS Floating Segmented Control
// ==========================================
class PillTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final ValueChanged<int>? onTap;

  const PillTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          height: 46,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.50),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          child: TabBar(
            controller: controller,
            onTap: (index) {
              onTap?.call(index);
            },
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(19),
              gradient: isDark
                  ? LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.35),
                        AppColors.primaryDark.withValues(alpha: 0.25),
                      ],
                    )
                  : const LinearGradient(
                      colors: [Colors.white, Color(0xFFF8F4F6)],
                    ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? AppColors.primary.withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
                if (isDark)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: isDark ? Colors.white : AppColors.lightTextHeading,
            unselectedLabelColor: isDark
                ? Colors.white.withValues(alpha: 0.50)
                : Colors.black.withValues(alpha: 0.38),
            labelStyle: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
            unselectedLabelStyle: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
      ),
    );
  }
}
