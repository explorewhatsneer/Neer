import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Haptic Feedback
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

// CORE IMPORTLARI
import '../core/theme_styles.dart';
import '../core/text_styles.dart';
import '../core/app_strings.dart';
import '../core/app_router.dart';

import '../services/supabase_service.dart';
import '../widgets/common/app_cached_image.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/animated_list_item.dart';
import '../widgets/common/app_confirm_dialog.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> with SingleTickerProviderStateMixin {
  final _service = SupabaseService();
  
  late TabController _tabController;

  // Arama Kontrolcüsü
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  Key _refreshKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _refreshChats() async {
    HapticFeedback.lightImpact();
    setState(() => _refreshKey = UniqueKey());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Supabase Auth ID
    String myUid = _service.client.auth.currentUser?.id ?? "";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor, 
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            AppStrings.messagesTitle, 
            style: AppTextStyles.h1.copyWith(fontSize: 32) 
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        
        // --- HEADER (ARAMA + TAB BAR) ---
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(134), 
          child: Column(
            children: [
              // 1. PREMIUM ARAMA BARI
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 15),
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
                  onChanged: (val) => setState(() => _searchText = val.trim().toLowerCase()),
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  cursorColor: theme.primaryColor,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchChatsHint, 
                    hintStyle: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor),
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

              // 2. SEGMENTED TAB BAR (iOS STYLE)
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                height: 45,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 2))]
                  ),
                  labelColor: theme.textTheme.bodyLarge?.color,
                  unselectedLabelColor: theme.disabledColor,
                  labelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, fontSize: 13),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  overlayColor: MaterialStateProperty.all(Colors.transparent), 
                  onTap: (index) => HapticFeedback.selectionClick(), 
                  tabs: [
                    Tab(text: AppStrings.chatsTab), 
                    Tab(text: AppStrings.placesTab), 
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalChatsStream(myUid, theme),
          _buildGroupChatsStream(myUid, theme),
        ],
      ),
    );
  }

  // --- 1. BİREYSEL SOHBETLER ---
  Widget _buildPersonalChatsStream(String myUid, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshChats,
      color: theme.primaryColor,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        key: _refreshKey,
        stream: _service.streamRecentMessages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const ShimmerList(itemCount: 6);

        final allMessages = snapshot.data!;

        Map<String, Map<String, dynamic>> lastMessagesMap = {};
        
        for (var msg in allMessages) {
          String senderId = msg['sender_id'];
          String receiverId = msg['receiver_id'] ?? "";

          // Sadece bana gelen veya benim gönderdiğim mesajlar (Ve grup mesajı olmayanlar)
          if ((senderId == myUid || receiverId == myUid) && msg['group_id'] == null) {
             // Karşı tarafın ID'sini bul
             String otherUserId = (senderId == myUid) ? receiverId : senderId;
             
             if (!lastMessagesMap.containsKey(otherUserId)) {
               lastMessagesMap[otherUserId] = {
                 'friendId': otherUserId,
                 'friendName': (senderId == myUid) ? "Giden Mesaj" : (msg['sender_name'] ?? "Kişi"), 
                 'friendAvatar': (senderId == myUid) ? "" : (msg['sender_image'] ?? ""),
                 'lastMessage': msg['message'],
                 'timestamp': msg['created_at'],
                 'isRead': (senderId == myUid) ? true : (msg['is_read'] ?? false), 
               };
             }
          }
        }

        var chats = lastMessagesMap.values.toList();

        if (_searchText.isNotEmpty) {
          chats = chats.where((data) {
            String name = (data['friendName'] ?? "").toString().toLowerCase();
            return name.contains(_searchText);
          }).toList();
        }

        if (chats.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                title: _searchText.isEmpty ? AppStrings.noMessages : AppStrings.noChatFound,
              ),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            var chatData = chats[index];
            return AnimatedListItem(
              index: index,
              child: _buildChatCard(chatData, chatData['friendId'], isGroup: false, myUid: myUid, theme: theme),
            );
          },
        );
      },
      ),
    );
  }

  // --- 2. MEKAN (GRUP) SOHBETLERİ ---
  Widget _buildGroupChatsStream(String myUid, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshChats,
      color: theme.primaryColor,
      child: StreamBuilder<List<Map<String, dynamic>>>(
        key: _refreshKey,
        stream: _service.streamRecentMessages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const ShimmerList(itemCount: 6);
        
        // 🔥 Dart tarafında 'group_id' si null olmayanları alıyoruz
        final allMessages = snapshot.data!.where((m) => m['group_id'] != null).toList();
        
        Map<String, Map<String, dynamic>> lastGroupMessages = {};

        for (var msg in allMessages) {
          String groupId = msg['group_id'];
          
          if (!lastGroupMessages.containsKey(groupId)) {
            lastGroupMessages[groupId] = {
              'groupId': groupId,
              'groupName': "Mekan Sohbeti", // İsim için join gerekir
              'groupImage': "", 
              'lastMessage': msg['message'],
              'lastMessageTime': msg['created_at'],
            };
          }
        }

        var groups = lastGroupMessages.values.toList();

        if (_searchText.isNotEmpty) {
          groups = groups.where((data) {
            String name = (data['groupName'] ?? "").toString().toLowerCase();
            return name.contains(_searchText);
          }).toList();
        }

        if (groups.isEmpty) {
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              EmptyState(
                icon: Icons.store_mall_directory_rounded,
                title: _searchText.isEmpty ? AppStrings.noCheckins : AppStrings.noPlaceFound,
              ),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            var groupData = groups[index];
            return AnimatedListItem(
              index: index,
              child: _buildChatCard(groupData, groupData['groupId'], isGroup: true, myUid: myUid, theme: theme),
            );
          },
        );
      },
      ),
    );
  }

  // --- PREMIUM CHAT CARD ---
  Widget _buildChatCard(Map<String, dynamic> data, String docId, {required bool isGroup, required String myUid, required ThemeData theme}) {
    String name = isGroup ? (data['groupName'] ?? "Mekan") : (data['friendName'] ?? "Kişi");
    String image = isGroup ? (data['groupImage'] ?? "") : (data['friendAvatar'] ?? "");
    bool hasValidImage = image.isNotEmpty && image.startsWith('http');
    bool isDark = theme.brightness == Brightness.dark;

    String lastMsg = data['lastMessage'] ?? "Sohbet başladı.";
    dynamic timestamp = isGroup ? data['lastMessageTime'] : data['timestamp'];

    String timeText = "";
    if (timestamp != null) {
      if (timestamp is String) {
         try {
           DateTime dt = DateTime.parse(timestamp);
           timeText = DateFormat('HH:mm').format(dt);
         } catch(e) {
           timeText = "";
         }
      }
    }

    return Dismissible(
      key: Key(docId),
      direction: DismissDirection.endToStart, 
      
      // Arkadaki Kırmızı Alan
      background: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.only(right: 25),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFFF3B30), // iOS System Red
          borderRadius: AppThemeStyles.radius16,
        ),
        child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
      ),
      
      // Onay Kutusu
      confirmDismiss: (direction) => AppConfirmDialog.show(
        context: context,
        title: isGroup ? AppStrings.leaveVenue : AppStrings.deleteChat,
        content: isGroup
            ? "$name ${AppStrings.leaveGroupConfirm}"
            : "$name ${AppStrings.deleteChatConfirm}",
        confirmText: AppStrings.delete,
        isDestructive: true,
      ),
      
      // Silme İşlemi 
      onDismissed: (direction) async {
        // Silme işlemi
      },

      // --- KART GÖVDESİ ---
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          if (isGroup) {
            context.push(AppRoutes.groupChat, extra: {'groupId': docId, 'groupName': name, 'groupImage': image});
          } else {
            String targetId = data['friendId'] ?? docId;
            context.push(AppRoutes.chat, extra: {'userId': targetId, 'userName': name, 'userImage': image});
          }
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
              // Avatar
              CachedAvatar(
                imageUrl: image,
                name: name,
                radius: 28,
                showOnlineIndicator: !isGroup,
                isOnline: !isGroup,
                backgroundColor: isGroup ? theme.primaryColor.withValues(alpha: 0.1) : null,
              ),
              const SizedBox(width: 16),
              
              // İsim ve Mesaj
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name, 
                            style: AppTextStyles.bodyLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeText, 
                          style: AppTextStyles.caption.copyWith(color: theme.disabledColor, fontWeight: FontWeight.w600)
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lastMsg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        height: 1.2
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // _buildEmptyState removed — now using EmptyState widget inline
}