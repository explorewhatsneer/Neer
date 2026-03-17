import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Reusable glassmorphism container widget.
///
/// Glass Morphism Design — buzlu cam efekti ile backdrop blur ve
/// yarı saydam arka plan kullanan container.
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
    this.blurSigma = 30,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.boxShadow,
    this.border,
    this.backgroundColor,
    this.darkAlpha = 0.55,
    this.lightAlpha = 0.65,
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
    this.darkAlpha = 0.70,
    this.lightAlpha = 0.80,
  })  : borderRadius = const BorderRadius.vertical(top: Radius.circular(35)),
        blurSigma = 30;

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
    this.darkAlpha = 0.50,
    this.lightAlpha = 0.60,
  })  : borderRadius = BorderRadius.zero,
        blurSigma = 25;

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
    this.darkAlpha = 0.45,
    this.lightAlpha = 0.60,
  })  : borderRadius = const BorderRadius.all(Radius.circular(22)),
        blurSigma = 20;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDark
            ? AppColors.darkSurface.withValues(alpha: darkAlpha)
            : Colors.white.withValues(alpha: lightAlpha));

    final resolvedBorder = border ??
        Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.55),
          width: 1,
        );

    final resolvedShadow = boxShadow ??
        [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.10 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -2,
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
