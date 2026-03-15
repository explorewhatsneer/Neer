import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// CORE IMPORTLARI
import '../core/text_styles.dart';
import '../core/app_strings.dart'; 

import '../widgets/chat/chat_input.dart';
import '../widgets/chat/message_bubble.dart';
import '../models/user_model.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String? userImage;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.userImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // 🔥 SUPABASE CLIENT
  final _supabase = Supabase.instance.client;
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late String currentUserId;
  UserModel? _currentUser;
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    final user = _supabase.auth.currentUser;
    if (user != null) {
      currentUserId = user.id;
      // Chat Room ID oluşturma mantığı (Alfabetik sıraya göre ID'leri birleştir)
      // Bu sayede A->B ve B->A her zaman aynı odayı açar.
      chatRoomId = _getChatRoomId(currentUserId, widget.userId);
      _fetchCurrentUser();
    }
  }

  // ID'leri sıralayıp tekil oda kimliği oluşturur
  String _getChatRoomId(String userA, String userB) {
    if (userA.compareTo(userB) > 0) {
      return "${userB}_$userA";
    } else {
      return "${userA}_$userB";
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
      debugPrint("Kullanıcı verisi alınamadı: $e");
    }
  }

  // 🔥 MESAJ GÖNDERME
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUser == null) return;
    
    String msg = _messageController.text.trim();
    _messageController.clear();

    try {
      await _supabase.from('messages').insert({
        'room_id': chatRoomId, // Filtreleme için anahtar
        'sender_id': currentUserId,
        'receiver_id': widget.userId,
        'message': msg,
        // group_chat'te olduğu gibi sender bilgilerini de ekleyebiliriz (opsiyonel)
        'sender_name': _currentUser!.name,
        'sender_image': _currentUser!.profileImage,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mesaj gönderilemedi: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      backgroundColor: theme.scaffoldBackgroundColor, 
      
      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: theme.cardColor.withValues(alpha: 0.75), // Yarısaydam
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)))
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
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.scaffoldBackgroundColor,
              backgroundImage: (widget.userImage != null && widget.userImage!.isNotEmpty) 
                  ? NetworkImage(widget.userImage!) 
                  : null,
              child: (widget.userImage == null || widget.userImage!.isEmpty) 
                  ? Text(widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : "?", style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)) 
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName, 
                  // 🔥 Core Style: BodyLarge (Bold)
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(color: Color(0xFF34C759), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      AppStrings.online, 
                      // 🔥 Core Style: Caption
                      style: AppTextStyles.caption.copyWith(color: theme.disabledColor, fontWeight: FontWeight.w600)
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      // --- BODY ---
      body: Column(
        children: [
          Expanded(
            // 🔥 SUPABASE STREAM
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _supabase
                  .from('messages')
                  .stream(primaryKey: ['id'])
                  .eq('room_id', chatRoomId) // Sadece bu iki kişi arasındaki mesajlar
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: theme.primaryColor));
                }
                
                // Mesaj yoksa boş liste döndür, hata verme
                final messages = snapshot.data ?? [];

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, 
                  physics: const BouncingScrollPhysics(), 
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + MediaQuery.of(context).padding.top + 20, 
                    bottom: 15,
                    left: 16,
                    right: 16
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var msgData = messages[index];
                    
                    // DateTime Dönüşümü
                    DateTime? timestamp;
                    if (msgData['created_at'] != null) {
                      timestamp = DateTime.parse(msgData['created_at']);
                    }

                    return MessageBubble(
                      message: msgData['message'] ?? "",
                      timestamp: timestamp,
                      isMe: msgData['sender_id'] == currentUserId,
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
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), 
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