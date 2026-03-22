import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/text_styles.dart';
import '../../core/constants.dart';
import '../../core/app_strings.dart';

/// Premium Glassmorphism Friend Profile Header — VisionOS style.
///
/// Mirrors ProfileHeader design: ambient background, boxless bio,
/// gradient shield for text readability, trust score ring.
class FriendProfileHeader extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String username;
  final String bio;
  final bool isOnline;
  final int followersCount;
  final int followingCount;
  final int friendsCount;
  final double trustScore;

  const FriendProfileHeader({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.username,
    required this.bio,
    required this.isOnline,
    required this.followersCount,
    required this.followingCount,
    required this.friendsCount,
    required this.trustScore,
  });

  String _formatCount(int count) {
    return count > 999 ? "${(count / 1000).toStringAsFixed(1)}k" : count.toString();
  }

  Color _scoreColor() {
    if (trustScore >= 8.0) return const Color(0xFF30D158);
    if (trustScore >= 5.0) return const Color(0xFFFF9F0A);
    return const Color(0xFFFF453A);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedImage = imageUrl.isNotEmpty ? imageUrl : "https://i.pravatar.cc/300";

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. AMBIENT BACKGROUND — full-screen blurred avatar
        CachedNetworkImage(
          imageUrl: resolvedImage,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, __) => Container(color: AppColors.darkBackground),
          errorWidget: (_, __, ___) => Container(color: AppColors.darkBackground),
        ),

        // 2. HEAVY BLUR — sigma 45
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
            child: Container(color: Colors.transparent),
          ),
        ),

        // 3. GRADIENT SHIELD
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

        // 4. CONTENT
        Positioned(
          bottom: 75,
          left: 20,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ROW: Avatar + Stats + Trust Score
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // AVATAR with online indicator
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
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
                              imageUrl: resolvedImage,
                              fit: BoxFit.cover,
                              width: 72,
                              height: 72,
                              placeholder: (_, __) => Container(color: Colors.grey.shade800),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.person, color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                        if (isOnline)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFF30D158),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // STATS
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatCol(count: _formatCount(followersCount), label: AppStrings.followers),
                        _StatCol(count: _formatCount(followingCount), label: AppStrings.following),
                        _StatCol(count: _formatCount(friendsCount), label: AppStrings.friends),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // TRUST SCORE
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.10)),
                          ),
                        ),
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: CircularProgressIndicator(
                            value: (trustScore / 10.0).clamp(0.0, 1.0),
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(_scoreColor()),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_rounded, size: 12, color: _scoreColor()),
                            Text(
                              trustScore.toStringAsFixed(1),
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
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // NAME & BIO (boxless)
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
    Shadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 8, offset: const Offset(0, 2)),
  ];

  static final List<Shadow> _textShadowsLight = [
    Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 6, offset: const Offset(0, 1)),
  ];
}

class _StatCol extends StatelessWidget {
  final String count;
  final String label;
  const _StatCol({required this.count, required this.label});

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
