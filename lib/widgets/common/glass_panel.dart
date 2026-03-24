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
    this.blurSigma = 40,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.constraints,
    this.boxShadow,
    this.border,
    this.backgroundColor,
    this.darkAlpha = 0.08,
    this.lightAlpha = 0.55,
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
    this.darkAlpha = 0.08,
    this.lightAlpha = 0.55,
  })  : borderRadius = const BorderRadius.all(Radius.circular(22)),
        blurSigma = 40;

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
    this.darkAlpha = 0.07,
    this.lightAlpha = 0.50,
  })  : borderRadius = const BorderRadius.all(Radius.circular(20)),
        blurSigma = 36;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Buzlu cam tonu — dark: şeffaf beyaz, light: opak beyaz
    final bgColor = backgroundColor ??
        Colors.white.withValues(alpha: isDark ? darkAlpha : lightAlpha);

    // Frosted kenar — ince beyaz
    final resolvedBorder = border ??
        Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.90),
          width: 1.0,
        );

    // Gölge — ClipRRect DIŞINDA uygulanır, cliplanmaz
    final resolvedShadow = boxShadow ?? NeerShadows.glass(isDark: isDark);

    // Dış kapsayıcı: boyut + margin + GÖLGE (clip dışı)
    return Container(
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: resolvedShadow,
      ),
      // ClipRRect sadece blur + renk katmanlarını kırpar; gölge bunun dışında kalır
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: borderRadius,
              border: resolvedBorder,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
