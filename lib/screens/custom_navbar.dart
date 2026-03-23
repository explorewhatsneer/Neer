import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/neer_design_system.dart';

/// Premium Floating Pill NavBar — Apple VisionOS style.
///
/// Features:
/// - Scroll-aware: scrolls down → shrinks to gradient dot, scrolls up → expands back
/// - No labels — icon-only
/// - Active indicator: gradient underline bar (2.5px)
/// - Notification dot for Chat (index 1) and Catch (index 3)
/// - Spring expand/collapse animation (elasticOut)
class CustomNavBar extends StatefulWidget {
  final int activeIndex;
  final Function(int) onTabChange;
  final ScrollController? scrollController;
  final bool hasChat;
  final bool hasCatch;

  const CustomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTabChange,
    this.scrollController,
    this.hasChat = false,
    this.hasCatch = false,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _expandAnim;
  bool _isDot = false;
  double _lastScrollOffset = 0;

  static const List<IconData> _icons = [
    Icons.map_rounded,
    Icons.chat_bubble_rounded,
    Icons.dynamic_feed_rounded,
    Icons.bolt_rounded,
    Icons.person_rounded,
  ];

  // Emoji for dot mode (active tab)
  static const List<String> _emojis = ['🗺️', '💬', '⚡', '🎯', '👤'];

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

  @override
  void didUpdateWidget(CustomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _animController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final sc = widget.scrollController;
    if (sc == null || !sc.hasClients) return;
    final offset = sc.offset;
    final delta = offset - _lastScrollOffset;
    _lastScrollOffset = offset;

    if (delta > 8 && !_isDot) {
      _collapseToDoc();
    } else if (delta < -4 && _isDot) {
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
          final screenW = MediaQuery.of(context).size.width - 32;
          final t = _expandAnim.value.clamp(0.0, 1.0);
          final width = 36.0 + (t * (screenW - 36));
          final height = 36.0 + (t * (58.0 - 36.0));
          final radius = 18.0 + (t * (28.0 - 18.0));

          return GestureDetector(
            onTap: _isDot ? _expandToBar : null,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 35, sigmaY: 35),
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      color: _isDot
                          ? (isDark
                              ? NeerColors.darkSurface.withValues(alpha: 0.80)
                              : Colors.white.withValues(alpha: 0.80))
                          : (isDark
                              ? NeerColors.darkSurface.withValues(alpha: 0.35)
                              : Colors.white.withValues(alpha: 0.35)),
                      borderRadius: BorderRadius.circular(radius),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: _isDot ? 0.15 : 0.12),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: _isDot ? 0.28 : 0.40),
                          blurRadius: _isDot ? 14 : 28,
                          offset: Offset(0, _isDot ? 5 : 6),
                        ),
                      ],
                    ),
                    child: _isDot
                        ? const SizedBox.shrink()
                        : Opacity(
                            opacity: t,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(5, (i) => _NavItem(
                                icon: _icons[i],
                                isActive: i == widget.activeIndex,
                                isDark: isDark,
                                hasNotification: (i == 1 && widget.hasChat) ||
                                    (i == 3 && widget.hasCatch),
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
}

/// Individual nav item — icon only with gradient underline indicator.
class _NavItem extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final bool isDark;
  final bool hasNotification;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.isDark,
    required this.hasNotification,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isDark ? Colors.white : NeerColors.primary;
    final inactiveColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.40)
        : Colors.black.withValues(alpha: 0.35);

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: SizedBox(
          width: 52,
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.isActive ? activeColor : inactiveColor,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  // Gradient underline indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: widget.isActive ? 16 : 0,
                    height: 2.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: widget.isActive ? NeerGradients.purplePink : null,
                    ),
                  ),
                ],
              ),
              // Notification dot
              if (widget.hasNotification)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: NeerColors.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.isDark
                            ? NeerColors.darkSurface
                            : Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
