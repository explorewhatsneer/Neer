import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants.dart';
import '../../core/text_styles.dart';
import '../../core/app_strings.dart';
import '../common/app_cached_image.dart';

// ==========================================
// 1. MODERN ARAMA ÇUBUĞU
// ==========================================
class ModernSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const ModernSearchBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 1,
              ),
              boxShadow: AppColors.adaptiveShadow(isDark, blur: 20, alpha: 0.06),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: theme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  AppStrings.searchHint, 
                  style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor, fontWeight: FontWeight.w500, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. KİŞİ SONUÇ KARTI (DİNAMİK HALKALI PUAN)
// ==========================================
class PersonResultCard extends StatelessWidget {
  final String name;
  final String username;
  final String imageUrl;
  final double trustScore; 
  final VoidCallback onTap;

  const PersonResultCard({
    super.key,
    required this.name,
    required this.username,
    required this.imageUrl,
    required this.trustScore, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    bool hasValidUrl = imageUrl.isNotEmpty && imageUrl.startsWith('http');

    // Puan Rengi
    final scoreColor = _getScoreColor(trustScore);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
            boxShadow: AppColors.adaptiveShadow(isDark, blur: 20, alpha: 0.06),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                      ),
                  child: CachedAvatar(
                    imageUrl: hasValidUrl ? imageUrl : '',
                    name: name,
                    radius: 24,
                  ),
                ),
                
                const SizedBox(width: 15),
                
                // İSİM VE KULLANICI ADI
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name, 
                        style: AppTextStyles.h3.copyWith(fontSize: 16, letterSpacing: -0.3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "@$username", 
                        style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // 🔥 YENİ DİNAMİK PUAN GÖSTERGESİ (FriendStatCard Stili)
                SizedBox(
                  width: 46, height: 46, // Boyut ayarlandı
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Arka Plan Halkası (Silik)
                      CircularProgressIndicator(
                        value: 1.0, // Tam daire
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation(scoreColor.withValues(alpha: 0.15)),
                      ),
                      // Ön Plan Halkası (Puan kadar dolu)
                      CircularProgressIndicator(
                        value: trustScore / 10.0,
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation(scoreColor),
                        strokeCap: StrokeCap.round,
                      ),
                      // Ortadaki Metin ve İkon
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shield_moon_rounded, size: 10, color: scoreColor),
                          Text(
                            trustScore.toStringAsFixed(1),
                            style: TextStyle(
                              color: scoreColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              height: 1.0
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
      ),
    );
  }

  // Puan rengini belirle
  Color _getScoreColor(double score) {
    if (score >= 8.0) return const Color(0xFF34C759); // Yeşil (Yüksek)
    if (score >= 5.0) return Colors.orange;           // Turuncu (Orta)
    return Colors.redAccent;                          // Kırmızı (Düşük)
  }
}

// 3. MEKAN SONUÇ KARTI (AYNI KALDI)
class PlaceResultCard extends StatelessWidget {
  final String name;
  final String category;
  final String address;
  final VoidCallback onTap;

  const PlaceResultCard({
    super.key,
    required this.name,
    required this.category,
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.14)
                : Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
            boxShadow: AppColors.adaptiveShadow(isDark, blur: 20, alpha: 0.06),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onTap();
              },
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.2), width: 1),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Colors.orange, size: 26),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name, 
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.3),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(category, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 12, color: theme.primaryColor)),
                          const SizedBox(width: 5),
                          Icon(Icons.circle, size: 4, color: theme.disabledColor),
                          const SizedBox(width: 5),
                          Expanded(child: Text(address, style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.disabledColor.withValues(alpha: 0.5)),
              ],
            ),
          ),
        ),
      ),
    ),
      ),
    );
  }
}