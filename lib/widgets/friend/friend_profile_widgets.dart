import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

// CORE IMPORTLARI
import '../../core/theme_styles.dart'; 
import '../../core/text_styles.dart';
import '../../core/app_strings.dart'; 

// --- YARDIMCI: PREMIUM STİL (KART YAPISI) ---
class _FriendPremiumContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap; 
  
  const _FriendPremiumContainer({required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap!();
        }
      },
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: AppThemeStyles.radius24,
          border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
          boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
        ),
        child: child,
      ),
    );
  }
}

// 1. TEKİL GEÇMİŞ KARTI
class HistoryItemCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const HistoryItemCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    String type = data['type'] ?? 'place';
    String title = data['title'] ?? '';
    String desc = data['description'] ?? '';
    String date = data['date'] ?? '';

    // Tipe göre İkon ve Renk
    IconData icon;
    Color color;

    switch (type) {
      case 'meetup':
        icon = Icons.directions_walk_rounded;
        color = Colors.blueAccent;
        break;
      case 'event':
        icon = Icons.event_available_rounded;
        color = Colors.purpleAccent;
        break;
      case 'place':
      default:
        icon = Icons.place_rounded;
        color = Colors.orangeAccent;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _FriendPremiumContainer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title, 
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800)
                      ),
                      Text(
                        date, 
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600, 
                          color: theme.disabledColor
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis, 
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8)
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 2. "BİZİM GEÇMİŞİMİZ" LİSTESİ
class MutualHistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const MutualHistoryList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      // 🔥 DÜZELTME: 'const' kaldırıldı
      return FriendEmptyCard(
        icon: Icons.history_toggle_off_rounded,
        title: "Henüz Yollarınız Kesişmedi",
        subtitle: "Birlikte aynı mekanda bulunduğunuzda veya etkinliğe katıldığınızda burada görünecek.",
      ); 
    }
    return Column(children: items.map((data) => HistoryItemCard(data: data)).toList());
  }
}

// 3. SIK UĞRANANLAR SATIRI
class FrequentPlaceRow extends StatelessWidget {
  final int rank;
  final String name;
  final int count;
  final String imgUrl;
  final VoidCallback onTap;

  const FrequentPlaceRow({
    super.key,
    required this.rank,
    required this.name,
    required this.count,
    required this.imgUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _FriendPremiumContainer(
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 24,
              alignment: Alignment.center,
              child: Text(
                "#$rank",
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.primaryColor.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imgUrl, width: 48, height: 48, fit: BoxFit.cover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(
                    "$count ${AppStrings.visits}", 
                    style: AppTextStyles.caption.copyWith(color: theme.disabledColor)
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.disabledColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

// 4. NOT BALONU
class NoteBubble extends StatelessWidget {
  final String placeName;
  final String note;
  final String date;
  final String profileImg;
  final VoidCallback onPlaceTap;

  const NoteBubble({
    super.key,
    required this.placeName,
    required this.note,
    required this.date,
    required this.profileImg,
    required this.onPlaceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _FriendPremiumContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(profileImg),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(placeName, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800)),
                      Text(date, style: AppTextStyles.caption.copyWith(color: theme.disabledColor, fontSize: 10)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onPlaceTap,
                  icon: Icon(Icons.location_on_rounded, size: 18, color: theme.primaryColor),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                note,
                style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. DEĞERLENDİRME GEÇMİŞİ KARTI
class SurveyHistoryCard extends StatelessWidget {
  final String placeName;
  final double overallScore;
  final String date;
  final Map<String, dynamic> details;
  final VoidCallback onPlaceTap;

  const SurveyHistoryCard({
    super.key,
    required this.placeName,
    required this.overallScore,
    required this.date,
    required this.details,
    required this.onPlaceTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _FriendPremiumContainer(
        onTap: onPlaceTap,
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: _getScoreColor(overallScore).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  overallScore.toStringAsFixed(1),
                  style: AppTextStyles.h3.copyWith(color: _getScoreColor(overallScore), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(placeName, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w800)),
                  Text(date, style: AppTextStyles.caption.copyWith(color: theme.disabledColor)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: theme.disabledColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 4.5) return Colors.green;
    if (score >= 3.0) return Colors.orange;
    return Colors.red;
  }
}

// 6. ŞIK BOŞ DURUM KARTI
class FriendEmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FriendEmptyCard({
    super.key, 
    required this.icon, 
    required this.title, 
    required this.subtitle
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: _FriendPremiumContainer(
        child: SizedBox(
          width: double.infinity, 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: theme.disabledColor),
              ),
              const SizedBox(height: 16),
              Text(
                title, 
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8)
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  subtitle, 
                  style: AppTextStyles.caption.copyWith(
                    color: theme.disabledColor,
                    height: 1.4
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}