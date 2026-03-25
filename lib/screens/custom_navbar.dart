import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/neer_design_system.dart';
import '../core/app_strings.dart';

/// Floating Pill NavBar — white pill slides between tabs, icons shift to make room.
class CustomNavBar extends StatefulWidget {
  final int activeIndex;
  final Function(int) onTabChange;
  final ValueNotifier<bool> shouldCollapse;
  final bool hasChat;
  final bool hasCatch;

  const CustomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTabChange,
    required this.shouldCollapse,
    this.hasChat = false,
    this.hasCatch = false,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar>
    with TickerProviderStateMixin {
  // ── Collapse to dot ──
  late AnimationController _collapseCtrl;
  late Animation<double> _collapseAnim;
  bool _isDot = false;

  // ── Pill slide ──
  late AnimationController _pillCtrl;
  late Animation<double> _pillAnim;
  int _fromIndex = 2;

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

  static const _labelStyle = TextStyle(
    fontFamily: 'SF Pro',
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  // Pre-computed pill widths (pad + icon + gap + text + pad)
  late List<double> _pillWidths;

  @override
  void initState() {
    super.initState();

    _collapseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _collapseAnim = CurvedAnimation(
      parent: _collapseCtrl,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInCubic,
    );
    _collapseCtrl.value = 1.0;

    _pillCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pillAnim = CurvedAnimation(
      parent: _pillCtrl,
      curve: Curves.easeOutCubic,
    );
    _pillCtrl.value = 1.0;
    _fromIndex = widget.activeIndex;

    _pillWidths = List.generate(5, _measurePillWidth);

    widget.shouldCollapse.addListener(_onCollapseChanged);
  }

  @override
  void didUpdateWidget(CustomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.shouldCollapse != widget.shouldCollapse) {
      oldWidget.shouldCollapse.removeListener(_onCollapseChanged);
      widget.shouldCollapse.addListener(_onCollapseChanged);
    }

    if (oldWidget.activeIndex != widget.activeIndex) {
      _fromIndex = oldWidget.activeIndex;
      _pillCtrl.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    widget.shouldCollapse.removeListener(_onCollapseChanged);
    _collapseCtrl.dispose();
    _pillCtrl.dispose();
    super.dispose();
  }

  // No setState — AnimatedBuilder rebuilds from animation ticks
  void _onCollapseChanged() {
    final collapse = widget.shouldCollapse.value;
    if (collapse && !_isDot) {
      _isDot = true;
      _collapseCtrl.reverse();
    } else if (!collapse && _isDot) {
      _isDot = false;
      _collapseCtrl.forward();
    }
  }

  double _measurePillWidth(int index) {
    final tp = TextPainter(
      text: TextSpan(text: _labels[index], style: _labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    return 14 + 22 + 8 + tp.width + 14;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: bottomPad + 10),
      child: AnimatedBuilder(
        animation: Listenable.merge([_collapseAnim, _pillAnim]),
        builder: (context, child) {
          final ct = _collapseAnim.value.clamp(0.0, 1.0);

          const dotSize = 44.0;
          const barHeight = 64.0;
          final screenW = MediaQuery.of(context).size.width - 32;

          final width = dotSize + (ct * (screenW - dotSize));
          final height = dotSize + (ct * (barHeight - dotSize));
          final radius = height / 2;

          return GestureDetector(
            onTap: _isDot
                ? () => widget.shouldCollapse.value = false
                : null,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
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
                      ],
                    ),
                    child: ct < 0.15
                        ? Center(
                            child: Icon(
                              _icons[widget.activeIndex],
                              size: 20,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          )
                        : Opacity(
                            opacity: ct,
                            child: _buildBar(width, height),
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

  Widget _buildBar(double barWidth, double barHeight) {
    const double hPadding = 12.0; 
    final double innerWidth = barWidth - (hPadding * 2);
    final t = _pillAnim.value;

    final fromPW = _pillWidths[_fromIndex];
    final toPW = _pillWidths[widget.activeIndex];
    final fromIW = (innerWidth - fromPW) / 4;
    final toIW = (innerWidth - toPW) / 4;

    // ── Compute each item's width at current t ──
    final widths = <double>[];
    for (int i = 0; i < 5; i++) {
      double w;
      if (i == _fromIndex && i == widget.activeIndex) {
        w = toPW;
      } else if (i == _fromIndex) {
        w = lerpDouble(fromPW, toIW, t)!;
      } else if (i == widget.activeIndex) {
        w = lerpDouble(fromIW, toPW, t)!;
      } else {
        w = lerpDouble(fromIW, toIW, t)!;
      }
      widths.add((w-0.2).clamp(0.0, innerWidth));
    }

    // ── Pill position: slides from _fromIndex to activeIndex ──
    // At t=0: pill left = sum of widths before _fromIndex (all inactive)
    final fromPillLeft = _fromIndex * fromIW;
    // At t=1: pill left = sum of widths before activeIndex (all inactive)
    final toPillLeft = widget.activeIndex * toIW;
    final pillLeft = lerpDouble(fromPillLeft, toPillLeft, t)!;
    final pillW = lerpDouble(fromPW, toPW, t)!;
    const pillH = 48.0;

return Padding(
      padding: const EdgeInsets.symmetric(horizontal: hPadding),
      child: Stack(
        children: [
          // ── Sliding white pill ──
          Positioned(
            // Sınırları innerWidth'e göre çizdik ki dışarı taşmasın
            left: pillLeft.clamp(0.0, innerWidth - pillW.clamp(1, innerWidth)),
            top: (barHeight - pillH) / 2,
            child: Container(
              width: pillW,
              height: pillH,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(pillH / 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              // Icon + label inside pill
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _icons[widget.activeIndex],
                    size: 22,
                    color: NeerColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Opacity(
                      opacity: t.clamp(0.0, 1.0),
                      child: Text(
                        _labels[widget.activeIndex],
                        style: _labelStyle.copyWith(
                          color: const Color(0xFF1A1A2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Icon row (tap targets + inactive icons) ──
          Row(
            children: List.generate(5, (i) {
              final isTo = i == widget.activeIndex;
              final isFrom = i == _fromIndex;
              final hasNotif =
                  (i == 1 && widget.hasChat) || (i == 3 && widget.hasCatch);

              // Hide icon when pill covers it
              double iconOpacity;
              if (isTo && isFrom) {
                iconOpacity = 0.0;
              } else if (isTo) {
                iconOpacity = 1.0 - t;
              } else if (isFrom) {
                iconOpacity = t;
              } else {
                iconOpacity = 1.0;
                if (_fromIndex != widget.activeIndex) {
                  final iCenter = _iconCenterX(widths, i);
                  final pillRight = pillLeft + pillW;
                  if (iCenter > pillLeft + 8 && iCenter < pillRight - 8) {
                    iconOpacity = 0.0;
                  }
                }
              }

              return SizedBox(
                width: widths[i],
                height: barHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onTabChange(i);
                  },
                  child: Center(
                    child: Opacity(
                      opacity: iconOpacity.clamp(0.0, 1.0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(
                            _icons[i],
                            size: 24,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                          if (hasNotif && iconOpacity > 0.5)
                            Positioned(
                              top: -2,
                              right: -3,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: NeerColors.secondary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1A1A2E),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// Center X of the icon at index [i], given current [widths].
  double _iconCenterX(List<double> widths, int i) {
    double x = 0;
    for (int j = 0; j < i; j++) {
      x += widths[j];
    }
    return x + widths[i] / 2;
  }
}
