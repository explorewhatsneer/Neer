import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// CORE IMPORTLARI
import '../core/constants.dart';
import '../core/text_styles.dart';
import '../core/theme_styles.dart';
import '../core/app_strings.dart';

import '../services/supabase_service.dart';
import '../screens/friend_profile_screen.dart';
import '../screens/business_profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = SupabaseService();
  late String _uid;

  @override
  void initState() {
    super.initState();
    _uid = _service.client.auth.currentUser?.id ?? '';
    // Ekran açıldığında tüm bildirimleri okundu yap
    Future.delayed(const Duration(seconds: 2), () {
      _service.markAllNotificationsRead(_uid);
    });
  }

  // ════════════════════════════════════════════
  // BİLDİRİM TİPİNE GÖRE İKON VE RENK
  // ════════════════════════════════════════════
  _NotifStyle _getStyle(String type) {
    switch (type) {
      case 'follow_request':
        return _NotifStyle(Icons.person_add_rounded, const Color(0xFF5856D6), 'Takip İsteği');
      case 'follow_accept':
        return _NotifStyle(Icons.how_to_reg_rounded, const Color(0xFF34C759), 'Kabul Edildi');
      case 'checkin':
        return _NotifStyle(Icons.location_on_rounded, const Color(0xFFFF9500), 'Check-in');
      case 'message':
        return _NotifStyle(Icons.chat_bubble_rounded, const Color(0xFF007AFF), 'Mesaj');
      case 'system':
        return _NotifStyle(Icons.info_rounded, const Color(0xFF8E8E93), 'Sistem');
      case 'promotion':
        return _NotifStyle(Icons.local_offer_rounded, const Color(0xFFFF2D55), 'Kampanya');
      case 'report_result':
        return _NotifStyle(Icons.shield_rounded, const Color(0xFFFF3B30), 'Moderasyon');
      default:
        return _NotifStyle(Icons.notifications_rounded, const Color(0xFF8E8E93), 'Bildirim');
    }
  }

  // ════════════════════════════════════════════
  // BİLDİRİME TIKLANDIĞINDA YÖNLENDİRME
  // ════════════════════════════════════════════
  void _handleNotificationTap(Map<String, dynamic> notif) {
    HapticFeedback.lightImpact();
    final type = notif['type'] ?? '';
    final data = notif['data'] is Map ? Map<String, dynamic>.from(notif['data']) : <String, dynamic>{};

    switch (type) {
      case 'follow_request':
      case 'follow_accept':
        final senderId = data['sender_id'];
        if (senderId != null) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => FriendProfileScreen(targetUserId: senderId),
          ));
        }
        break;
      case 'checkin':
        final placeId = data['place_id'];
        final placeName = data['place_name'] ?? 'Mekan';
        if (placeId != null) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => BusinessProfileScreen(
              venueId: placeId.toString(),
              venueName: placeName,
              imageUrl: '',
            ),
          ));
        }
        break;
      case 'message':
        // DM ekranına yönlendir — chat_screen.dart
        final senderId = data['sender_id'];
        if (senderId != null) {
          // Basit yönlendirme: profil üzerinden mesajlaşma
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => FriendProfileScreen(targetUserId: senderId),
          ));
        }
        break;
      default:
        break;
    }
  }

  // ════════════════════════════════════════════
  // ZAMAN FORMATLAMA
  // ════════════════════════════════════════════
  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk';
    if (diff.inHours < 24) return '${diff.inHours}sa';
    if (diff.inDays < 7) return '${diff.inDays}g';
    return '${date.day}.${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.cardColor.withValues(alpha: 0.8),
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
        title: Text(
          AppStrings.notifications,
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _service.markAllNotificationsRead(_uid);
            },
            icon: Icon(Icons.done_all_rounded, color: theme.primaryColor, size: 22),
            tooltip: 'Tümünü okundu işaretle',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _service.getNotifications(_uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: theme.primaryColor));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_rounded, size: 64, color: theme.disabledColor.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz bildirim yok',
                    style: AppTextStyles.bodyLarge.copyWith(color: theme.disabledColor, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yeni etkileşimler burada görünecek.',
                    style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 12,
              bottom: 100,
            ),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final style = _getStyle(notif['type'] ?? '');
              final bool isRead = notif['is_read'] ?? false;

              return Dismissible(
                key: Key(notif['id'].toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  color: Colors.red.withValues(alpha: 0.1),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                ),
                onDismissed: (_) {
                  // Bildirimi sil
                  _service.deleteNotification(notif['id']);
                },
                child: InkWell(
                  onTap: () => _handleNotificationTap(notif),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: isRead
                          ? Colors.transparent
                          : (isDark ? Colors.white.withValues(alpha: 0.03) : theme.primaryColor.withValues(alpha: 0.03)),
                      border: Border(
                        bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.08)),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // İkon
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: style.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(style.icon, color: style.color, size: 22),
                        ),
                        const SizedBox(width: 14),

                        // İçerik
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif['title'] ?? style.label,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatTime(notif['created_at']?.toString()),
                                    style: AppTextStyles.caption.copyWith(
                                      color: theme.disabledColor,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              if (notif['body'] != null && notif['body'].toString().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  notif['body'],
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: theme.disabledColor,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Okunmadı noktası
                        if (!isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 6),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════
// YARDIMCI: Bildirim Stili
// ════════════════════════════════════════════
class _NotifStyle {
  final IconData icon;
  final Color color;
  final String label;

  _NotifStyle(this.icon, this.color, this.label);
}