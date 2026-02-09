import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:supabase_flutter/supabase_flutter.dart';
// import '../main.dart'; // Gerek kalmadı

// CORE IMPORTLARI
import '../core/theme_styles.dart'; 
import '../core/text_styles.dart';
import '../core/app_strings.dart'; 

import 'chat_screen.dart';
import 'friend_profile_screen.dart';  

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  // 🔥 SUPABASE CLIENT
  final _supabase = Supabase.instance.client;
  
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Supabase User ID
    String myUid = _supabase.auth.currentUser?.id ?? "";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      
      // --- FLOATING ACTION BUTTON ---
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90), 
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppStrings.findFriendsOnMapDesc, 
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
                ), 
                backgroundColor: theme.primaryColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
              )
            );
          },
          backgroundColor: theme.primaryColor,
          elevation: 4,
          icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
          label: Text(
            AppStrings.findOnMap, 
            style: AppTextStyles.button.copyWith(fontSize: 14)
          ),
        ),
      ),

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor, 
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            AppStrings.friendsTitle, 
            style: AppTextStyles.h1.copyWith(fontSize: 32) 
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        
        // --- ARAMA ÇUBUĞU ---
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            height: 50,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: AppThemeStyles.radius16,
              boxShadow: isDark ? [] : AppThemeStyles.shadowLow,
              border: isDark ? Border.all(color: Colors.white12, width: 1) : null,
            ),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (val) => setState(() => _searchText = val.toLowerCase()),
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
              cursorColor: theme.primaryColor,
              decoration: InputDecoration(
                hintText: AppStrings.searchFriendsHint, 
                hintStyle: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor, fontWeight: FontWeight.w500),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search_rounded, color: theme.primaryColor),
                suffixIcon: _searchText.isNotEmpty 
                  ? IconButton(
                      icon: Icon(Icons.cancel_rounded, color: theme.disabledColor), 
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchText = "");
                        HapticFeedback.lightImpact();
                      })
                  : null,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),

      // 1. KENDİ PROFİLİNDEN ARKADAŞ LİSTESİNİ ÇEK (Stream)
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('profiles')
            .stream(primaryKey: ['id'])
            .eq('id', myUid)
            .limit(1),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: theme.primaryColor));
          if (snapshot.data!.isEmpty) return _bosArkadasEkrani(theme);

          var userData = snapshot.data!.first;
          List<dynamic> friendsList = userData['friends'] ?? [];

          if (friendsList.isEmpty) {
            return _bosArkadasEkrani(theme);
          }

          // Arkadaş ID'lerini String listesine çevir
          List<String> friendIds = friendsList.map((e) => e.toString()).toList();

          // 2. ARKADAŞLARIN DETAYLARINI ÇEK (FutureBuilder'a çevrildi)
          // ⚠️ DÜZELTME: .inFilter Stream'de çalışmaz, .select() kullanıyoruz.
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _supabase
                .from('profiles')
                .select()
                .inFilter('id', friendIds), // 🔥 DÜZELTİLDİ: .in_ yerine .inFilter
            builder: (context, friendsSnapshot) {
              if (friendsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: theme.primaryColor));
              }

              if (!friendsSnapshot.hasData || friendsSnapshot.data!.isEmpty) {
                 // Veri yoksa veya hata varsa
                 return Center(
                  child: Text(
                    AppStrings.noPersonFound, 
                    style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)
                  )
                );
              }

              var friends = friendsSnapshot.data!;

              // Arama Filtresi
              if (_searchText.isNotEmpty) {
                friends = friends.where((user) {
                  String name = (user['full_name'] ?? "").toString().toLowerCase();
                  return name.contains(_searchText);
                }).toList();
              }

              if (friends.isEmpty) {
                return Center(
                  child: Text(
                    AppStrings.noPersonFound, 
                    style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor, fontWeight: FontWeight.bold)
                  )
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), 
                physics: const BouncingScrollPhysics(),
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  var user = friends[index];
                  String uid = user['id'];
                  return _buildFriendCard(user, uid, theme);
                },
              );
            },
          );
        },
      ),
    );
  }

  // --- PREMIUM ARKADAŞ KARTI ---
  Widget _buildFriendCard(Map<String, dynamic> user, String uid, ThemeData theme) {
    // 🔥 DÜZELTME: isOnline artık veriden geliyor (Sarı hata giderildi)
    bool isOnline = user['is_online'] ?? false; 
    
    String name = user['full_name'] ?? AppStrings.nameless;
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
          color: const Color(0xFFFF3B30), // iOS Red
          borderRadius: AppThemeStyles.radius16
        ),
        child: const Icon(Icons.person_remove_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: theme.cardColor,
            shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius24),
            title: Text(AppStrings.deleteFriend, style: AppTextStyles.h3),
            content: Text("$name ${AppStrings.deleteFriendConfirm}", style: AppTextStyles.bodySmall),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false), 
                child: Text(AppStrings.cancel, style: AppTextStyles.button.copyWith(color: theme.disabledColor))
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true), 
                child: Text(AppStrings.delete, style: AppTextStyles.button.copyWith(color: Colors.redAccent))
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        String myUid = _supabase.auth.currentUser!.id;
        try {
          final data = await _supabase.from('profiles').select('friends').eq('id', myUid).single();
          List currentFriends = List.from(data['friends'] ?? []);
          currentFriends.remove(uid);
          await _supabase.from('profiles').update({'friends': currentFriends}).eq('id', myUid);

          if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("$name ${AppStrings.friendDeleted}"), 
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: AppThemeStyles.radius16),
              )
            );
          }
        } catch (e) {
          // Hata yönetimi
        }
      },
      
      // KART GÖVDESİ
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfileScreen(targetUserId: uid)));
        },
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
              // Avatar ve Online Durumu
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.dividerColor, width: 1),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.scaffoldBackgroundColor,
                      backgroundImage: (image.isNotEmpty) ? NetworkImage(image) : null,
                      child: (image.isEmpty)
                        ? Text(name.isNotEmpty ? name[0].toUpperCase() : "?", style: TextStyle(fontWeight: FontWeight.w800, color: theme.disabledColor, fontSize: 22))
                        : null,
                    ),
                  ),
                  
                  // 🔥 ARTIK SARI YANMAYACAK
                  if (isOnline)
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF34C759), // Online Yeşil
                          shape: BoxShape.circle, 
                          border: Border.all(color: theme.cardColor, width: 2.5)
                        ),
                      ),
                    )
                ],
              ),
              const SizedBox(width: 16),
              
              // İsim ve Durum
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name, 
                      style: AppTextStyles.bodyLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w600)
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isOnline ? AppStrings.online : AppStrings.offline, 
                      style: AppTextStyles.caption.copyWith(
                        color: isOnline ? const Color(0xFF34C759) : theme.disabledColor, 
                        fontWeight: FontWeight.w600
                      )
                    ),
                  ],
                ),
              ),

              // Chat İkonu
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(userName: name, userId: uid, userImage: image)));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.chat_bubble_outline_rounded, color: theme.primaryColor, size: 22),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- BOŞ DURUM ---
  Widget _bosArkadasEkrani(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_off_rounded, size: 80, color: theme.disabledColor.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text(
            AppStrings.noFriendsYet, 
            style: AppTextStyles.h3.copyWith(color: theme.disabledColor, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.findFriendsDesc, 
            style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)
          ),
        ],
      ),
    );
  }
}