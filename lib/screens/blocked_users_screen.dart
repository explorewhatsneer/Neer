import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:supabase_flutter/supabase_flutter.dart';

// CORE IMPORTLARI
import '../core/theme_styles.dart';
import '../core/text_styles.dart';
import '../core/app_strings.dart';

import '../services/supabase_service.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final _service = SupabaseService();

  // Engeli Kaldırma Fonksiyonu
  Future<void> _unblockUser(String targetUid, String targetName) async {
    HapticFeedback.mediumImpact(); // Titreşim efekti

    String? myUid = _service.client.auth.currentUser?.id;
    if (myUid == null) return;

    try {
      // 1. Mevcut engelli listesini çek
      final data = await _service.getProfileFields(myUid, 'blocked_users');

      List<dynamic> blockedList = List.from(data?['blocked_users'] ?? []);

      // 2. Listeden çıkar
      blockedList.remove(targetUid);

      // 3. Güncel listeyi kaydet
      await _service.updateProfile(myUid, {'blocked_users': blockedList});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$targetName ${AppStrings.unblockedSuccess}", 
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
            ),
            backgroundColor: const Color(0xFF34C759), // Başarı Yeşili
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.cameraError), 
            backgroundColor: Theme.of(context).colorScheme.error,
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? myUid = _service.client.auth.currentUser?.id;

    if (myUid == null) return const SizedBox();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppStrings.blockedUsersTitle,
          style: AppTextStyles.h3.copyWith(fontSize: 20)
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // 1. Kendi profilimizi dinle (blocked_users listesi için)
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _service.streamProfileAsList(myUid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: theme.primaryColor));
          }
          
          if (snapshot.data!.isEmpty) return _buildEmptyState(theme);

          var myData = snapshot.data!.first;
          List<dynamic> blockedListRaw = myData['blocked_users'] ?? [];
          List<String> blockedList = blockedListRaw.map((e) => e.toString()).toList();

          if (blockedList.isEmpty) {
            return _buildEmptyState(theme);
          }

          // 2. Engellenen kullanıcıların detaylarını çek (FutureBuilder)
          // Not: Liste çok uzunsa pagination gerekebilir, şimdilik basit select
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _service.getUsersByIds(blockedList), // ID'si bu listede olanları getir
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) return Center(child: CircularProgressIndicator(color: theme.primaryColor));
              
              var users = userSnapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var userData = users[index];
                  String blockedUserId = userData['id'];
                  return _buildBlockedUserCard(userData, blockedUserId, theme);
                },
              );
            },
          );
        },
      ),
    );
  }

  // --- PREMIUM KULLANICI KARTI ---
  Widget _buildBlockedUserCard(Map<String, dynamic> user, String uid, ThemeData theme) {
    // Supabase sütun isimleri: full_name, username, avatar_url
    String name = user['full_name'] ?? AppStrings.nameless;
    String username = user['username'] ?? "kullanici";
    String image = user['avatar_url'] ?? "";
    bool isDark = theme.brightness == Brightness.dark;

    return Dismissible(
      key: Key(uid),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: const Color(0xFF34C759), // iOS Green
          borderRadius: AppThemeStyles.radius16
        ),
        child: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.lightImpact();
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius24),
            title: Text(
              AppStrings.unblockUser, 
              style: AppTextStyles.h3
            ),
            content: Text(
              "$name ${AppStrings.unblockConfirm}", 
              style: AppTextStyles.bodySmall,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false), 
                child: Text(
                  AppStrings.cancel, 
                  style: AppTextStyles.button.copyWith(color: theme.disabledColor)
                )
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true), 
                child: Text(
                  AppStrings.unblockUser, 
                  style: AppTextStyles.button.copyWith(color: const Color(0xFF34C759), fontWeight: FontWeight.bold)
                )
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => _unblockUser(uid, name),
      
      // KART İÇERİĞİ
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: AppThemeStyles.radius16,
          boxShadow: isDark ? [] : AppThemeStyles.shadowLow, 
          border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.scaffoldBackgroundColor,
              backgroundImage: (image.isNotEmpty) ? NetworkImage(image) : null,
              child: (image.isEmpty)
                ? Icon(Icons.person, color: theme.disabledColor, size: 28)
                : null,
            ),
            const SizedBox(width: 16),
            
            // Bilgiler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name, 
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "@$username", 
                    style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)
                  ),
                ],
              ),
            ),

            // Kilit Butonu
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _unblockUser(uid, name),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lock_open_rounded, color: Colors.redAccent, size: 20),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- BOŞ DURUM ---
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_moon_rounded, size: 80, color: theme.disabledColor.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          Text(
            AppStrings.noBlockedUsers, 
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold, color: theme.disabledColor)
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.listClean, 
            style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)
          ),
        ],
      ),
    );
  }
}