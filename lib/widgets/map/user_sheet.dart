import 'dart:ui'; // ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback

// CORE IMPORTLARI
import '../../core/theme_styles.dart'; 
import '../../core/text_styles.dart';
import '../../core/app_strings.dart'; 

import '../../screens/chat_screen.dart';
import '../../screens/friend_profile_screen.dart';
import '../../screens/business_profile_screen.dart';

class UserSheet {
  static void show(BuildContext context, Map<String, dynamic> userData, String targetUid) {
    HapticFeedback.lightImpact(); // Açılış titreşimi
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Güvenli Veri Çekimi
    final String profileImage = userData['profile_image'] ?? "https://i.pravatar.cc/300?u=$targetUid";
    final String coverImage = "https://picsum.photos/800/400?random=$targetUid"; 

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
                color: isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 10))
                ],
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1)),
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

                        // 2. Gradient Overlay (Yumuşak Geçiş)
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9), 
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                        
                        // Tutamaç (Grab Bar)
                        Positioned(
                          top: 12,
                          child: Container(
                            width: 40, height: 4, 
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7), 
                              borderRadius: BorderRadius.circular(10)
                            )
                          ),
                        ),

                        // 3. Profil Bilgileri (Avatar + İsim)
                        Positioned(
                          top: 130, // Kapak resminin altından başlar
                          left: 0, right: 0,
                          child: Column(
                            children: [
                              // Avatar
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.black45 : Colors.white.withOpacity(0.5), 
                                      shape: BoxShape.circle,
                                      border: Border.all(color: theme.primaryColor.withOpacity(0.3), width: 1),
                                    ),
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundColor: theme.cardColor,
                                      backgroundImage: NetworkImage(profileImage),
                                    ),
                                  ),
                                  // Online Noktası
                                  Positioned(
                                    bottom: 8, right: 8,
                                    child: Container(
                                      width: 22, height: 22,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF34C759), // Online Yeşili
                                        shape: BoxShape.circle,
                                        border: Border.all(color: isDark ? Colors.black : Colors.white, width: 3.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // İsim
                              Text(
                                userData['name'] ?? AppStrings.nameless, 
                                // 🔥 Core Style: H2 (ExtraBold)
                                style: AppTextStyles.h2.copyWith(
                                  fontWeight: FontWeight.w800, 
                                  color: theme.textTheme.displayLarge?.color,
                                )
                              ),
                              
                              const SizedBox(height: 6),
                              
                              // Konum ve Kullanıcı Adı
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on_rounded, size: 16, color: theme.primaryColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Kadıköy, İstanbul", 
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: theme.disabledColor, 
                                      fontWeight: FontWeight.w600
                                    )
                                  ),
                                  Container(margin: const EdgeInsets.symmetric(horizontal: 8), width: 1, height: 12, color: theme.dividerColor),
                                  Text(
                                    "@${userData['username'] ?? 'kullanici'}", 
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
                            _buildCompactGlassStat("85%", AppStrings.trustScore, Icons.shield_rounded, const Color(0xFF34C759), theme),
                            const SizedBox(width: 10),
                            _buildCompactGlassStat("126", AppStrings.friends, Icons.group_rounded, Colors.orange, theme),
                            const SizedBox(width: 10),
                            _buildCompactGlassStat("5. Lv", AppStrings.level, Icons.star_rounded, Colors.blue, theme),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Hakkında
                        Text(
                          AppStrings.about, 
                          style: AppTextStyles.h3.copyWith(fontSize: 18)
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userData['bio'] ?? AppStrings.defaultBio,
                          style: AppTextStyles.bodyLarge.copyWith(
                            height: 1.5,
                            color: theme.textTheme.bodyMedium?.color
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Ortak Bağlantılar (Mini Avatarlar)
                        Text(
                          AppStrings.mutualConnections, 
                          style: AppTextStyles.h3.copyWith(fontSize: 18)
                        ),
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
                                    const TextSpan(text: "Sen, "),
                                    TextSpan(text: "Ahmet", style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                                    const TextSpan(text: " ve "),
                                    TextSpan(text: "4 diğer kişi", style: TextStyle(fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                                    const TextSpan(text: " tanıyor."),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // Son Gittiği Yerler
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.recentPlaces, 
                              style: AppTextStyles.h3.copyWith(fontSize: 18)
                            ),
                            Text(
                              AppStrings.seeAll, 
                              style: AppTextStyles.caption.copyWith(
                                color: theme.primaryColor, 
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildRecentPlaceItem(context, "place_1", "Espresso Lab", "2s ${AppStrings.hourAgo}", "https://picsum.photos/200/200?random=1", theme),
                              _buildRecentPlaceItem(context, "place_2", "Moda Sahil", "Dün", "https://picsum.photos/200/200?random=2", theme),
                              _buildRecentPlaceItem(context, "place_3", "Bina", "3 ${AppStrings.dayAgo}", "https://picsum.photos/200/200?random=3", theme),
                            ],
                          ),
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
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18), // Yükseklik standardı
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                  elevation: 8,
                                  shadowColor: theme.primaryColor.withOpacity(0.4),
                                ),
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(userName: userData['name'] ?? '', userId: targetUid)));
                                },
                                icon: const Icon(Icons.chat_bubble_rounded, size: 22),
                                label: Text(
                                  AppStrings.sendMessage, 
                                  style: AppTextStyles.button
                                ),
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
                                  backgroundColor: theme.cardColor.withOpacity(0.5),
                                  foregroundColor: theme.textTheme.bodyLarge?.color,
                                ),
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(context); 
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(targetUserId: targetUid)));
                                }, 
                                child: Text(
                                  AppStrings.visitProfile, 
                                  style: AppTextStyles.button.copyWith(color: theme.textTheme.bodyLarge?.color)
                                ),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
      ),
      child: CircleAvatar(radius: 16, backgroundImage: NetworkImage(url)),
    );
  }

  static Widget _buildCompactGlassStat(String val, String label, IconData icon, Color color, ThemeData theme) {
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
            Text(
              val, 
              style: AppTextStyles.h3.copyWith(fontSize: 16)
            ), 
            Text(
              label, 
              style: AppTextStyles.caption.copyWith(color: theme.disabledColor, fontWeight: FontWeight.bold)
            ), 
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusinessProfileScreen(venueId: venueId, venueName: name, imageUrl: imgUrl),
          ),
        );
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
                  Text(
                    name, 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis, 
                    style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 10, color: theme.disabledColor),
                      const SizedBox(width: 3),
                      Text(
                        time, 
                        style: AppTextStyles.caption.copyWith(color: theme.disabledColor, fontSize: 10)
                      ),
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