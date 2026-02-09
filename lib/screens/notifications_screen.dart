import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

// CORE IMPORTLARI
import '../core/theme_styles.dart'; 
import '../core/text_styles.dart';
import '../core/app_strings.dart'; 

// WIDGETLAR
import '../widgets/notifications/notification_tile.dart';
import '../widgets/notifications/request_summary_tile.dart';
import 'follow_requests_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _supabase = Supabase.instance.client;
  late String _currentUserId;

  // --- MOCK DATA (Sistem ve Check-in Bildirimleri İçin) ---
  final List<Map<String, dynamic>> _otherNotifications = [
    {
      "id": "2",
      "type": "checkin",
      "title": "Yakınında Hareket Var",
      "body": "Zeynep ve 2 arkadaşın şu an Thru Coffee'de! ☕",
      "time": "15 dk önce",
      "image": "https://i.pravatar.cc/150?img=5",
      "isRead": true,
    },
    {
      "id": "3",
      "type": "system",
      "title": "Anket Sonuçlandı",
      "body": "'Kadıköy'de en iyi kahve' anketin sonuçlandı. Sonuçları gör.",
      "time": "1 saat önce",
      "image": "", 
      "isRead": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentUserId = _supabase.auth.currentUser?.id ?? '';
  }

  // Bildirim Silme
  void _removeNotification(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      _otherNotifications.removeWhere((item) => item['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          AppStrings.notificationsTitle, 
          style: AppTextStyles.h2.copyWith(fontSize: 24)
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.iconTheme.color, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_otherNotifications.isNotEmpty)
            TextButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                setState(() => _otherNotifications.clear());
              }, 
              child: Text(
                AppStrings.clearAll, 
                style: AppTextStyles.button.copyWith(color: theme.colorScheme.error)
              )
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerColor.withOpacity(0.1), height: 1.0), 
        ),
      ),
      
      // 🔥 StreamBuilder: Veritabanındaki değişiklikleri dinler
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('friend_requests')
            .stream(primaryKey: ['id'])
            .eq('receiver_id', _currentUserId),
        builder: (context, snapshot) {
          // İstek listesini al (Yoksa boş liste)
          final friendRequests = snapshot.data ?? [];
          final bool hasRequests = friendRequests.isNotEmpty;
          final bool hasOtherNotifs = _otherNotifications.isNotEmpty;

          // Eğer HİÇ bildirim yoksa
          if (!hasRequests && !hasOtherNotifs) {
            return _buildEmptyState(theme);
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              
              // 1. İSTEK ÖZETİ (Supabase'den canlı veri)
              if (hasRequests) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: RequestSummaryTile(
                    requests: friendRequests, 
                    // 🔥 DÜZELTME BURADA YAPILDI 🔥
                    onTap: () async { 
                      HapticFeedback.selectionClick();
                      
                      // Sayfaya git ve DÖNMESİNİ BEKLE (await)
                      await Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const FriendRequestsScreen())
                      );

                      // Döndüğünde ekranı zorla yenile ki veriler güncellensin
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],

              // 2. DİĞER BİLDİRİMLER (Varsa Göster)
              if (hasOtherNotifs)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık
                      if (hasRequests)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, left: 4, top: 10),
                          child: Text(
                            AppStrings.generalSection, 
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w900, 
                              color: theme.disabledColor,
                              letterSpacing: 1.2
                            )
                          ),
                        ),
                    
                      ..._otherNotifications.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NotificationTile(
                          key: ValueKey(item['id']),
                          id: item['id'],
                          type: item['type'],
                          title: item['title'],
                          body: item['body'],
                          time: item['time'],
                          imageUrl: item['image'],
                          isRead: item['isRead'],
                          onDismiss: _removeNotification,
                        ),
                      )),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // --- BOŞ DURUM ---
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
              boxShadow: AppThemeStyles.shadowLow,
            ),
            child: Icon(Icons.notifications_off_rounded, size: 60, color: theme.disabledColor.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.noNotifications, 
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold, 
              color: theme.textTheme.bodyLarge?.color
            )
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.allQuiet, 
            style: AppTextStyles.bodySmall.copyWith(color: theme.disabledColor)
          ),
        ],
      ),
    );
  }
}