import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/neer_design_system.dart';
import '../../core/app_strings.dart';
import '../profile/profile_header.dart';

/// Friend Profile Header — matches ProfileHeader design language.
///
/// Uses ProfileHeaderBackground (dominant color extraction + blur)
/// with clean content layout: Avatar | Name+Username | NeerScore,
/// Bio, Stats row.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedImage = imageUrl.isNotEmpty ? imageUrl : 'https://i.pravatar.cc/300';

    final textColor = isDark ? Colors.white : Colors.black.withValues(alpha: 0.87);
    final subTextColor = isDark
        ? Colors.white.withValues(alpha: 0.55)
        : Colors.black.withValues(alpha: 0.50);
    final textShadows = isDark
        ? [Shadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 8, offset: const Offset(0, 2))]
        : <Shadow>[];
    final subShadows = isDark
        ? [Shadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 1))]
        : <Shadow>[];

    return ProfileHeaderBackground(
      imageUrl: resolvedImage,
      isDark: isDark,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Avatar | Name+Username | NeerScore
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with online indicator
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: resolvedImage,
                              fit: BoxFit.cover,
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
                            bottom: 1,
                            right: 1,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: const Color(0xFF30D158),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? Colors.black : Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name + Username
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: NeerTypography.h2.copyWith(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            shadows: textShadows,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@$username',
                          style: NeerTypography.caption.copyWith(
                            color: subTextColor,
                            shadows: subShadows,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // NeerScore ring
                  _NeerScoreRing(score: trustScore, color: _scoreColor()),
                ],
              ),

              const SizedBox(height: 7),

              // Row 2: Bio
              if (bio.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Text(
                    bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: NeerTypography.bodySmall.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.78)
                          : Colors.black.withValues(alpha: 0.65),
                      shadows: subShadows,
                    ),
                  ),
                ),

              // Row 3: Stats
              Row(
                children: [
                  _StatChip(value: _formatCount(followersCount), label: AppStrings.followers),
                  _StatSep(isDark: isDark),
                  _StatChip(value: _formatCount(followingCount), label: AppStrings.following),
                  _StatSep(isDark: isDark),
                  _StatChip(value: _formatCount(friendsCount), label: AppStrings.friends),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeerScoreRing extends StatelessWidget {
  final double score;
  final Color color;
  const _NeerScoreRing({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.12)),
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              value: (score / 10.0).clamp(0.0, 1.0),
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_rounded, size: 10, color: color),
              Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
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

class _StatChip extends StatelessWidget {
  final String value, label;
  const _StatChip({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = isDark ? Colors.white.withValues(alpha: 0.92) : Colors.black.withValues(alpha: 0.87);
    final labelColor = isDark ? Colors.white.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.45);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: NeerTypography.caption.copyWith(
          color: valueColor,
          fontWeight: FontWeight.w700,
          fontSize: 15,
          shadows: isDark ? [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 6)] : [],
        )),
        const SizedBox(width: 3),
        Text(label, style: NeerTypography.caption.copyWith(
          color: labelColor, fontSize: 13,
        )),
      ],
    );
  }
}

class _StatSep extends StatelessWidget {
  final bool isDark;
  const _StatSep({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isDark ? Colors.white.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.18),
    );
  }
}
