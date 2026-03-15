import 'dart:ui';
import 'package:flutter/material.dart';

class GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final double borderRadius;
  final Color? iconColor;
  final bool themeAware;
  final bool hasShadow;
  final String? tooltip;

  const GlassButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 30,
    this.iconSize = 20,
    this.borderRadius = 14,
    this.iconColor,
    this.themeAware = false,
    this.hasShadow = false,
    this.tooltip,
  });

  /// Small glass button for AppBar actions (30x30, rounded square)
  const GlassButton.appBar({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.tooltip,
  })  : size = 30,
        iconSize = 20,
        borderRadius = 14,
        themeAware = false,
        hasShadow = false;

  /// Medium glass button (40x40, rounded square)
  const GlassButton.medium({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.tooltip,
  })  : size = 40,
        iconSize = 20,
        borderRadius = 14,
        themeAware = false,
        hasShadow = false;

  /// Floating action button style (50x50, circular, theme-aware)
  const GlassButton.fab({
    super.key,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.tooltip,
  })  : size = 50,
        iconSize = 24,
        borderRadius = 25,
        themeAware = true,
        hasShadow = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = themeAware
        ? (isDark
            ? Colors.black.withValues(alpha: 0.6)
            : Colors.white.withValues(alpha: 0.85))
        : Colors.white.withValues(alpha: 0.1);

    final borderColor = themeAware
        ? (isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.5))
        : Colors.white.withValues(alpha: 0.25);

    final resolvedIconColor = iconColor ??
        (themeAware && isDark ? Colors.white : Colors.white);

    Widget button = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: hasShadow
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Icon(icon, color: resolvedIconColor, size: iconSize),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
