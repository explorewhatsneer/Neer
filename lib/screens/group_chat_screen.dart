import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import '../main.dart'; // Gerek kalmadı, instance üzerinden alıyoruz

// CORE IMPORTLARI 
import '../core/text_styles.dart';
import '../core/app_strings.dart'; 

// import '../services/firestore_service.dart'; // Servisi devre dışı bıraktık, direct logic yazıyoruz
import '../models/user_model.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/chat/group_message_bubble.dart';
import '../widgets/common/active_users_sheet.dart'; 

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupImage;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    this.groupImage = "",
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  // 🔥 SUPABASE CLIENT
  final _supabase = Supabase.instance.client;
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late String currentUserId;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    final user = _supabase.auth.currentUser;
    if (user != null) {
      currentUserId = user.id;
      _fetchCurrentUser();
    }
  }

  void _fetchCurrentUser() async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUserId)
          .single();
      
      if (mounted) {
        setState(() {
          _currentUser = UserModel.fromMap(data);
        });
      }
    } catch (e) {
      debugPrint("Kullanıcı getirme hatası: $e");
    }
  }

  // 🔥 MESAJ GÖNDERME (SUPABASE)
  void _sendMessage() async {
    HapticFeedback.lightImpact();
    if (_messageController.text.trim().isEmpty || _currentUser == null) return;

    String msg = _messageController.text.trim();
    _messageController.clear();

    try {
      // Mesajı veritabanına ekle
      // Not: 'sender_name' ve 'sender_image' verisini mesajın içine gömüyoruz (Denormalization).
      // Bu sayede her mesaj için tekrar profil sorgusu atmamıza gerek kalmaz.
      await _supabase.from('messages').insert({
        'group_id': widget.groupId, // Mekan ID'si veya Grup ID'si
        'sender_id': currentUserId,
        'message': msg,
        'sender_name': _currentUser!.name,
        'sender_image': _currentUser!.profileImage,
        'created_at': DateTime.now().toIso8601String(), // Supabase formatı
      });

      // Listeyi kaydır
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppStrings.error}: $e"), backgroundColor: Colors.red)
        );
      }
    }
  }

  // Grup Üyelerini Göster
  void _showGroupMembers() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // active_users_sheet dosyasındaki fonksiyonu kullanıyoruz
      builder: (context) => ActiveUsersSheet(chatId: widget.groupId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.groupId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(AppStrings.errorTitle)), 
        body: Center(child: Text(AppStrings.chatError)), 
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: theme.cardColor.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1)))
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.dividerColor, width: 1)
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                backgroundImage: (widget.groupImage.isNotEmpty && widget.groupImage.startsWith('http')) 
                    ? NetworkImage(widget.groupImage) 
                    : null,
                child: (widget.groupImage.isEmpty || !widget.groupImage.startsWith('http')) 
                    ? Icon(Icons.store_mall_directory_rounded, color: theme.primaryColor, size: 20) 
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.groupName, 
                    overflow: TextOverflow.ellipsis,
                    // 🔥 Core Style: BodyLarge (Bold)
                    style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)
                  ),
                  Text(
                    AppStrings.venueChat, // 🔥 Core String
                    // 🔥 Core Style: Caption (Primary Color)
                    style: AppTextStyles.caption.copyWith(color: theme.primaryColor, fontWeight: FontWeight.w600)
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showGroupMembers, 
            icon: Icon(Icons.groups_rounded, color: theme.iconTheme.color, size: 26)
          ),
          const SizedBox(width: 8),
        ],
      ),

      // --- BODY ---
      body: Column(
        children: [
          Expanded(
            // 🔥 SUPABASE REALTIME MESSAGE STREAM
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase
                  .from('messages')
                  .stream(primaryKey: ['id'])
                  .eq('group_id', widget.groupId)
                  .order('created_at', ascending: false), // Yeni mesajlar en başta (Reverse list için)
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: theme.primaryColor));
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      AppStrings.beFirstToMessage, 
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor),
                    ),
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // Mesajlar aşağıdan yukarı dizilir
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + MediaQuery.of(context).padding.top + 20,
                    bottom: 15,
                    left: 16,
                    right: 16
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msgData = messages[index];
                    bool isMe = msgData['sender_id'] == currentUserId;
                    
                    // String tarihi DateTime'a çevir
                    DateTime? timestamp;
                    if (msgData['created_at'] != null) {
                      timestamp = DateTime.parse(msgData['created_at']);
                    }
                    
                    return GroupMessageBubble(
                      message: msgData['message'] ?? "",
                      // Veritabanında snake_case, widget'ta camelCase olabilir
                      senderName: msgData['sender_name'] ?? AppStrings.nameless,
                      senderImage: msgData['sender_image'] ?? "",
                      timestamp: timestamp, // Artık DateTime nesnesi gidiyor
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),

          // --- INPUT ALANI ---
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            // 🔥 Alt güvenli alan (Home Indicator) için padding
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom, 
              ),
              child: ChatInput(
                controller: _messageController,
                onSendPressed: _sendMessage,
                focusNode: FocusNode(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}