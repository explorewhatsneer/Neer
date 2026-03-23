import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/neer_design_system.dart';

/// Premium animated mesh gradient background — Apple VisionOS / Siri style.
///
/// VIBRANT VERSION — high-saturation orbs, large sizes, high alpha.
/// The orbs must be CLEARLY visible — not subtle.
class PremiumBackground extends StatefulWidget {
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
      duration: const Duration(seconds: 14),
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

    final baseGradient = isDark
        ? NeerGradients.backgroundDark
        : NeerGradients.backgroundLight;

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

class _StaticBackground extends StatelessWidget {
  final bool isDark;
  final LinearGradient baseGradient;

  const _StaticBackground({required this.isDark, required this.baseGradient});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: baseGradient)),
        ..._buildOrbs(isDark, 0.0),
        const _NoiseOverlay(),
      ],
    );
  }
}

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
        DecoratedBox(decoration: BoxDecoration(gradient: baseGradient)),
        ..._buildOrbs(isDark, t),
        const _NoiseOverlay(),
      ],
    );
  }
}

/// Builds 5 large, VIBRANT positioned gradient orbs.
///
/// Colors are highly saturated, alphas are HIGH (0.5-0.8).
/// Orb sizes are LARGE (0.7-1.0 of screen).
List<Widget> _buildOrbs(bool isDark, double t) {
  final colors = isDark
      ? [
          const Color(0xFF8B3FA0), // Vivid purple
          const Color(0xFF3A5FC4), // Electric blue
          const Color(0xFFB83A70), // Hot pink / magenta
          const Color(0xFF2855A0), // Rich cobalt
          const Color(0xFF6B2D90), // Deep violet
        ]
      : [
          const Color(0xFFFF85B0), // Vibrant rose
          const Color(0xFFA080E0), // Saturated lavender
          const Color(0xFFE080C0), // Hot pink
          const Color(0xFF80A0F0), // Bright periwinkle
          const Color(0xFFD090E8), // Orchid
        ];

  // Dark modda 3 orb (daha az yük), light'ta 5 orb
  final orbCount = isDark ? 3 : 5;
  final alphas = isDark
      ? [0.26, 0.22, 0.20, 0.0, 0.0]
      : [0.55, 0.45, 0.50, 0.40, 0.42];

  final basePositions = [
    const Alignment(-1.1, -1.0),  // sol üst köşe dışı
    const Alignment(1.1, -0.9),   // sağ üst köşe dışı
    const Alignment(-1.0, 1.0),   // sol alt köşe dışı
    const Alignment(1.0, 1.0),    // sağ alt köşe dışı
    const Alignment(0.0, 0.1),    // merkez (sabit)
  ];

  // LARGE orb sizes — must fill significant screen area
  final sizes = [0.90, 0.75, 0.80, 0.70, 0.65];

  final phases = [0.0, 0.20, 0.40, 0.60, 0.80];

  return List.generate(orbCount, (i) {
    final phase = (t + phases[i]) % 1.0;
    final dx = math.sin(phase * 2 * math.pi) * 0.35;
    final dy = math.cos(phase * 2 * math.pi) * 0.30;

    final alignment = Alignment(
      (basePositions[i].x + dx).clamp(-1.3, 1.3),
      (basePositions[i].y + dy).clamp(-1.3, 1.3),
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
                  colors[i].withValues(alpha: alphas[i] * 0.5),
                  colors[i].withValues(alpha: alphas[i] * 0.15),
                  colors[i].withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  });
}

/// Lightweight noise grain overlay.
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
    final random = math.Random(42);
    final color = isDark ? Colors.white : Colors.black;
    final alpha = isDark ? 0.03 : 0.02;

    final dotCount = (size.width * size.height / 700).toInt().clamp(300, 2000);

    for (int i = 0; i < dotCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      paint.color = color.withValues(alpha: alpha + random.nextDouble() * 0.02);
      canvas.drawCircle(Offset(x, y), 0.5 + random.nextDouble() * 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
