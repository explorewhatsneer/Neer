import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../../core/neer_design_system.dart';
import '../../core/app_strings.dart';
import '../common/glass_panel.dart';
import '../common/animated_press.dart';

// ═══════════════════════════════════════════════════════
// GLASS TEXT FIELD — glassmorphism input
// ═══════════════════════════════════════════════════════

class NeerTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType inputType;

  const NeerTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.maxLines = 1,
    this.inputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GlassPanel.card(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: inputType,
        style: NeerTypography.bodyLarge.copyWith(
          color: isDark ? Colors.white : Colors.black.withValues(alpha: 0.87),
        ),
        cursorColor: theme.primaryColor,
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: NeerTypography.bodySmall.copyWith(
            color: isDark ? Colors.white54 : Colors.black45,
            fontWeight: FontWeight.w600,
          ),
          icon: Icon(icon, color: theme.primaryColor.withValues(alpha: 0.8), size: 22),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SECTION TITLE
// ═══════════════════════════════════════════════════════

class EditSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  const EditSectionTitle({super.key, required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: NeerColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: NeerColors.primary, size: 16),
            ),
            const SizedBox(width: 10),
          ],
          Text(
            title,
            style: NeerTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.80),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// AVATAR EDIT — ProfileHeaderBackground style
// ═══════════════════════════════════════════════════════

class EditAvatarArea extends StatelessWidget {
  final File? selectedImage;
  final String? currentUrl;
  final VoidCallback onEditTap;

  const EditAvatarArea({
    super.key,
    required this.selectedImage,
    required this.currentUrl,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ImageProvider<Object>? imageProvider;
    if (selectedImage != null) {
      imageProvider = FileImage(selectedImage!);
    } else if (currentUrl != null && currentUrl!.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(currentUrl!);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Blurred background
        if (imageProvider != null)
          Image(image: imageProvider, fit: BoxFit.cover)
        else
          Container(
            color: isDark ? const Color(0xFF1A0F1A) : const Color(0xFFEDE8FF),
          ),
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.62)
                  : Colors.white.withValues(alpha: 0.52),
            ),
          ),
        ),

        // Avatar + edit button
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              AnimatedPress(
                onTap: onEditTap,
                child: Stack(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: imageProvider != null
                            ? Image(image: imageProvider, fit: BoxFit.cover)
                            : Container(
                                color: isDark ? NeerColors.darkSurface : NeerColors.gray200,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 44,
                                  color: isDark ? Colors.white38 : Colors.black26,
                                ),
                              ),
                      ),
                    ),
                    // Edit badge
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: NeerColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.black : Colors.white,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: NeerColors.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              AnimatedPress(
                onTap: onEditTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    AppStrings.changePhoto,
                    style: NeerTypography.caption.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
