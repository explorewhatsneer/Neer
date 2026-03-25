import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/neer_design_system.dart';
import '../core/app_strings.dart';

/// Floating Pill NavBar — Active tab shows white pill with icon + label.
///
/// Features:
/// - Active tab: white pill with icon + label (expands with animation)
/// - Inactive tabs: icon only on dark background
/// - Scroll-aware: scrolls down → shrinks to gradient dot, scrolls up → expands
/// - Spring expand/collapse animation
/// - Notification dot for Chat (index 1) and Catch (index 3)
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
    with TickerProviderStateMixin {
  // Scroll collapse animation
  late AnimationController _collapseController;
  late Animation<double> _collapseAnim;
  bool _isDot = false;
  double _lastScrollOffset = 0;

  // Tab switch animation
  late AnimationController _tabController;
  late Animation<double> _tabAnim;

  static const List<IconData> _icons = [
    Icons.map_rounded,
    Icons.chat_bubble_rounded,
    Icons.dynamic_feed_rounded,
    Icons.bolt_rounded,
    Icons.person_rounded,
  ];

  static List<String> get _labels => [
    AppStrings.navMap,
    AppStrings.navChat,
    AppStrings.navFeed,
    AppStrings.navCatch,
    AppStrings.navProfile,
  ];

  @override
  void initState() {
    super.initState();

    // Collapse to dot
    _collapseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _collapseAnim = CurvedAnimation(
      parent: _collapseController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInCubic,
    );
    _collapseController.value = 1.0;

    // Tab switch
    _tabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _tabAnim = CurvedAnimation(
      parent: _tabController,
      curve: Curves.easeOutCubic,
    );
    _tabController.value = 1.0;

    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(CustomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }

    if (oldWidget.activeIndex != widget.activeIndex) {
      _tabController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _collapseController.dispose();
    _tabController.dispose();
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
    _collapseController.reverse();
  }

  void _expandToBar() {
    if (!_isDot) return;
    setState(() => _isDot = false);
    _collapseController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: bottomPad + 10),
      child: AnimatedBuilder(
        animation: Listenable.merge([_collapseAnim, _tabAnim]),
        builder: (context, child) {
          final t = _collapseAnim.value.clamp(0.0, 1.0);

          // Collapsed dot dimensions
          const dotSize = 44.0;
          // Expanded bar dimensions
          const barHeight = 64.0;
          final screenW = MediaQuery.of(context).size.width - 48; // 24*2 padding

          final width = dotSize + (t * (screenW - dotSize));
          final height = dotSize + (t * (barHeight - dotSize));
          final radius = height / 2; // perfect stadium shape

          return GestureDetector(
            onTap: _isDot ? _expandToBar : null,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      // Dark opaque background like reference
                      color: isDark
                          ? const Color(0xFF1C1024).withValues(alpha: 0.92)
                          : const Color(0xFF1A1A2E).withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(radius),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.12),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 32,
                          offset: const Offset(0, 8),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: NeerColors.primary.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _isDot
                        ? Center(
                            child: Icon(
                              _icons[widget.activeIndex],
                              size: 20,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          )
                        : Opacity(
                            opacity: t,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: Row(
                                children: List.generate(5, (i) {
                                  final isActive = i == widget.activeIndex;
                                  final hasNotif = (i == 1 && widget.hasChat) ||
                                      (i == 3 && widget.hasCatch);
                                  return _NavItem(
                                    icon: _icons[i],
                                    label: _labels[i],
                                    isActive: isActive,
                                    isDark: isDark,
                                    hasNotification: hasNotif,
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      widget.onTabChange(i);
                                    },
                                  );
                                }),
                              ),
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

/// Individual nav item — active: white pill with icon+label, inactive: icon only.
class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final bool hasNotification;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
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
  late AnimationController _pressController;
  late Animation<double> _pressAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _pressAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInOut,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Active: expanded white pill. Inactive: compact icon.
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _pressAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          height: 48,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isActive ? 18 : 0,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? (widget.isDark ? Colors.white : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: widget.isActive ? 24 : 48,
                    height: 48,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          widget.icon,
                          key: ValueKey('${widget.isActive}_${widget.icon}'),
                          size: widget.isActive ? 22 : 24,
                          color: widget.isActive
                              ? NeerColors.primary
                              : Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                  // Notification dot
                  if (widget.hasNotification)
                    Positioned(
                      top: 10,
                      right: widget.isActive ? -2 : 8,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: NeerColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.isActive
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Label (only when active)
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: widget.isActive
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          widget.label,
                          style: const TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            letterSpacing: -0.3,
                          ),
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
