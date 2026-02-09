import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:supabase_flutter/supabase_flutter.dart';
// import '../main.dart'; // Gerek kalmadı

// CORE IMPORTLARI
import '../../core/theme_styles.dart'; 
import '../../core/text_styles.dart'; 
import '../../core/constants.dart';
import '../../core/app_strings.dart'; 

import '../../screens/friend_profile_screen.dart';

// --- DIŞARIDAN ÇAĞRILAN FONKSİYON ---
void showGroupMembers(BuildContext context, String chatId) {
  if (chatId.trim().isEmpty) {
    debugPrint("⚠️ HATA: showGroupMembers boş chatId ile çağrıldı.");
    return;
  }

  HapticFeedback.lightImpact();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent, 
    isScrollControlled: true, 
    builder: (context) => ActiveUsersSheet(chatId: chatId),
  );
}

class ActiveUsersSheet extends StatefulWidget {
  final String chatId;

  const ActiveUsersSheet({super.key, required this.chatId});

  @override
  State<ActiveUsersSheet> createState() => _ActiveUsersSheetState();
}

class _ActiveUsersSheetState extends State<ActiveUsersSheet> {
  // 🔥 Supabase İstemcisi
  final _supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final String currentUid = _supabase.auth.currentUser?.id ?? "";

    // 🛡️ GÜVENLİK KONTROLÜ
    if (widget.chatId.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.cardColor, 
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24))
        ),
        child: Center(
          child: Text(
            "${AppStrings.error}: Grup ID bulunamadı.", 
            style: AppTextStyles.bodyLarge.copyWith(color: theme.colorScheme.error)
          )
        ),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, controller) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              // Dinamik Glass Rengi
              color: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
              boxShadow: AppThemeStyles.shadowHigh, 
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1)),
            ),
            child: Column(
              children: [
                // --- HEADER (GRAB BAR) ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        AppStrings.activeMembers, 
                        style: AppTextStyles.h3.copyWith(
                          color: isDark ? AppColors.darkTextHeading : AppColors.lightTextHeading
                        ),
                      ),
                    ],
                  ),
                ),

                // --- LİSTE ---
                Expanded(
                  // 🔥 SUPABASE STREAM (Mekan üyelerini veya check-in yapanları getirir)
                  // Not: Gerçek senaryoda burası 'checkins' tablosundan veri çekmelidir.
                  // Şimdilik 'profiles' tablosundan tüm kullanıcıları getiriyoruz (Demo amaçlı).
                  // İleride: .from('checkins').stream(primaryKey: ['id']).eq('place_id', widget.chatId)
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _supabase
                        .from('profiles')
                        .stream(primaryKey: ['id'])
                        .limit(20), // Demo: Rastgele 20 kişiyi gösteriyor gibi düşünelim
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: theme.primaryColor));
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyState(theme, isDark);
                      }

                      final users = snapshot.data!;

                      return ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: users.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          final String userId = user['id'];
                          final bool isMe = userId == currentUid;
                          // Supabase'de online durumu için Presence kullanılır ama şimdilik statik false
                          final bool isOnline = false; 

                          return _buildUserTile(
                            context: context,
                            theme: theme,
                            user: user,
                            userId: userId,
                            isMe: isMe,
                            isOnline: isOnline,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- KULLANICI KARTI (TILE) ---
  Widget _buildUserTile({
    required BuildContext context,
    required ThemeData theme,
    required Map<String, dynamic> user,
    required String userId,
    required bool isMe,
    required bool isOnline,
  }) {
    final bool isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (!isMe) {
          HapticFeedback.lightImpact();
          Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(targetUserId: userId)));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(0.5), 
          borderRadius: AppThemeStyles.radius16,
          border: isDark ? Border.all(color: Colors.white.withOpacity(0.05), width: 0.5) : null,
          boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
        ),
        child: Row(
          children: [
            // 1. AVATAR & ONLINE NOKTASI
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                  ),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    backgroundImage: NetworkImage(user['avatar_url'] ?? "https://i.pravatar.cc/150?u=$userId"),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759), 
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.cardColor, width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(width: 16),

            // 2. İSİM & KULLANICI ADI
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // 🔥 Supabase sütun isimleri: full_name
                    isMe ? "${user['full_name']} ${AppStrings.you}" : (user['full_name'] ?? "Kullanıcı"),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600, 
                      color: isDark ? AppColors.darkTextHeading : AppColors.lightTextHeading
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "@${user['username'] ?? 'gizliuye'}",
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
                    ),
                  ),
                ],
              ),
            ),

            // 3. AKSİYON İKONU
            if (!isMe)
              Icon(
                Icons.chevron_right_rounded, 
                color: theme.disabledColor.withOpacity(0.5),
                size: 24,
              )
          ],
        ),
      ),
    );
  }

  // --- BOŞ DURUM ---
  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_rounded, size: 60, color: theme.disabledColor.withOpacity(0.3)),
          const SizedBox(height: 10),
          Text(
            AppStrings.noMembers, 
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
              fontWeight: FontWeight.bold
            )
          ),
        ],
      ),
    );
  }
}