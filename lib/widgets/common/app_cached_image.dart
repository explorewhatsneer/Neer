import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan cache'li network image widget'ı.
///
/// Otomatik olarak:
/// - Disk + memory cache
/// - Shimmer placeholder (loading state)
/// - Hata durumunda fallback icon
/// - Fade-in animasyonu
///
/// Kullanım:
/// ```dart
/// AppCachedImage(imageUrl: url, width: 60, height: 60)
/// AppCachedImage.avatar(imageUrl: url, radius: 24)
/// AppCachedImage.cover(imageUrl: url, height: 200)
/// ```
class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool isCircle;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
    this.isCircle = false,
  });

  /// Yuvarlak avatar — profil resimleri, chat avatarları vs.
  const AppCachedImage.avatar({
    super.key,
    required this.imageUrl,
    double radius = 24,
    this.placeholder,
    this.errorWidget,
  })  : width = radius * 2,
        height = radius * 2,
        fit = BoxFit.cover,
        borderRadius = 0,
        isCircle = true;

  /// Tam genişlik cover image — feed kartları, mekan header vs.
  const AppCachedImage.cover({
    super.key,
    required this.imageUrl,
    this.height = 200,
    this.borderRadius = 0,
    this.placeholder,
    this.errorWidget,
  })  : width = double.infinity,
        fit = BoxFit.cover,
        isCircle = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // URL boşsa direkt fallback göster
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return _buildFallback(isDark);
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder: (context, url) => placeholder ?? _buildShimmer(isDark),
      errorWidget: (context, url, error) => errorWidget ?? _buildFallback(isDark),
      memCacheWidth: _cacheResolution,
    );

    if (isCircle) {
      return ClipOval(child: image);
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }

    return image;
  }

  /// Shimmer benzeri loading placeholder
  Widget _buildShimmer(bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.12),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : (borderRadius > 0 ? BorderRadius.circular(borderRadius) : null),
      ),
    );
  }

  /// Hata/boş URL fallback widget
  Widget _buildFallback(bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.08),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : (borderRadius > 0 ? BorderRadius.circular(borderRadius) : null),
      ),
      child: Icon(
        isCircle ? Icons.person : Icons.image_outlined,
        color: isDark ? Colors.white24 : Colors.grey.shade400,
        size: _iconSize,
      ),
    );
  }

  /// Cache'e gönderilecek çözünürlük (bellek tasarrufu)
  int? get _cacheResolution {
    if (width != null && width != double.infinity) return (width! * 2).toInt();
    if (height != null) return (height! * 2).toInt();
    return null;
  }

  /// Fallback icon boyutu
  double get _iconSize {
    if (width != null && width != double.infinity) return (width! * 0.4).clamp(16, 40);
    if (height != null) return (height! * 0.4).clamp(16, 40);
    return 24;
  }
}

/// CircleAvatar yerine kullanılabilecek cache'li avatar.
///
/// Kullanım:
/// ```dart
/// CachedAvatar(
///   imageUrl: user['avatar_url'] ?? '',
///   name: user['full_name'] ?? '',
///   radius: 28,
/// )
/// ```
class CachedAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double radius;
  final Color? backgroundColor;
  final bool showOnlineIndicator;
  final bool isOnline;

  /// Hero animasyonu için tag. Null ise Hero kullanılmaz.
  final String? heroTag;

  const CachedAvatar({
    super.key,
    required this.imageUrl,
    this.name = '',
    this.radius = 24,
    this.backgroundColor,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imageUrl.isNotEmpty && imageUrl.startsWith('http');

    Widget avatar;
    if (hasImage) {
      avatar = ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 200),
          memCacheWidth: (radius * 4).toInt(),
          placeholder: (_, __) => _buildInitials(theme),
          errorWidget: (_, __, ___) => _buildInitials(theme),
        ),
      );
    } else {
      avatar = _buildInitials(theme);
    }

    Widget result = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: avatar,
    );

    if (showOnlineIndicator) {
      result = Stack(
        children: [
          result,
          if (isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: radius * 0.55,
                height: radius * 0.55,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759),
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.cardColor, width: 2.5),
                ),
              ),
            ),
        ],
      );
    }

    // Hero animasyonu desteği
    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: result,
      );
    }

    return result;
  }

  Widget _buildInitials(ThemeData theme) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.scaffoldBackgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: theme.disabledColor,
          fontSize: radius * 0.7,
        ),
      ),
    );
  }
}
