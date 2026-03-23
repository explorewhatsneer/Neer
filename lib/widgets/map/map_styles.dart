// Dosya: lib/widgets/map/map_styles.dart

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../core/neer_design_system.dart'; // NeerColors için

// --- CLUSTER TASARIMI (Bulanık Top) ---
class PremiumCluster extends StatelessWidget { 
  final int count;
  final Color color;
  const PremiumCluster({super.key, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 5))
            ],
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16,
                fontFamily: 'SF Pro' 
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- RENK VE İKON YARDIMCILARI ---
Color getCategoryColor(String category) { // _getCategoryColor -> getCategoryColor
  switch (category.toLowerCase()) {
    case 'kafe': return Colors.orangeAccent;
    case 'yemek': return Colors.redAccent;
    case 'bar': return Colors.purpleAccent;
    case 'sanat': return Colors.teal;
    case 'spor': return Colors.blueAccent;
    default: return NeerColors.primary;
  }
}

IconData getCategoryIcon(String category) { // _getCategoryIcon -> getCategoryIcon
  switch (category.toLowerCase()) {
    case 'kafe': return Icons.coffee_rounded;
    case 'yemek': return Icons.restaurant_rounded;
    case 'bar': return Icons.nightlife_rounded;
    case 'sanat': return Icons.palette_rounded;
    case 'spor': return Icons.fitness_center_rounded;
    default: return Icons.store_mall_directory_rounded;
  }
}

// --- ÜÇGEN ÇİZİMİ ---
class TriangleClipper extends CustomClipper<ui.Path> { // _TriangleClipper -> TriangleClipper
  @override
  ui.Path getClip(Size size) {
    final path = ui.Path();
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<ui.Path> oldClipper) => false;
}