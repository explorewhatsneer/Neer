import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback

// CORE IMPORTLARI
import '../../core/theme_styles.dart'; 
import '../../core/text_styles.dart';
import '../../core/app_strings.dart'; 

class ReviewCard extends StatelessWidget {
  final String placeName;
  final String imageUrl;
  final String date;
  final String desc; // Bekleyenler için açıklama, Tamamlananlar için yorum
  final String? category;
  final double? rating; // Sadece tamamlananlarda var
  final bool isCompleted;
  final VoidCallback? onTap;

  const ReviewCard({
    super.key,
    required this.placeName,
    required this.imageUrl,
    required this.date,
    required this.desc,
    this.category,
    this.rating,
    this.isCompleted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppThemeStyles.radius24,
        boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mekan Görseli
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5)],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              
              // Bilgiler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            placeName, 
                            // 🔥 Core Style: BodyLarge (ExtraBold)
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w800, 
                              fontSize: 16
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Tamamlananlar İçin Puan Rozeti
                        if (isCompleted && rating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB400).withValues(alpha: 0.15), // Amber Rengi
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFFFB400), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  "$rating", 
                                  style: AppTextStyles.caption.copyWith(
                                    fontWeight: FontWeight.bold, 
                                    color: const Color(0xFFFFB400), 
                                    fontSize: 12
                                  )
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    if (!isCompleted && category != null)
                      Text(
                        category!, 
                        // 🔥 Core Style: LabelSmall / Caption
                        style: AppTextStyles.caption.copyWith(
                          color: theme.disabledColor, 
                          fontWeight: FontWeight.bold
                        )
                      ),
                    
                    const SizedBox(height: 6),
                    
                    Row(
                      children: [
                        if (!isCompleted) Icon(Icons.access_time_rounded, size: 14, color: theme.primaryColor),
                        if (!isCompleted) const SizedBox(width: 4),
                        Text(
                          date, 
                          style: AppTextStyles.caption.copyWith(
                            color: isCompleted ? theme.disabledColor : theme.textTheme.bodyMedium?.color, 
                            fontWeight: FontWeight.w600
                          )
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // --- İÇERİK ---
          if (!isCompleted) ...[
            // Bekleyen Durum (Bilgi Kutusu)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor, 
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: theme.primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      desc, 
                      // 🔥 Core Style: BodySmall
                      style: AppTextStyles.bodySmall
                    )
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Buton (Sadece Bekleyenler İçin)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: theme.primaryColor.withValues(alpha: 0.4),
                ),
                onPressed: () {
                  HapticFeedback.mediumImpact(); // Titreşim
                  if (onTap != null) onTap!();
                },
                child: Text(
                  AppStrings.rateNow, // 🔥 Core String
                  style: AppTextStyles.button.copyWith(fontSize: 15)
                ),
              ),
            )
          ] else ...[
            // Tamamlanan Durum (Yorum Metni)
            Text(
              desc, 
              // 🔥 Core Style: BodyMedium (Okunabilirlik)
              style: AppTextStyles.bodyLarge.copyWith(
                height: 1.4, 
                fontSize: 15,
                color: theme.textTheme.bodyMedium?.color
              ), 
              maxLines: 3, 
              overflow: TextOverflow.ellipsis
            ),
          ]
        ],
      ),
    );
  }
}