import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

// CORE IMPORTLARI
import '../../core/text_styles.dart'; 
import '../../core/app_strings.dart';  

class ProfileHeader extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String username;
  final String bio;
  
  final String followersCount;
  final String followingCount;
  final String friendsCount; // 🔥 EKLENDİ
  final double trustScore;   // 🔥 EKLENDİ

  const ProfileHeader({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.username,
    required this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.friendsCount, // 🔥
    required this.trustScore,   // 🔥
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Yazı gölgeleri
    final List<Shadow> textShadows = [
      Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 1)),
    ];

    // Bileşen Boyutu (Avatar ve Güven Halkası için)
    const double componentSize = 68.0; 

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. ARKA PLAN RESMİ
        Image.network(
          imageUrl.isNotEmpty ? imageUrl : "https://i.pravatar.cc/300", 
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1C1C1E)),
        ),
        
        // 2. GELİŞMİŞ BLUR VE GRADIENT
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), 
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.3),
                    theme.scaffoldBackgroundColor, 
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ),

        // 3. İÇERİK
        Positioned(
          bottom: 80, // TabBar payı
          left: 16, 
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              // --- ÜST SATIR: AVATAR - İSTATİSTİKLER - GÜVEN ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  
                  // 1. PREMIUM AVATAR (Çift Çerçeve)
                  SizedBox(
                    width: componentSize, height: componentSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dış Cam Halka
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                          ),
                        ),
                        // İç Avatar
                        Container(
                          margin: const EdgeInsets.all(4), 
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(imageUrl.isNotEmpty ? imageUrl : "https://i.pravatar.cc/300"),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 5)],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. ORTA: İSTATİSTİKLER (3'lü Yapı)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                      children: [
                        _buildStatItem(AppStrings.followers, followersCount), 
                        _buildStatItem(AppStrings.following, followingCount),
                        _buildStatItem(AppStrings.friends, friendsCount), // 🔥 Arkadaş eklendi
                      ],
                    ),
                  ),

                  // 3. SAĞ: GÜVEN SKORU (🔥 ARTIK BOŞ DEĞİL)
                  SizedBox(
                    width: componentSize, height: componentSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Arka Halka (Silik)
                        SizedBox(
                          width: componentSize, height: componentSize,
                          child: CircularProgressIndicator(
                            value: 1.0, strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.1)),
                          ),
                        ),
                        // Ön Halka (Değer)
                        SizedBox(
                          width: componentSize, height: componentSize,
                          child: CircularProgressIndicator(
                            value: trustScore / 10.0, strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(_getScoreColor(trustScore)),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        // Değer Yazısı
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shield_moon_rounded, size: 14, color: _getScoreColor(trustScore)),
                            Text(
                              trustScore.toStringAsFixed(1),
                              style: AppTextStyles.h3.copyWith(color: Colors.white, fontSize: 13, height: 1.0, shadows: textShadows),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // --- ALT: İSİM & BIO GLASS PANEL ---
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08), 
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SOL: İsim ve Kullanıcı Adı
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "@$username",
                                style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        
                        // AYRAÇ
                        Container(
                          width: 1, height: 35,
                          color: Colors.white.withValues(alpha: 0.15),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),

                        // SAĞ: Bio
                        Expanded(
                          flex: 6,
                          child: Text(
                            bio.isNotEmpty ? bio : "Merhaba, ben Neer kullanıyorum!", 
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13, 
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
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

  // --- HELPER METHODLAR ---

  Widget _buildStatItem(String label, String countStr) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          countStr,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17, letterSpacing: -0.5),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return const Color(0xFF30D158); 
    if (score >= 5.0) return const Color(0xFFFF9F0A); 
    return const Color(0xFFFF453A);                   
  }
}