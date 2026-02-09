import 'dart:ui'; // ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback

// CORE IMPORTLARI
import '../../core/theme_styles.dart'; 
import '../../core/text_styles.dart';
import '../../core/app_strings.dart'; 

import '../../widgets/common/check_in_button.dart'; // Yolu düzelttim (venue içinde)
import '../../screens/business_profile_screen.dart';

class PlaceSheet {
  static void show(BuildContext context, Map<String, dynamic> placeData, String placeId) {
    HapticFeedback.lightImpact(); // Açılışta titreşim
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Görsel URL
    String safeIdForImage = placeId.isEmpty ? "default" : placeId;
    final String placeImageUrl = "https://picsum.photos/800/400?sig=$safeIdForImage";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, 
      isScrollControlled: true, 
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65, 
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                // Dinamik Arka Plan Rengi (Glass)
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
                  // --- GÖRSEL KISIM (PARALLAX HEADER) ---
                  Stack(
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(placeImageUrl), 
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Gradient Overlay (Yazıların okunması için)
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9)
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
                              color: Colors.white.withOpacity(0.8), 
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]
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
                                    Text(
                                      placeData['name'] ?? 'Mekan İsmi', 
                                      // 🔥 Core Style: H2 (ExtraBold)
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
                                          "Moda, Kadıköy • 120m", 
                                          // 🔥 Core Style: BodyMedium (Semibold)
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
                              // Puan Kutusu
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
                                    Text("4.8", style: TextStyle(color: const Color(0xFF34C759), fontWeight: FontWeight.w900, fontSize: 18)),
                                    Text(AppStrings.wonderful, style: const TextStyle(color: Color(0xFF34C759), fontSize: 10, fontWeight: FontWeight.bold)),
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
                              _buildModernChip(Icons.restaurant_menu_rounded, placeData['category'] ?? "Restoran", Colors.orange, theme),
                              const SizedBox(width: 10),
                              _buildModernChip(Icons.wifi_rounded, AppStrings.freeWifi, Colors.blue, theme),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 25),
                        Divider(height: 1, color: theme.dividerColor.withOpacity(0.2)),
                        const SizedBox(height: 25),

                        // --- 1. ŞU AN BURADA OLANLAR ---
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
                                color: theme.primaryColor.withOpacity(0.1), 
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
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]
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

                        // --- 2. ZİYARET EDEN ARKADAŞLAR ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.friendsVisited, 
                              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800)
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
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
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)]
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
                                venueName: placeData['name'] ?? "Mekan",
                                venueImage: placeImageUrl,
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
                                    backgroundColor: theme.cardColor.withOpacity(0.5),
                                    foregroundColor: theme.textTheme.bodyLarge?.color,
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.pop(context); 
                                    String detailId = placeId.isEmpty ? "unknown_venue_123" : placeId;
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => BusinessProfileScreen(venueId: detailId, venueName: placeData['name'] ?? "Mekan", imageUrl: placeImageUrl)));
                                  }, 
                                  child: Text(
                                    AppStrings.details, // 🔥 Core String
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
        ),
      ),
    );
  }

  static Widget _buildModernChip(IconData icon, String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2))
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