import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// CORE IMPORTLARI
import '../../core/theme_styles.dart';
import '../../core/text_styles.dart';
import '../../core/app_strings.dart';

import '../../services/supabase_service.dart';
import '../common/app_cached_image.dart';

class RequestSummaryTile extends StatelessWidget {
  final List<Map<String, dynamic>> requests; // Supabase'den gelen ham veri
  final VoidCallback onTap;

  const RequestSummaryTile({
    super.key,
    required this.requests,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Listenin en başındaki (en yeni) isteği alıyoruz
    final firstRequest = requests.first;
    final String senderId = firstRequest['sender_id'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppThemeStyles.radius16,
        boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppThemeStyles.radius16,
          onTap: () {
            HapticFeedback.lightImpact(); 
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            // 🔥 KRİTİK NOKTA: Gönderen kişinin bilgilerini burada çekiyoruz
            child: FutureBuilder<Map<String, dynamic>?>(
              future: SupabaseService().getProfileSingle(senderId),
              builder: (context, snapshot) {
                // Varsayılan değerler (Veri yüklenirken veya hata varsa)
                String titleText = AppStrings.followRequest;
                String subtitleText = "Yükleniyor...";
                String? imageUrl;

                if (snapshot.hasData) {
                  final user = snapshot.data!;
                  final String fullName = user['full_name'] ?? "Kullanıcı";
                  final String firstName = fullName.split(' ').first; // Sadece ilk isim
                  imageUrl = user['avatar_url'];

                  // Metni oluşturma mantığı
                  if (requests.length == 1) {
                    titleText = AppStrings.followRequest;
                    subtitleText = "$fullName seni takip etmek istiyor.";
                  } else {
                    titleText = AppStrings.followRequests;
                    subtitleText = "$firstName ${AppStrings.and} ${requests.length - 1} ${AppStrings.othersWantToFollow}";
                  }
                }

                return Row(
                  children: [
                    // --- AVATAR YIĞINI (STACK) ---
                    SizedBox(
                      width: 58,
                      height: 50,
                      child: Stack(
                        children: [
                          // Arkadaki gölge resim (2 veya daha fazla istek varsa)
                          if (requests.length > 1)
                            Positioned(
                              right: 4, top: 2,
                              child: _buildAvatarBorder(
                                theme,
                                imageUrl: null, // Arkadaki resim boş olabilir (placeholder)
                                radius: 18,
                              ),
                            ),
                          
                          // Öndeki Ana Resim (Snapshot'tan gelen url)
                          Positioned(
                            left: 0, bottom: 2,
                            child: _buildAvatarBorder(
                              theme,
                              imageUrl: imageUrl,
                              radius: 20,
                            ),
                          ),

                          // Kırmızı Bildirim Sayısı
                          Positioned(
                            right: 0, top: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: theme.cardColor, width: 2),
                              ),
                              child: Text(
                                "${requests.length}",
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white, 
                                  fontSize: 10, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // --- METİN KISMI ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleText, 
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor
                            )
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitleText, 
                            maxLines: 2, 
                            overflow: TextOverflow.ellipsis, 
                            style: AppTextStyles.bodySmall.copyWith(
                              color: theme.disabledColor,
                              fontSize: 13
                            )
                          ),
                        ],
                      ),
                    ),

                    // --- OK İŞARETİ ---
                    Icon(
                      Icons.chevron_right_rounded, 
                      color: theme.disabledColor.withValues(alpha: 0.5),
                      size: 24,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Yardımcı Avatar Widget'ı
  Widget _buildAvatarBorder(ThemeData theme, {required String? imageUrl, required double radius}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.cardColor, width: 2.5),
      ),
      child: CachedAvatar(imageUrl: imageUrl ?? '', name: '', radius: radius),
    );
  }
}