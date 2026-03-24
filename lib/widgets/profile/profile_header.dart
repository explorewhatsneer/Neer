import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../core/neer_design_system.dart';
import '../../core/app_strings.dart';

// ==========================================
// DOMINANT RENK ARKA PLAN (D1)
// ==========================================

/// D1: PP'den dominant renk çıkar — solid blok, fade yok
class ProfileHeaderBackground extends StatefulWidget {
  final String imageUrl;
  final bool isDark;
  final Widget child;
  final ValueChanged<Color>? onColorExtracted;

  const ProfileHeaderBackground({
    super.key,
    required this.imageUrl,
    required this.isDark,
    required this.child,
    this.onColorExtracted,
  });

  @override
  State<ProfileHeaderBackground> createState() =>
      _ProfileHeaderBackgroundState();
}

class _ProfileHeaderBackgroundState extends State<ProfileHeaderBackground> {
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
        maximumColorCount: 8,
      );
      final dominant = generator.dominantColor?.color ?? generator.vibrantColor?.color;
      if (dominant != null && mounted) {
        final blended = widget.isDark
            ? Color.lerp(dominant, Colors.black, 0.55)!
            : Color.lerp(dominant, Colors.white, 0.60)!;
        widget.onColorExtracted?.call(blended);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // PP blurlu arka plan
        Positioned.fill(
          child: widget.imageUrl.isNotEmpty
              ? CachedNetworkImage(imageUrl: widget.imageUrl, fit: BoxFit.cover)
              : Container(
                  color: widget.isDark ? const Color(0xFF1A0F1A) : const Color(0xFFEDE8FF),
                ),
        ),
        // Frosted blur katmanı
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(
              color: widget.isDark
                  ? Colors.black.withValues(alpha: 0.62)
                  : Colors.white.withValues(alpha: 0.52),
            ),
          ),
        ),
        widget.child,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Satır 1: Avatar | İsim+Username | Edit+Settings
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ProfileAvatar(imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://i.pravatar.cc/300'),
                const SizedBox(width: 12),
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
                // Edit + Settings butonları (sağ üst)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HeaderIconButton(icon: Icons.edit_rounded, onTap: onEditTap ?? () {}),
                    const SizedBox(width: 7),
                    _HeaderIconButton(icon: Icons.settings_rounded, onTap: onSettingsTap ?? () {}),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 7),

            // Satır 2: Bio (sol, esnek) | NeerScore (sağ, sabit)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: bio.isNotEmpty
                      ? Text(
                          bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: NeerTypography.bodySmall.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.78)
                                : Colors.black.withValues(alpha: 0.65),
                            shadows: subShadows,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 12),
                _NeerScoreRingHeader(
                  score: neerScore,                  
                  size: 48,
                ),
              ],
            ),

            const SizedBox(height: 7),

            // Satır 3: Stats — tıklanabilir
            Row(
              children: [
                GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); onFollowersTap?.call(); },
                  child: _StatChip(value: followersCount, label: AppStrings.followers),
                ),
                _StatSep(),
                GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); onFollowingTap?.call(); },
                  child: _StatChip(value: followingCount, label: AppStrings.following),
                ),
                _StatSep(),
                GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); onFriendsTap?.call(); },
                  child: const _StatChip(value: '—', label: 'Arkadaş'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.20)
                : Colors.black.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: isDark
              ? Colors.white.withValues(alpha: 0.85)
              : Colors.black.withValues(alpha: 0.70),
          size: 14,
        ),
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
          fontWeight: FontWeight.w700, fontSize: 15,
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
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1, height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isDark ? Colors.white.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.18),
    );
  }
}

class _NeerScoreRingHeader extends StatelessWidget {
  final double score;
  final double size;
  const _NeerScoreRingHeader({required this.score, required this.size});

  Color _color() {
    if (score >= 8.0) return const Color(0xFF30D158);
    if (score >= 5.0) return const Color(0xFFFF9F0A);
    return const Color(0xFFFF453A);
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return SizedBox(
        width: 48, height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size, height: size,
              child: CircularProgressIndicator(
                value: 1.0, strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.12)),
              ),
            ),
            SizedBox(
              width: size, height: size,
              child: CircularProgressIndicator(
                value: (score / 10.0).clamp(0.0, 1.0),
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(score.toStringAsFixed(1), style: TextStyle(
              color: Colors.white, fontSize: 48 * 0.26, fontWeight: FontWeight.w600, height: 1.0,
            )),
          ],
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
  final Color? color;
  const GradientTabIndicator({
    this.height = 2.5,
    this.borderRadius = const BorderRadius.all(Radius.circular(2)),
    this.color,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChange]) =>
      _SolidTabPainter(height: height, borderRadius: borderRadius, color: color ?? Colors.white);
}

class _SolidTabPainter extends BoxPainter {
  final double height;
  final BorderRadius borderRadius;
  final Color color;
  _SolidTabPainter({required this.height, required this.borderRadius, required this.color});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final rect = Rect.fromLTWH(
      offset.dx, offset.dy + (configuration.size?.height ?? 0) - height,
      configuration.size?.width ?? 0, height,
    );
    final paint = Paint()..color = color;
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
        indicator: GradientTabIndicator(
          color: isDark ? Colors.white : NeerColors.primary,
        ),
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        labelColor: isDark ? Colors.white : NeerColors.primary,
        unselectedLabelColor: isDark ? Colors.white.withValues(alpha: 0.40) : Colors.black.withValues(alpha: 0.40),
        labelStyle: NeerTypography.caption.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
        unselectedLabelStyle: NeerTypography.caption.copyWith(fontWeight: FontWeight.w500, fontSize: 14),
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }
}

// Keep PillTabBar as alias for backward compat (maps to ProfileTabBar)
typedef PillTabBar = ProfileTabBar;
