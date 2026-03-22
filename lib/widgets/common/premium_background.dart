import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/constants.dart';

/// Premium animated mesh gradient background — Apple VisionOS / Siri style.
///
/// Features:
/// - 4 soft orbs (RadialGradient, NOT BackdropFilter) at different positions
/// - Slow breathing animation (10-15s cycles) for organic movement
/// - Dark/Light mode adaptive colors from AppColors palette
/// - Optional noise grain overlay (lightweight)
/// - RepaintBoundary optimized — won't trigger child repaints
///
/// Usage:
/// ```dart
/// Stack(children: [
///   const PremiumBackground(),
///   // ... your UI content
/// ])
/// ```
class PremiumBackground extends StatefulWidget {
  /// Set to false to disable animation (static mesh gradient).
  final bool animate;

  const PremiumBackground({super.key, this.animate = true});

  @override
  State<PremiumBackground> createState() => _PremiumBackgroundState();
}

class _PremiumBackgroundState extends State<PremiumBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Base gradient (subtle, under orbs)
    final baseGradient = isDark
        ? AppColors.darkBackgroundGradient
        : AppColors.backgroundGradient;

    if (!widget.animate) {
      return RepaintBoundary(
        child: _StaticBackground(isDark: isDark, baseGradient: baseGradient),
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return _AnimatedBackground(
            isDark: isDark,
            baseGradient: baseGradient,
            t: t,
          );
        },
      ),
    );
  }
}

/// Static version — no animation, just positioned orbs.
class _StaticBackground extends StatelessWidget {
  final bool isDark;
  final LinearGradient baseGradient;

  const _StaticBackground({required this.isDark, required this.baseGradient});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient
        DecoratedBox(decoration: BoxDecoration(gradient: baseGradient)),

        // Static orbs
        ..._buildOrbs(isDark, 0.0),

        // Noise grain overlay
        const _NoiseOverlay(),
      ],
    );
  }
}

/// Animated version — orbs shift slowly.
class _AnimatedBackground extends StatelessWidget {
  final bool isDark;
  final LinearGradient baseGradient;
  final double t;

  const _AnimatedBackground({
    required this.isDark,
    required this.baseGradient,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base gradient
        DecoratedBox(decoration: BoxDecoration(gradient: baseGradient)),

        // Animated orbs
        ..._buildOrbs(isDark, t),

        // Noise grain overlay
        const _NoiseOverlay(),
      ],
    );
  }
}

/// Builds 4 positioned gradient orbs.
///
/// Uses RadialGradient (NOT BackdropFilter) for GPU efficiency.
/// The [t] parameter (0.0-1.0) drives the animation cycle.
List<Widget> _buildOrbs(bool isDark, double t) {
  // Orb definitions: [alignX, alignY, radius, color]
  // Positions shift slightly with sin/cos based on t

  final colors = isDark
      ? [
          const Color(0xFF5B3A7A), // Rich purple
          const Color(0xFF2E4070), // Deep blue
          const Color(0xFF7A3A5B), // Rose-plum
          const Color(0xFF1E3058), // Indigo
        ]
      : [
          const Color(0xFFE8A0BF), // Soft rose
          const Color(0xFFB8A9C9), // Lavender
          const Color(0xFFC8B8E0), // Light purple
          const Color(0xFFD5C0D8), // Pink-lavender
        ];

  final alphas = isDark
      ? [0.45, 0.35, 0.30, 0.25]
      : [0.50, 0.40, 0.35, 0.30];

  // Base positions (fractional alignment: -1 to 1)
  final basePositions = [
    const Alignment(-0.8, -0.6), // Top-left
    const Alignment(0.7, -0.3),  // Top-right
    const Alignment(-0.3, 0.7),  // Bottom-left
    const Alignment(0.6, 0.8),   // Bottom-right
  ];

  // Orb sizes (fraction of screen width)
  final sizes = [0.75, 0.60, 0.65, 0.55];

  // Animation offsets (each orb moves on a different phase)
  final phases = [0.0, 0.25, 0.50, 0.75];

  return List.generate(4, (i) {
    final phase = (t + phases[i]) % 1.0;
    final dx = math.sin(phase * 2 * math.pi) * 0.12;
    final dy = math.cos(phase * 2 * math.pi) * 0.08;

    final alignment = Alignment(
      (basePositions[i].x + dx).clamp(-1.2, 1.2),
      (basePositions[i].y + dy).clamp(-1.2, 1.2),
    );

    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: FractionallySizedBox(
          widthFactor: sizes[i],
          heightFactor: sizes[i],
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  colors[i].withValues(alpha: alphas[i]),
                  colors[i].withValues(alpha: alphas[i] * 0.4),
                  colors[i].withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  });
}

/// Very lightweight noise/grain overlay.
///
/// Uses a tiny custom painter with seeded random dots.
/// Opacity is 0.03 — barely visible but adds glass texture.
class _NoiseOverlay extends StatelessWidget {
  const _NoiseOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _NoisePainter(
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  final bool isDark;

  _NoisePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = math.Random(42); // Seeded for consistency
    final color = isDark ? Colors.white : Colors.black;
    final alpha = isDark ? 0.025 : 0.018;

    // Draw sparse dots — lightweight, no per-pixel computation
    final dotCount = (size.width * size.height / 800).toInt().clamp(200, 1500);

    for (int i = 0; i < dotCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      paint.color = color.withValues(alpha: alpha + random.nextDouble() * 0.015);
      canvas.drawCircle(Offset(x, y), 0.5 + random.nextDouble() * 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
