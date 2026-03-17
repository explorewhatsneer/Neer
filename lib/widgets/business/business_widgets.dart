import 'package:flutter/material.dart';

// CORE IMPORTLARI
import '../../core/theme_styles.dart';
import '../../core/text_styles.dart';
import '../../core/app_strings.dart';
import '../common/app_cached_image.dart'; 

// 1. BÖLÜM BAŞLIĞI
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  
  const SectionHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(8)
            ),
            child: Icon(icon, size: 18, color: theme.primaryColor),
          ),
          const SizedBox(width: 10),
          Text(
            title, 
            style: AppTextStyles.h3.copyWith(
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 18 
            )
          ),
        ],
      ),
    );
  }
}

// 2. MEKAN İSTATİSTİKLERİ (Puan, Yorum, Fiyat)
class PlaceStatsRow extends StatelessWidget {
  const PlaceStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 25, top: 5), 
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppThemeStyles.radius24,
        boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem("4.8", AppStrings.rating, Icons.star_rounded, Colors.orange, theme),
          _divider(theme),
          _buildItem("120", AppStrings.reviews, Icons.chat_bubble_rounded, Colors.blue, theme),
          _divider(theme),
          _buildItem("₺₺₺", AppStrings.price, Icons.attach_money_rounded, Colors.green, theme),
          _divider(theme),
          _buildItem(AppStrings.open, AppStrings.status, Icons.check_circle_rounded, theme.primaryColor, theme),
        ],
      ),
    );
  }

  Widget _divider(ThemeData theme) => Container(width: 1, height: 30, color: theme.dividerColor.withValues(alpha: 0.5));

  Widget _buildItem(String value, String label, IconData icon, Color color, ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value, 
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700, fontSize: 16)
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label, 
          style: AppTextStyles.caption.copyWith(
            color: theme.disabledColor, 
            fontWeight: FontWeight.w600
          )
        ),
      ],
    );
  }
}

// 3. ETKİNLİK BİLETİ
class EventTicketCard extends StatelessWidget {
  const EventTicketCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppThemeStyles.radius16,
        boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: Row(
        children: [
          // Sol Tarih Kısmı
          Container(
            width: 90,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              image: const DecorationImage(
                image: NetworkImage("https://picsum.photos/200"), 
                fit: BoxFit.cover, 
                opacity: 0.4
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("MAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text("14", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          
          // Sağ Bilgi Kısmı
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Akustik Caz Gecesi", 
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: theme.disabledColor),
                      const SizedBox(width: 5),
                      Text(
                        "20:00 - 23:30", 
                        style: AppTextStyles.caption.copyWith(color: theme.disabledColor)
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Bilet Butonu
          IconButton(
            onPressed: (){}, 
            icon: Icon(Icons.confirmation_number_outlined, color: theme.primaryColor)
          ),
        ],
      ),
    );
  }
}

// 4. ETKİLEŞİM GRİD (Ziyaret/Fotoğraf/Beğeni)
class InteractionStatsGrid extends StatelessWidget {
  const InteractionStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildInfoBox("5", AppStrings.visits, Icons.location_on_rounded, Colors.blue, context)),
        const SizedBox(width: 10),
        Expanded(child: _buildInfoBox("3", AppStrings.photos, Icons.camera_alt_rounded, Colors.purple, context)),
        const SizedBox(width: 10),
        Expanded(child: _buildInfoBox("12", AppStrings.likes, Icons.thumb_up_rounded, Colors.orange, context)),
      ],
    );
  }

  Widget _buildInfoBox(String val, String label, IconData icon, Color color, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppThemeStyles.radius16,
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(val, style: AppTextStyles.h3.copyWith(fontSize: 18)),
          Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11, color: theme.disabledColor)),
        ],
      ),
    );
  }
}

