import 'dart:ui';
import 'package:flutter/material.dart';

// CORE IMPORTLARI
import '../core/constants.dart';
import '../core/text_styles.dart';
import '../core/app_strings.dart';
import '../core/snackbar_helper.dart';

import '../services/supabase_service.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/common/app_cached_image.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/empty_state.dart';
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
  final _service = SupabaseService();

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String currentUserId;
  UserModel? _currentUser;
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    final user = _service.client.auth.currentUser;
    if (user != null) {
      currentUserId = user.id;
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
    final result = await _service.getUser(currentUserId);
    if (mounted && result.isSuccess) {
      setState(() {
        _currentUser = result.data;
      });
    }
  }

  // 🔥 MESAJ GÖNDERME
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _currentUser == null) return;
    
    String msg = _messageController.text.trim();
    _messageController.clear();

    final result = await _service.sendMessage({
      'room_id': chatRoomId,
      'sender_id': currentUserId,
      'receiver_id': widget.userId,
      'message': msg,
      'sender_name': _currentUser!.name,
      'sender_image': _currentUser!.profileImage,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (result.isFailure) {
      if (mounted) {
        AppSnackBar.error(context, "Mesaj gönderilemedi: ${result.error.message}");
      }
      return;
    }

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.45),
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
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
            CachedAvatar(
              imageUrl: widget.userImage ?? '',
              name: widget.userName,
              radius: 18,
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
              stream: _service.streamDMMessages(chatRoomId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ShimmerList(itemCount: 8);
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: AppStrings.noMessages,
                    description: 'İlk mesajı gönder!',
                  );
                }

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

          // --- GLASS INPUT AREA ---
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 45, sigmaY: 45),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface.withValues(alpha: 0.14)
                      : Colors.white.withValues(alpha: 0.22),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 0.5,
                    ),
                  ),
                ),
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
            ),
          ),
        ],
      ),
    );
  }
}