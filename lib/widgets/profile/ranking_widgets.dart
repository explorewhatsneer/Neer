import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/text_styles.dart';

// ==========================================
// 🏆 RANKING PODIUM (Avatar Only 3D Style)
// ==========================================
class RankingPodium extends StatelessWidget {
  final List<Map<String, dynamic>> top3Places; 
  final Function(String id, String name, String img) onTap;

  const RankingPodium({super.key, required this.top3Places, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (top3Places.isEmpty) return const SizedBox();

    final first = top3Places.isNotEmpty ? top3Places[0] : null;
    final second = top3Places.length > 1 ? top3Places[1] : null;
    final third = top3Places.length > 2 ? top3Places[2] : null;

    return Container(
      height: 180, // Sadece avatarlar olduğu için yükseklik azaldı
      padding: const EdgeInsets.symmetric(vertical: 10),
      // Stack kullanarak Z-Index (Ön/Arka) ilişkisini kuruyoruz
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 🥈 2. SIRA (Sol - Arkada)
          if (second != null)
            Positioned(
              left: 20,
              bottom: 20, // Ortadakinden biraz yukarıda dursun (perspektif)
              child: _RankAvatar(
                place: second,
                rank: 2,
                size: 90,
                color: const Color(0xFFC0C0C0), // Gümüş
                onTap: onTap,
              ),
            ),

          // 🥉 3. SIRA (Sağ - Arkada)
          if (third != null)
            Positioned(
              right: 20,
              bottom: 20,
              child: _RankAvatar(
                place: third,
                rank: 3,
                size: 90,
                color: const Color(0xFFCD7F32), // Bronz
                onTap: onTap,
              ),
            ),

          // 🥇 1. SIRA (Orta - En Önde)
          if (first != null)
            Positioned(
              bottom: 0, // En aşağıda (ön planda)
              child: _RankAvatar(
                place: first,
                rank: 1,
                size: 120, // En büyük
                color: const Color(0xFFFFD700), // Altın
                onTap: onTap,
                isCenter: true,
              ),
            ),
        ],
      ),
    );
  }
}

class _RankAvatar extends StatelessWidget {
  final Map<String, dynamic> place;
  final int rank;
  final double size;
  final Color color;
  final bool isCenter;
  final Function(String id, String name, String img) onTap;

  const _RankAvatar({
    required this.place,
    required this.rank,
    required this.size,
    required this.color,
    required this.onTap,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    String name = place['place_name'] ?? 'Mekan';
    String img = place['image_url'] ?? "https://picsum.photos/200";
    
    return GestureDetector(
      onTap: () => onTap(_findPlaceId(place), name, img),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Taç İkonu (Sadece 1. sıra)
          if (isCenter)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(Icons.emoji_events_rounded, color: color, size: 32),
            ),

          // Avatar Çerçevesi
          Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 4), // Kalın, belirgin çerçeve
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: ClipOval(
                  child: Image.network(img, fit: BoxFit.cover),
                ),
              ),
              
              // Sıralama Rozeti (#1, #2)
              Positioned(
                bottom: -12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(
                    "#$rank",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16), // Rozet payı
          
          // Mekan İsmi
          SizedBox(
            width: size + 20, // Taşan isimler için genişlik
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isCenter ? 14 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _findPlaceId(Map<String, dynamic> data) {
    if (data['placeId'] != null) return data['placeId'].toString();
    if (data['venueId'] != null) return data['venueId'].toString();
    if (data['id'] != null) return data['id'].toString();
    return "";
  }
}

// ==========================================
// 📄 SIMPLE RANK ROW (Liste Elemanı - Minimalist)
// ==========================================
class SimpleRankRow extends StatelessWidget {
  final int rank;
  final String name;
  final int count;
  final String imgUrl;
  final VoidCallback? onTap;

  const SimpleRankRow({super.key, required this.rank, required this.name, required this.count, required this.imgUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 2))]
      ),
      child: ListTile(
        onTap: onTap,
        dense: true, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        
        // Sıra No
        leading: SizedBox(
          width: 30,
          child: Text("#$rank", style: AppTextStyles.h3.copyWith(fontSize: 16, color: Theme.of(context).disabledColor.withValues(alpha: 0.5))),
        ),
        
        // İsim ve Ziyaret
        title: Text(name, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text("$count ziyaret", style: AppTextStyles.caption),
        
        // Resim
        trailing: ClipRRect(
          borderRadius: BorderRadius.circular(10), 
          child: Image.network(imgUrl, width: 44, height: 44, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width:44, height:44, color:Colors.grey.shade200))
        ),
      ),
    );
  }
}

// ==========================================
// 🏷 SECTION HEADER (Değişmedi)
// ==========================================
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onActionTap;
  const SectionHeader({super.key, required this.title, required this.icon, this.onActionTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 15, 4, 10), 
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
      children: [
        Row(children: [
          Icon(icon, size: 18, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.h3.copyWith(fontSize: 17, letterSpacing: -0.5))
        ]), 
        if (onActionTap != null) 
          GestureDetector(
            onTap: (){HapticFeedback.lightImpact(); onActionTap!();}, 
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text("Tümü", style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600, fontSize: 13)),
            )
          )
      ]
    )
  );
}