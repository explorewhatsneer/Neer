import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../core/constants.dart';
import 'app_cached_image.dart';

/// Pinterest/Masonry style photo gallery with random aspect ratios.
///
/// Tap on any photo opens a fullscreen viewer with Hero animation,
/// pinch-to-zoom, and swipe-to-dismiss.
class MasonryGallery extends StatelessWidget {
  final List<String> photos;
  final EdgeInsetsGeometry padding;

  const MasonryGallery({
    super.key,
    required this.photos,
    this.padding = const EdgeInsets.all(12),
  });

  /// Pseudo-random aspect ratio per image (seeded by index for consistency).
  double _aspectRatio(int index) {
    final rng = Random(index.hashCode + photos[index].hashCode);
    // Ratios between 0.7 (tall) and 1.4 (wide)
    return 0.7 + rng.nextDouble() * 0.7;
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: padding,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final ratio = _aspectRatio(index);
        final heroTag = 'gallery_photo_$index';

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                barrierColor: Colors.black87,
                pageBuilder: (_, __, ___) => FullscreenImageViewer(
                  imageUrl: photos[index],
                  heroTag: heroTag,
                  photos: photos,
                  initialIndex: index,
                ),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 250),
                reverseTransitionDuration: const Duration(milliseconds: 200),
              ),
            );
          },
          child: Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: ratio,
                child: AppCachedImage.cover(
                  imageUrl: photos[index],
                  borderRadius: 0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Sliver-compatible masonry gallery for use inside CustomScrollView.
class SliverMasonryGallery extends StatelessWidget {
  final List<String> photos;
  final EdgeInsetsGeometry padding;

  const SliverMasonryGallery({
    super.key,
    required this.photos,
    this.padding = const EdgeInsets.all(12),
  });

  double _aspectRatio(int index) {
    final rng = Random(index.hashCode + photos[index].hashCode);
    return 0.7 + rng.nextDouble() * 0.7;
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childCount: photos.length,
        itemBuilder: (context, index) {
          final ratio = _aspectRatio(index);
          final heroTag = 'gallery_photo_$index';

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  barrierColor: Colors.black87,
                  pageBuilder: (_, __, ___) => FullscreenImageViewer(
                    imageUrl: photos[index],
                    heroTag: heroTag,
                    photos: photos,
                    initialIndex: index,
                  ),
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 250),
                  reverseTransitionDuration: const Duration(milliseconds: 200),
                ),
              );
            },
            child: Hero(
              tag: heroTag,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: ratio,
                  child: AppCachedImage.cover(
                    imageUrl: photos[index],
                    borderRadius: 0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Fullscreen image viewer with PageView, pinch-to-zoom, and swipe-to-dismiss.
class FullscreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String heroTag;
  final List<String> photos;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset += details.delta.dy;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_dragOffset.abs() > 100 || details.velocity.pixelsPerSecond.dy.abs() > 800) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _dragOffset = 0;
        _isDragging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - (_dragOffset.abs() / 400)).clamp(0.3, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Stack(
          children: [
            // Background tap to close
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black.withValues(alpha: opacity * 0.9)),
            ),

            // Image PageView
            AnimatedContainer(
              duration: _isDragging ? Duration.zero : const Duration(milliseconds: 200),
              transform: Matrix4.translationValues(0, _dragOffset, 0),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.photos.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) {
                  final tag = 'gallery_photo_$index';
                  return Center(
                    child: Hero(
                      tag: tag,
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: AppCachedImage(
                          imageUrl: widget.photos[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                ),
              ),
            ),

            // Page indicator
            if (widget.photos.length > 1)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${widget.photos.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
    );
  }
}
