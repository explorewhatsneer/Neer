import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:go_router/go_router.dart';

// CORE IMPORTLARI
import '../../core/theme_styles.dart';
import '../../core/text_styles.dart';
import '../../core/app_strings.dart';

import '../../widgets/common/check_in_button.dart';
import '../../widgets/common/glass_panel.dart';

class PlaceSheet {
  static void show(BuildContext context, Map<String, dynamic> placeData, String placeId) {
    HapticFeedback.lightImpact(); // Açılışta titreşim
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 🔥 1. GERÇEK VERİLERİ AYIKLA
    final String name = placeData['name'] ?? "Mekan İsmi";
    final String category = placeData['category'] ?? "Genel";
    
    // Puan kontrolü (Supabase int veya double gönderebilir)
    final double rating = (placeData['average_rating'] is num) 
        ? (placeData['average_rating'] as num).toDouble() 
        : 0.0;
        
    // Resim kontrolü (DB'de yoksa rastgele ata)
    final String placeImageUrl = (placeData['image'] != null && placeData['image'].toString().isNotEmpty)
        ? placeData['image']
        : "https://picsum.photos/800/400?sig=$placeId";

    // Puan durumuna göre etiket ve renk
    String ratingLabel = "Mükemmel";
    Color ratingColor = const Color(0xFF34C759); // Yeşil
    if (rating < 4.0) {
      ratingLabel = "İyi";
      ratingColor = Colors.orange;
    }
    if (rating < 3.0) {
      ratingLabel = "Ortalama";
      ratingColor = Colors.grey;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, 
      isScrollControlled: true, 
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65, 
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => GlassPanel.sheet(
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 10))
              ],
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1)),
              child: ListView(
                controller: controller,
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                children: [
                  // --- GÖRSEL KISIM (PARALLAX HEADER) ---
                  Stack(
                    children: [
                      // 🔥 Gerçek Resim
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          image: DecorationImage(
                            image: NetworkImage(placeImageUrl), 
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Gradient Overlay
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              isDark ? Colors.black.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9)
                            ],
                            stops: const [0.5, 1.0]
                          ),
                        ),
                      ),
                      // Grab Bar
                      Positioned(
                        top: 12, left: 0, right: 0,
                        child: Center(
                          child: Container(
                            width: 50, height: 5, 
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8), 
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]
                            )
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -30), // Görselin üzerine bindir
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 🔥 Gerçek İsim
                                    Text(
                                      name, 
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.h2.copyWith(
                                        fontSize: 28, 
                                        fontWeight: FontWeight.w800,
                                        height: 1.1,
                                        color: theme.textTheme.displayLarge?.color
                                      )
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_rounded, size: 16, color: theme.primaryColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          "İstanbul, Türkiye", // Şimdilik sabit, ilerde Geocoding ekleriz
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: theme.disabledColor, 
                                            fontWeight: FontWeight.w600
                                          )
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              // 🔥 Gerçek Puan Kutusu
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
                                  border: isDark ? Border.all(color: Colors.white12) : null,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      rating.toString(), 
                                      style: TextStyle(color: ratingColor, fontWeight: FontWeight.w900, fontSize: 18)
                                    ),
                                    Text(
                                      ratingLabel, 
                                      style: TextStyle(color: ratingColor, fontSize: 10, fontWeight: FontWeight.bold)
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),

                        // Chipler (Özellikler)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildModernChip(Icons.access_time_filled_rounded, AppStrings.openNow, const Color(0xFF34C759), theme),
                              const SizedBox(width: 10),
                              // 🔥 Gerçek Kategori
                              _buildModernChip(Icons.restaurant_menu_rounded, category, Colors.orange, theme),
                              const SizedBox(width: 10),
                              _buildModernChip(Icons.wifi_rounded, AppStrings.freeWifi, Colors.blue, theme),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 25),
                        Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.2)),
                        const SizedBox(height: 25),

                        // --- 1. ŞU AN BURADA OLANLAR (SİMÜLASYON) ---
                        // Not: Burası canlı veri değil, atmosferi doldurmak için simüle edildi.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.hereNow, 
                              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800)
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(alpha: 0.1), 
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.people_alt_rounded, size: 14, color: theme.primaryColor),
                                  const SizedBox(width: 5),
                                  Text("12 ${AppStrings.peopleCount}", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 6,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Align(
                                widthFactor: 0.8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.scaffoldBackgroundColor, width: 2.5),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5)]
                                  ),
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: theme.cardColor,
                                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${index + 20}'),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 30),

                        // --- 2. ZİYARET EDEN ARKADAŞLAR (SİMÜLASYON) ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.friendsVisited, 
                              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800)
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                children: [
                                  const Icon(Icons.history_rounded, size: 14, color: Colors.orange),
                                  const SizedBox(width: 5),
                                  Text("4 ${AppStrings.friends}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 15),
                        
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 4, 
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Align(
                                widthFactor: 0.8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: theme.scaffoldBackgroundColor, width: 2.5),
                                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 5)]
                                  ),
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: theme.cardColor,
                                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${index + 50}'),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 40),

                        // --- AKSİYON BUTONLARI ---
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: CheckInButton(
                                venueId: placeId,
                                venueName: name, // 🔥 Gerçek İsim
                                venueImage: placeImageUrl, // 🔥 Gerçek Resim
                                onCheckInSuccess: () {
                                  Navigator.pop(context); // Pencereyi kapat
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: theme.dividerColor, width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    backgroundColor: theme.cardColor.withValues(alpha: 0.5),
                                    foregroundColor: theme.textTheme.bodyLarge?.color,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.pop(context);
                                    // 🔥 Gerçek Detay Sayfasına Git
                                    context.push('/venue/$placeId', extra: {'venueName': name, 'imageUrl': placeImageUrl});
                                  }, 
                                  child: Text(
                                    AppStrings.details, 
                                    style: AppTextStyles.button.copyWith(color: theme.textTheme.bodyLarge?.color)
                                  ),
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
    );
  }

  static Widget _buildModernChip(IconData icon, String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2))
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}