import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/neer_design_system.dart';
import '../../core/app_strings.dart';

// ==========================================
// 🏷 SECTION HEADER — gradient accent left bar
// ==========================================
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon; // opsiyonel — geriye dönük uyum
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 10),
      child: Row(
        children: [
          // Sol gradient accent çizgi
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              gradient: NeerGradients.purplePink,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: NeerTypography.h3.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (onActionTap != null)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onActionTap!();
              },
              child: Text(
                AppStrings.seeAll,
                style: NeerTypography.caption.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}