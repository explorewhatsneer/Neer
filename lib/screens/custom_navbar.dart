import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';
import '../core/text_styles.dart';
import '../core/app_strings.dart';

class CustomNavBar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTabChange;

  const CustomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad > 0 ? bottomPad : 16),
      child: SizedBox(
        height: 80,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // ─── GLASS PILL BAR ───
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: isDark ? AppColors.darkNavBarGradient : AppColors.navBarGradient,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(0, Icons.notifications_rounded, AppStrings.navProfile, isDark),
                      _buildNavItem(1, Icons.chat_bubble_rounded, AppStrings.navChat, isDark),
                      const SizedBox(width: 56), // Center FAB boşluğu
                      _buildNavItem(3, Icons.person_rounded, AppStrings.navFeed, isDark),
                      _buildNavItem(4, Icons.bolt_rounded, AppStrings.navCatch, isDark),
                    ],
                  ),
                ),
              ),
            ),

            // ─── CENTER FAB (+) BUTTON ───
            Positioned(
              top: 0,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onTabChange(2);
                },
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkGradientStart
                          : AppColors.gradientStart,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.40),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    activeIndex == 2 ? Icons.location_on_rounded : Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withValues(alpha: isDark ? 0.15 : 0.30)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.55),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
