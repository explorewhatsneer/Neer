import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback

// CORE IMPORTLARI
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';

import '../services/supabase_service.dart';
import '../widgets/common/app_cached_image.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/animated_list_item.dart';
import '../core/snackbar_helper.dart';
import '../widgets/common/app_confirm_dialog.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final _service = SupabaseService();
  Key _refreshKey = UniqueKey();

  Future<void> _refreshList() async {
    HapticFeedback.lightImpact();
    setState(() => _refreshKey = UniqueKey());
  }

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
      final updateResult = await _service.updateProfile(myUid, {'blocked_users': blockedList});

      if (updateResult.isFailure) {
        if (mounted) AppSnackBar.error(context, AppStrings.cameraError);
        return;
      }

      if (mounted) {
        AppSnackBar.success(context, "$targetName ${AppStrings.unblockedSuccess}");
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, AppStrings.cameraError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String? myUid = _service.client.auth.currentUser?.id;

    if (myUid == null) return const SizedBox();

    return GradientScaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.blockedUsersTitle,
          style: NeerTypography.h3.copyWith(fontSize: 20)
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // 1. Kendi profilimizi dinle (blocked_users listesi için)
      body: RefreshIndicator(
        onRefresh: _refreshList,
        color: theme.primaryColor,
        child: StreamBuilder<List<Map<String, dynamic>>>(
          key: _refreshKey,
          stream: _service.streamProfileAsList(myUid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const ShimmerList(itemCount: 5);
            }

            if (snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [SizedBox(height: MediaQuery.of(context).size.height * 0.25), _buildEmptyState(theme)],
              );
            }

            var myData = snapshot.data!.first;
            List<dynamic> blockedListRaw = myData['blocked_users'] ?? [];
            List<String> blockedList = blockedListRaw.map((e) => e.toString()).toList();

            if (blockedList.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [SizedBox(height: MediaQuery.of(context).size.height * 0.25), _buildEmptyState(theme)],
              );
            }

            // 2. Engellenen kullanıcıların detaylarını çek (FutureBuilder)
            return FutureBuilder<List<Map<String, dynamic>>>(
              future: _service.getUsersByIds(blockedList),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) return const ShimmerList(itemCount: 5);

                var users = userSnapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var userData = users[index];
                    String blockedUserId = userData['id'];
                    return AnimatedListItem(
                      index: index,
                      child: _buildBlockedUserCard(userData, blockedUserId, theme),
                    );
                  },
                );
              },
            );
          },
        ),
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
          borderRadius: NeerRadius.buttonRadius
        ),
        child: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) => AppConfirmDialog.show(
        context: context,
        title: AppStrings.unblockUser,
        content: "$name ${AppStrings.unblockConfirm}",
        confirmText: AppStrings.unblockUser,
      ),
      onDismissed: (direction) => _unblockUser(uid, name),
      
      // KART İÇERİĞİ
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: NeerRadius.buttonRadius,
          boxShadow: isDark ? [] : NeerShadows.soft(), 
          border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
        ),
        child: Row(
          children: [
            // Avatar
            CachedAvatar(imageUrl: image, name: name, radius: 28),
            const SizedBox(width: 16),
            
            // Bilgiler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name, 
                    style: NeerTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "@$username", 
                    style: NeerTypography.bodySmall.copyWith(color: theme.disabledColor)
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
    return EmptyState(
      icon: Icons.shield_moon_rounded,
      title: AppStrings.noBlockedUsers,
      description: AppStrings.listClean,
    );
  }
}