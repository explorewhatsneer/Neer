import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// CORE IMPORTLARI
import '../core/neer_design_system.dart';
import '../core/app_strings.dart';
import '../core/snackbar_helper.dart';

import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../widgets/chat/chat_input.dart';
import '../widgets/chat/group_message_bubble.dart';
import '../widgets/common/active_users_sheet.dart';
import '../widgets/common/shimmer_loading.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/app_cached_image.dart';

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
  final _service = SupabaseService();

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String currentUserId;
  UserModel? _currentUser;

  // 🔥 Rate Limiting State
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final user = _service.client.auth.currentUser;
    if (user != null) {
      currentUserId = user.id;
      _fetchCurrentUser();
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchCurrentUser() async {
    final result = await _service.getUser(currentUserId);
    if (mounted && result.isSuccess) {
      setState(() {
        _currentUser = result.data;
      });
    }
  }

  // ════════════════════════════════════════════
  // 🔥 COOLDOWN ZAMANLAYICISI
  // ════════════════════════════════════════════
  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = seconds);

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldownSeconds--;
        if (_cooldownSeconds <= 0) {
          _cooldownSeconds = 0;
          timer.cancel();
        }
      });
    });
  }

  // ════════════════════════════════════════════
  // 🔥 MESAJ GÖNDERME (Rate Limiting ile)
  // Rapordaki kurallar:
  //   Kimlikli: 3 sn/mesaj (burst: 5, sonra 10 sn)
  //   Anonim Seviye 1: 120 sn, Seviye 2: 60 sn, Seviye 3: 30 sn
  //   Trust < 50: 20 sn cooldown
  // ════════════════════════════════════════════
  void _sendMessage() async {
    HapticFeedback.lightImpact();
    if (_messageController.text.trim().isEmpty || _currentUser == null) return;
    if (_cooldownSeconds > 0 || _isSending) return; // Cooldown aktifse engelle

    String msg = _messageController.text.trim();

    // Karakter limiti kontrolü (rapor: max 280 karakter)
    if (msg.length > 280) {
      _showSnack("Mesaj çok uzun (max 280 karakter).", Colors.orange);
      return;
    }

    // Büyük harf kontrolü (rapor: %70'den fazlası büyük harf ise engelle)
    if (msg.length > 5) {
      int upperCount = msg.runes.where((r) => String.fromCharCode(r).toUpperCase() == String.fromCharCode(r) && String.fromCharCode(r).toLowerCase() != String.fromCharCode(r)).length;
      if (upperCount / msg.length > 0.7) {
        _showSnack("Lütfen tamamını büyük harfle yazma.", Colors.orange);
        return;
      }
    }

    setState(() => _isSending = true);

    try {
      // 🔥 1. RATE LIMIT KONTROLÜ (Sunucu tarafı)
      final rateCheck = await _service.canSendMessage(currentUserId, widget.groupId);

      if (rateCheck['allowed'] != true) {
        int waitSecs = (rateCheck['wait_seconds'] ?? 3).toInt();
        _startCooldown(waitSecs);
        _showSnack("$waitSecs saniye beklemen gerekiyor.", Colors.orange);
        setState(() => _isSending = false);
        return;
      }

      // 🔥 2. MESAJI GÖNDER
      _messageController.clear();

      final sendResult = await _service.sendMessage({
        'group_id': widget.groupId,
        'sender_id': currentUserId,
        'message': msg,
        'sender_name': _currentUser!.name,
        'sender_image': _currentUser!.profileImage,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (sendResult.isFailure) {
        if (_messageController.text.isEmpty) {
          _messageController.text = msg;
        }
        _showSnack("Mesaj gönderilemedi: ${sendResult.error.message}", Colors.red);
        if (mounted) setState(() => _isSending = false);
        return;
      }

      // 🔥 3. Cooldown başlat (sunucudan dönen değerle)
      int cooldown = (rateCheck['cooldown'] ?? 3).toInt();
      if (cooldown > 3) {
        _startCooldown(cooldown);
      }

      // Listeyi kaydır
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      // Hata durumunda mesajı geri koy
      if (_messageController.text.isEmpty) {
        _messageController.text = msg;
      }
      _showSnack("Mesaj gönderilemedi: $e", Colors.red);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showSnack(String text, Color color) {
    if (!mounted) return;
    if (color == Colors.red) {
      AppSnackBar.error(context, text);
    } else if (color == Colors.orange) {
      AppSnackBar.warning(context, text);
    } else {
      AppSnackBar.info(context, text);
    }
  }

  // Grup Üyelerini Göster
  void _showGroupMembers() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

    return GradientScaffold(
      extendBodyBehindAppBar: true,

      // --- APP BAR ---
      appBar: AppBar(
        backgroundColor: isDark
            ? Colors.black.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.45),
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1))),
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
              imageUrl: widget.groupImage,
              radius: 18,
              backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.groupName,
                    overflow: TextOverflow.ellipsis,
                    style: NeerTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    AppStrings.venueChat,
                    style: NeerTypography.caption.copyWith(color: theme.primaryColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showGroupMembers,
            icon: Icon(Icons.groups_rounded, color: theme.iconTheme.color, size: 26),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // --- BODY ---
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _service.streamGroupMessages(widget.groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const ShimmerList(itemCount: 8);
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return EmptyState(
                    icon: Icons.forum_outlined,
                    title: AppStrings.beFirstToMessage,
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: kToolbarHeight + MediaQuery.of(context).padding.top + 20,
                    bottom: 15,
                    left: 12,
                    right: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var msgData = messages[index];
                    bool isMe = msgData['sender_id'] == currentUserId;

                    return GroupMessageBubble(
                      message: msgData['message'] ?? '',
                      senderName: msgData['sender_name'] ?? 'Anonim',
                      senderImage: msgData['sender_image'] ?? '',
                      isMe: isMe,
                      timestamp: DateTime.tryParse(msgData['created_at'] ?? '') ?? DateTime.now(),
                    );
                  },
                );
              },
            ),
          ),

          // --- 🔥 COOLDOWN BANNER ---
          if (_cooldownSeconds > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      value: 1.0, // İleride gerçek progress eklenebilir
                      strokeWidth: 2,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$_cooldownSeconds saniye bekle",
                    style: NeerTypography.caption.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          // --- MESAJ GİRİŞ ALANI ---
          ChatInput(
            controller: _messageController,
            onSendPressed: _sendMessage,
            enabled: _cooldownSeconds <= 0 && !_isSending,
          ),
        ],
      ),
    );
  }
}