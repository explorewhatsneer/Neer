import 'dart:ui'; // ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback

// CORE IMPORTLARI
import '../../core/text_styles.dart';
import '../../core/app_strings.dart';

import '../../services/supabase_service.dart';

class GlassSuggestions extends StatelessWidget {
  final String query;
  final Function(Map<String, dynamic> data, String id, String type) onItemSelected;

  const GlassSuggestions({
    super.key,
    required this.query,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return const SizedBox();
    final service = SupabaseService();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Premium Blur
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          margin: const EdgeInsets.only(top: 8),
          
          decoration: BoxDecoration(
            // Dinamik Cam Rengi (Koyu/Açık)
            color: isDark 
                ? Colors.black.withValues(alpha: 0.6) 
                : Colors.white.withValues(alpha: 0.85),
            
            borderRadius: BorderRadius.circular(24),
            
            // Premium Çerçeve
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.5), 
              width: 1.0
            ),
            
            // Premium Gölge
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15), 
                blurRadius: 20, 
                offset: const Offset(0, 8), 
                spreadRadius: 2
              )
            ],
          ),
          
          child: CustomScrollView(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // --- MEKANLAR ---
              SliverToBoxAdapter(child: _buildSectionHeader(AppStrings.placesHeading, theme)),
              
              // 🔥 SUPABASE MEKAN SORGUSU
              FutureBuilder<List<Map<String, dynamic>>>(
                future: service.searchPlacesPrefix(query, limit: 5),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                     return const SliverToBoxAdapter(child: SizedBox());
                  }
                  
                  final places = snapshot.data!;
                  
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                         var data = places[index];
                         return _buildListItem(
                           data, 
                           data['id'].toString(), // ID
                           'place', 
                           Icons.storefront_rounded, 
                           Colors.orangeAccent, 
                           theme
                         );
                      },
                      childCount: places.length,
                    ),
                  );
                }
              ),

              // --- AYIRICI ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
              ),

              // --- KİŞİLER ---
              SliverToBoxAdapter(child: _buildSectionHeader(AppStrings.peopleHeading, theme)),

              // 🔥 SUPABASE PROFİL SORGUSU
              FutureBuilder<List<Map<String, dynamic>>>(
                future: service.searchUsersPrefix(query, limit: 5),
                builder: (context, snapshot) {
                   if (!snapshot.hasData || snapshot.data!.isEmpty) {
                     return const SliverToBoxAdapter(child: SizedBox());
                   }
                   
                   final users = snapshot.data!;
                   
                   return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                         var data = users[index];
                         return _buildListItem(
                           data, 
                           data['id'].toString(), // ID
                           'user', 
                           Icons.person_rounded, 
                           theme.primaryColor, 
                           theme
                         );
                      },
                      childCount: users.length,
                    ),
                  );
                }
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title, 
        // 🔥 Core Style: Caption
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w900, 
          color: theme.disabledColor,
          letterSpacing: 1.2
        )
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> data, String id, String type, IconData icon, Color color, ThemeData theme) {
    // 🔥 Veri eşleştirme (Firebase -> Supabase sütun isimleri)
    final String name = type == 'user' 
        ? (data['full_name'] ?? AppStrings.nameless) 
        : (data['name'] ?? AppStrings.generalPlace);
        
    final String? imageUrl = type == 'user' 
        ? data['avatar_url'] // Supabase'deki sütun adı
        : null; // Mekan resmi varsa buraya eklenebilir

    final String subText = type == 'place' 
          ? (data['category'] ?? AppStrings.generalPlace) 
          : (data['username'] != null ? "@${data['username']}" : AppStrings.user);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // Seçilen veriyi geri döndür
          onItemSelected(data, id, type);
        },
        overlayColor: MaterialStateProperty.all(theme.primaryColor.withValues(alpha: 0.1)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // İkon Kutusu
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: type == 'user' ? null : BorderRadius.circular(10), // User ise daire
                  shape: type == 'user' ? BoxShape.circle : BoxShape.rectangle,
                ),
                child: type == 'user' && imageUrl != null && imageUrl.isNotEmpty
                    ? ClipOval(child: Image.network(imageUrl, fit: BoxFit.cover))
                    : Icon(icon, size: 22, color: color),
              ),
              
              const SizedBox(width: 14),
              
              // Metinler
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      // 🔥 Core Style: BodyLarge (Bold)
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700, 
                      ), 
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subText,
                      // 🔥 Core Style: Caption/BodySmall
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.disabledColor
                      )
                    ),
                  ],
                ),
              ),
              
              // Yönlendirme Oku
              Icon(Icons.north_west_rounded, size: 18, color: theme.disabledColor.withValues(alpha: 0.5)),
            ],
          ),
        ),
      ),
    );
  }
}