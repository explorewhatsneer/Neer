import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable glassmorphism container widget.
///
/// Replaces the repeated ClipRRect + BackdropFilter + Container pattern
/// found across 20+ files in the codebase.
///
/// Usage:
/// ```dart
/// GlassPanel(
///   borderRadius: BorderRadius.circular(24),
///   child: Text('Hello'),
/// )
/// ```
class GlassPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  /// Override background color. If null, uses theme-aware defaults.
  final Color? backgroundColor;

  /// Alpha values for auto theme colors (dark / light).
  final double darkAlpha;
  final double lightAlpha;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blurSigma = 20,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.boxShadow,
    this.border,
    this.backgroundColor,
    this.darkAlpha = 0.8,
    this.lightAlpha = 0.9,
  });

  /// Bottom sheet style — top corners rounded, higher blur.
  const GlassPanel.sheet({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.boxShadow,
    this.border,
    this.backgroundColor,
    this.darkAlpha = 0.8,
    this.lightAlpha = 0.9,
  })  : borderRadius = const BorderRadius.vertical(top: Radius.circular(35)),
        blurSigma = 20;

  /// AppBar style — no bottom radius, moderate blur.
  const GlassPanel.appBar({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.boxShadow,
    this.border,
    this.backgroundColor,
    this.darkAlpha = 0.7,
    this.lightAlpha = 0.85,
  })  : borderRadius = BorderRadius.zero,
        blurSigma = 20;

  /// Card style — fully rounded, subtle blur.
  const GlassPanel.card({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.boxShadow,
    this.border,
    this.backgroundColor,
    this.darkAlpha = 0.6,
    this.lightAlpha = 0.85,
  })  : borderRadius = const BorderRadius.all(Radius.circular(20)),
        blurSigma = 15;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDark
            ? Colors.black.withValues(alpha: darkAlpha)
            : Colors.white.withValues(alpha: lightAlpha));

    final resolvedBorder = border ??
        Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.5),
          width: 1.5,
        );

    final resolvedShadow = boxShadow ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ];

    Widget container = Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
        border: resolvedBorder,
        boxShadow: resolvedShadow,
      ),
      child: child,
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: container,
      ),
    );
  }
}
