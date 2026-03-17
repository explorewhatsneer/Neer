import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// CORE IMPORTLARI
import '../../core/text_styles.dart';
import '../../core/app_strings.dart';  

class FriendProfileHeader extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String username;
  final String bio;
  final bool isOnline;
  
  final int followersCount;
  final int followingCount;
  final int friendsCount;
  final double trustScore;

  const FriendProfileHeader({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.username,
    required this.bio,
    required this.isOnline,
    required this.followersCount,
    required this.followingCount,
    required this.friendsCount,
    required this.trustScore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Yazı gölgeleri (Shadows)
    final List<Shadow> textShadows = [
      Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 1)),
    ];

    // Bileşen Boyutu (Avatar ve Güven Halkası için)
    const double componentSize = 68.0; 

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. ARKA PLAN RESMİ (cache'li)
        CachedNetworkImage(
          imageUrl: imageUrl.isNotEmpty ? imageUrl : "https://i.pravatar.cc/300",
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, __) => Container(color: const Color(0xFF1C1C1E)),
          errorWidget: (_, __, ___) => Container(color: const Color(0xFF1C1C1E)),
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
                    theme.scaffoldBackgroundColor, // Sayfayla birleşir
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
              
              // --- ÜST: AVATAR - İSTATİSTİK - GÜVEN ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  
                  // 1. PREMIUM AVATAR
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
                        // İç Avatar (cache'li + Hero)
                        Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 5)],
                          ),
                          child: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: imageUrl.isNotEmpty ? imageUrl : "https://i.pravatar.cc/300",
                              fit: BoxFit.cover,
                              width: componentSize - 8,
                              height: componentSize - 8,
                              placeholder: (_, __) => Container(color: Colors.grey.shade800),
                              errorWidget: (_, __, ___) => Container(
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.person, color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                        if (isOnline)
                          Positioned(
                            bottom: 4, right: 4,
                            child: Container(
                              width: 12, height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF34C759),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // 2. ORTA: İSTATİSTİKLER
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                      children: [
                        _buildStatItem(AppStrings.followers, followersCount), 
                        _buildStatItem(AppStrings.following, followingCount),
                        _buildStatItem(AppStrings.friends, friendsCount),
                      ],
                    ),
                  ),

                  // 3. SAĞ: GÜVEN SKORU
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
                            bio.isNotEmpty ? bio : "...", 
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

  Widget _buildStatItem(String label, int count) {
    String displayCount = count > 999 ? "${(count / 1000).toStringAsFixed(1)}k" : count.toString();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          displayCount,
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