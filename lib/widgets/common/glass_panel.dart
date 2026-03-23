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
    this.blurSigma = 28,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.boxShadow,
    this.border,
    this.backgroundColor,
    this.darkAlpha = 0.08,
    this.lightAlpha = 0.38,
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
    this.darkAlpha = 0.10,
    this.lightAlpha = 0.45,
  })  : borderRadius = const BorderRadius.vertical(top: Radius.circular(35)),
        blurSigma = 32;

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
    this.darkAlpha = 0.06,
    this.lightAlpha = 0.30,
  })  : borderRadius = BorderRadius.zero,
        blurSigma = 40;

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
    this.darkAlpha = 0.08,
    this.lightAlpha = 0.38,
  })  : borderRadius = const BorderRadius.all(Radius.circular(22)),
        blurSigma = 24;

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
    this.darkAlpha = 0.10,
    this.lightAlpha = 0.35,
  })  : borderRadius = const BorderRadius.all(Radius.circular(20)),
        blurSigma = 20;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = backgroundColor ??
        (isDark
            ? NeerColors.darkSurface.withValues(alpha: darkAlpha)
            : Colors.white.withValues(alpha: lightAlpha));

    // Jilet kenarlar — always 1px, alpha 0.18
    final resolvedBorder = border ??
        Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
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
