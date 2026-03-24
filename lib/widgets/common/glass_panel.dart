import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/neer_design_system.dart';

/// Premium Glassmorphism container — Apple VisionOS style.
///
/// Rules:
/// - blurSigma minimum 45 (high blur)
/// - darkAlpha 0.12–0.15, lightAlpha 0.20–0.25 (extreme transparency)
/// - 1px frosted border at alpha 0.18
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
  final Color? backgroundColor;
  final double darkAlpha;
  final double lightAlpha;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blurSigma = 35,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.boxShadow,
    this.border,
    this.backgroundColor,
    this.darkAlpha = 0.42,
    this.lightAlpha = 0.78,
  });

  /// Bottom sheet style — top corners rounded.
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
    this.darkAlpha = 0.48,
    this.lightAlpha = 0.85,
  })  : borderRadius = const BorderRadius.vertical(top: Radius.circular(35)),
        blurSigma = 40;

  /// AppBar style — no bottom radius.
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
    this.darkAlpha = 0.35,
    this.lightAlpha = 0.70,
  })  : borderRadius = BorderRadius.zero,
        blurSigma = 45;

  /// Card style — fully rounded, used in Bento Box.
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
    this.darkAlpha = 0.42,
    this.lightAlpha = 0.78,
  })  : borderRadius = const BorderRadius.all(Radius.circular(22)),
        blurSigma = 30;

  /// Bento cell — tighter radius, used inside Bento Dashboard grids.
  const GlassPanel.bento({
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
    this.darkAlpha = 0.38,
    this.lightAlpha = 0.72,
  })  : borderRadius = const BorderRadius.all(Radius.circular(20)),
        blurSigma = 26;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDark
            ? NeerColors.darkSurface.withValues(alpha: darkAlpha)
            : Colors.white.withValues(alpha: lightAlpha));

    // Tema-aware border — dark: beyaz, light: siyah
    final resolvedBorder = border ??
        Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.black.withValues(alpha: 0.07),
          width: 0.8,
        );

    final resolvedShadow = boxShadow ??
        NeerShadows.soft();

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
