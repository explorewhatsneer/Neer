import 'dart:ui'; // ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:go_router/go_router.dart';

// CORE IMPORTLARI
import '../../core/theme_styles.dart';
import '../../core/text_styles.dart';
import '../../core/app_strings.dart';
import '../../core/constants.dart'; // AppColors için
import '../../core/app_router.dart';

// 🔥 Servis Importu
import '../../services/supabase_service.dart';

class UserSheet {
  static void show(BuildContext context, Map<String, dynamic> userData, String targetUid) {
    HapticFeedback.lightImpact(); // Açılış titreşimi
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 🔥 VERİ GÜVENLİĞİ VE EŞLEŞTİRME
    final String profileImage = userData['avatar_url'] ?? userData['profile_image'] ?? "https://i.pravatar.cc/300?u=$targetUid";
    final String coverImage = "https://picsum.photos/800/400?random=$targetUid"; 
    
    final String displayName = userData['full_name'] ?? userData['name'] ?? userData['username'] ?? "Kullanıcı";
    final String username = userData['username'] ?? "user";
    final String bio = userData['bio'] ?? "Merhaba, ben Neer kullanıyorum! 👋";
    
    final String trustScore = (userData['trust_score'] ?? 5.0).toString();
    final String followers = (userData['followers_count'] ?? 126).toString();
    final bool isOnline = userData['is_online'] ?? false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75, 
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                // Dinamik Glass Rengi
                color: isDark ? Colors.black.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 10))
                ],
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1)),
              ),
              child: ListView(
                controller: controller,
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  
                  // --- HEADER (KAPAK + AVATAR) ---
                  SizedBox(
                    height: 340, 
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // 1. Kapak Resmi
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(coverImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // 2. Gradient Overlay
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                isDark ? Colors.black.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.95), 
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                        
                        // Tutamaç
                        Positioned(
                          top: 12,
                          child: Container(
                            width: 40, height: 4, 
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7), 
                              borderRadius: BorderRadius.circular(10)
                            )
                          ),
                        ),

                        // 3. Profil Bilgileri
                        Positioned(
                          top: 130, 
                          left: 0, right: 0,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.black45 : Colors.white.withValues(alpha: 0.5), 
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
                                    ),
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundColor: theme.cardColor,
                                      backgroundImage: NetworkImage(profileImage),
                                    ),
                                  ),
                                  if (isOnline)
                                    Positioned(
                                      bottom: 8, right: 8,
                                      child: Container(
                                        width: 22, height: 22,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF34C759),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: isDark ? Colors.black : Colors.white, width: 3.5),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              Text(
                                displayName, 
                                style: AppTextStyles.h2.copyWith(
                                  fontWeight: FontWeight.w800, 
                                  color: theme.textTheme.displayLarge?.color,
                                )
                              ),
                              
                              const SizedBox(height: 6),
                              
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Yakınlarda", 
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: theme.disabledColor, 
                                      fontWeight: FontWeight.w600
                                    )
                                  ),
                                  Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 12, color: theme.dividerColor),
                                  Text(
                                    "@$username", 
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: theme.disabledColor,
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- İÇERİK ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // İstatistikler
                        Row(
                          children: [
                            _buildStatCard(trustScore, "Güven Skoru", Icons.shield_rounded, const Color(0xFF34C759), theme),
                            const SizedBox(width: 10),
                            _buildStatCard(followers, "Takipçi", Icons.group_rounded, AppColors.accent, theme),
                            const SizedBox(width: 10),
                            _buildStatCard("5. Lv", "Seviye", Icons.star_rounded, Colors.blue, theme),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Hakkında
                        Text("Hakkında", style: AppTextStyles.h3.copyWith(fontSize: 18)),
                        const SizedBox(height: 8),
                        Text(
                          bio,
                          style: AppTextStyles.bodyLarge.copyWith(
                            height: 1.5,
                            color: theme.textTheme.bodyMedium?.color
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Ortak Bağlantılar
                        Text("Ortak Bağlantılar", style: AppTextStyles.h3.copyWith(fontSize: 18)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: 75, 
                              height: 35,
                              child: Stack(
                                children: [
                                  Positioned(left: 0, child: _buildMiniAvatar("https://i.pravatar.cc/150?img=5", theme)),
                                  Positioned(left: 20, child: _buildMiniAvatar("https://i.pravatar.cc/150?img=8", theme)),
                                  Positioned(left: 40, child: _buildMiniAvatar("https://i.pravatar.cc/150?img=12", theme)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.caption.copyWith(color: theme.disabledColor),
                                  children: [
                                    const TextSpan(text: "Sen ve "),
                                    TextSpan(text: "3 ortak arkadaşınız", style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                                    const TextSpan(text: " var."),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // 🔥 SON GİTTİĞİ YERLER (Başlık FutureBuilder'ın DIŞINA alındı)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Son Gittiği Yerler", 
                              style: AppTextStyles.h3.copyWith(fontSize: 18)
                            ),
                            Text(
                              "Tümünü Gör", 
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary, 
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // 🔥 ARTIK LİSTE BURADA YÜKLENİYOR
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: SupabaseService().getRecentVisits(targetUid),
                          builder: (context, snapshot) {
                            // Yükleniyor
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                height: 100,
                                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            }

                            final visits = snapshot.data ?? [];

                            // Boş İse Mesaj Göster (Ama Başlık Yukarıda Kaldı!)
                            if (visits.isEmpty) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  color: theme.cardColor.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: isDark ? Border.all(color: Colors.white12) : null,
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.map_outlined, color: theme.disabledColor, size: 30),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Henüz bir check-in yapmamış.", 
                                      style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)
                                    ),
                                  ],
                                ),
                              );
                            }

                            // Dolu İse Listeyi Göster
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: visits.map((visit) {
                                  // Zaman Hesaplama
                                  DateTime visitDate = DateTime.parse(visit['visit_time']);
                                  Duration diff = DateTime.now().difference(visitDate);
                                  String timeAgo;
                                  if (diff.inHours < 24) {
                                    timeAgo = "${diff.inHours}s önce";
                                  } else {
                                    timeAgo = "${diff.inDays} gün önce";
                                  }

                                  return _buildRecentPlaceItem(
                                    context, 
                                    visit['place_id'].toString(), 
                                    visit['place_name'], 
                                    timeAgo, 
                                    visit['place_image'] ?? "https://picsum.photos/200", 
                                    theme
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 40),

                        // --- AKSİYON BUTONLARI ---
                        Row(
                          children: [
                            // Mesaj Gönder
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                  elevation: 8,
                                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                                ),
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  Navigator.pop(context);
                                  context.push(AppRoutes.chat, extra: {'userId': targetUid, 'userName': displayName, 'userImage': null});
                                },
                                icon: const Icon(Icons.chat_bubble_rounded, size: 22),
                                label: Text("Mesaj Gönder", style: AppTextStyles.button),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Profil Butonu
                            Expanded(
                              flex: 2,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: theme.dividerColor, width: 1.5),
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                  backgroundColor: theme.cardColor.withValues(alpha: 0.5),
                                  foregroundColor: theme.textTheme.bodyLarge?.color,
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(context);
                                  context.push('/profile/$targetUid');
                                }, 
                                child: Text("Profili Gör", style: AppTextStyles.button.copyWith(color: theme.textTheme.bodyLarge?.color)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- YARDIMCI WIDGETLAR ---
  static Widget _buildMiniAvatar(String url, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: theme.cardColor, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
      ),
      child: CircleAvatar(radius: 16, backgroundImage: NetworkImage(url)),
    );
  }

  static Widget _buildStatCard(String val, String label, IconData icon, Color color, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12), 
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16), 
          border: isDark ? Border.all(color: Colors.white12) : null,
          boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color), 
            const SizedBox(height: 6),
            Text(val, style: AppTextStyles.h3.copyWith(fontSize: 16)), 
            Text(label, style: AppTextStyles.caption.copyWith(color: theme.disabledColor, fontWeight: FontWeight.bold)), 
          ],
        ),
      ),
    );
  }

  static Widget _buildRecentPlaceItem(BuildContext context, String venueId, String name, String time, String imgUrl, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/venue/$venueId', extra: {'venueName': name, 'imageUrl': imgUrl});
      },
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? Border.all(color: Colors.white12) : null,
          boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(imgUrl, height: 80, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 10, color: theme.disabledColor),
                      const SizedBox(width: 3),
                      Text(time, style: AppTextStyles.caption.copyWith(color: theme.disabledColor, fontSize: 10)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}