import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';

class CustomNavBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTabChange;

  const CustomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTabChange,
  });

  // Doğru ikon eşlemesi: 0=Profil, 1=Chat, 2=Map(pin), 3=Feed, 4=Catch
  static const List<IconData> _icons = [
    Icons.person_rounded,
    Icons.chat_bubble_rounded,
    Icons.pin_drop_rounded,       // Center — pin ikonu
    Icons.dynamic_feed_rounded,
    Icons.bolt_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: 72 + bottomPad,
          padding: EdgeInsets.only(bottom: bottomPad),
          decoration: BoxDecoration(
            gradient: isDark ? AppColors.darkNavBarGradient : AppColors.navBarGradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.40),
                width: 0.5,
              ),
            ),
            boxShadow: isDark
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.40), blurRadius: 20, offset: const Offset(0, -4))]
                : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, -4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) {
              // Center buton (pin) özel tasarım
              if (index == 2) return _buildCenterButton(isDark);
              return _buildNavItem(index, isDark);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton(bool isDark) {
    final isActive = activeIndex == 2;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTabChange(2);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isActive ? AppColors.primaryGradient : null,
          color: isActive ? null : Colors.white.withValues(alpha: isDark ? 0.10 : 0.25),
          border: Border.all(
            color: isActive
                ? Colors.white.withValues(alpha: 0.30)
                : Colors.white.withValues(alpha: isDark ? 0.08 : 0.20),
            width: 1.5,
          ),
          boxShadow: isActive
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))]
              : [],
        ),
        child: Icon(
          Icons.pin_drop_rounded,
          color: Colors.white,
          size: isActive ? 26 : 22,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, bool isDark) {
    final isActive = index == activeIndex;

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          HapticFeedback.lightImpact();
          onTabChange(index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: isDark ? 0.15 : 0.28)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _icons[index],
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.50),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