// 5. LİDERLİK TABLOSU
class VenueLeaderboard extends StatelessWidget {
  const VenueLeaderboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppThemeStyles.radius16,
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: Column(
        children: [
          _buildUserRow(1, "zeynepkamil", "42 Ziyaret", "https://i.pravatar.cc/150?u=1", theme),
          Divider(color: theme.dividerColor.withValues(alpha: 0.5)),
          _buildUserRow(2, "canbertkorkmaz", "38 Ziyaret", "https://i.pravatar.cc/150?u=2", theme),
          Divider(color: theme.dividerColor.withValues(alpha: 0.5)),
          _buildUserRow(3, "ingebogan", "21 Ziyaret", "https://i.pravatar.cc/150?u=3", theme),
        ],
      ),
    );
  }

  Widget _buildUserRow(int rank, String name, String detail, String img, ThemeData theme) {
    return Row(
      children: [
        Text(
          "#$rank", 
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w900, 
            color: rank == 1 ? Colors.orange : theme.disabledColor, 
          )
        ),
        const SizedBox(width: 15),
        CachedAvatar(imageUrl: img, name: name, radius: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text("@$name", 
            // 🔥 DÜZELTME: bodyMedium -> bodySmall
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)
          )
        ),
        Text(
          detail, 
          style: AppTextStyles.caption.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)
        ),
      ],
    );
  }
}

// 6. ARKADAŞ NOTU (Bubble)
class FriendNoteBubble extends StatelessWidget {
  const FriendNoteBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(0), 
              topRight: Radius.circular(20), 
              bottomLeft: Radius.circular(20), 
              bottomRight: Radius.circular(20)
            ),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "\"Kahveleri harika ama haftasonu yer bulmak çok zor, erken gitmeni öneririm!\"", 
                // 🔥 DÜZELTME: bodyMedium -> bodySmall
                style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic)
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end, 
                children: [
                  Text("- Ece Doğan", style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: theme.disabledColor))
                ]
              )
            ],
          ),
        ),
        Positioned(
          top: -10, left: -5,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.scaffoldBackgroundColor, width: 2)
            ),
            child: const CachedAvatar(
              imageUrl: "https://i.pravatar.cc/150?u=ece",
              name: "Ece",
              radius: 20,
            ),
          ),
        )
      ],
    );
  }
}

// 7. DETAYLI PUAN ÇUBUKLARI
class DetailedRatingBars extends StatelessWidget {
  const DetailedRatingBars({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppThemeStyles.radius16,
        border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
      ),
      child: Column(
        children: [
          _buildBarItem(AppStrings.serviceSpeed, 0.85, theme),
          const SizedBox(height: 15),
          _buildBarItem(AppStrings.cleanliness, 0.95, theme),
          const SizedBox(height: 15),
          _buildBarItem(AppStrings.taste, 0.90, theme),
          const SizedBox(height: 15),
          _buildBarItem(AppStrings.pricePerf, 0.70, theme),
        ],
      ),
    );
  }

  Widget _buildBarItem(String label, double percent, ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
            Text(
              "${(percent * 5).toStringAsFixed(1)}", 
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: percent, 
            backgroundColor: theme.dividerColor.withValues(alpha: 0.2), 
            color: theme.primaryColor, 
            minHeight: 6
          ),
        ),
      ],
    );
  }
}

// 8. KONUM VE QR SATIRI
class LocationQrRow extends StatelessWidget {
  const LocationQrRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Harita Önizleme
        Expanded(
          flex: 2,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.1),
              borderRadius: AppThemeStyles.radius16,
              image: const DecorationImage(
                image: NetworkImage("https://maps.googleapis.com/maps/api/staticmap?center=41.0082,28.9784&zoom=14&size=400x200&sensor=false"), 
                fit: BoxFit.cover,
                opacity: 0.8
              ),
            ),
            child: Center(child: Icon(Icons.location_on_rounded, color: theme.primaryColor, size: 32)),
          ),
        ),
        const SizedBox(width: 15),
        
        // Menü QR
        Expanded(
          flex: 1,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: AppThemeStyles.radius16,
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2_rounded, size: 40, color: theme.textTheme.bodyLarge?.color),
                const SizedBox(height: 5),
                Text(AppStrings.menu, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}