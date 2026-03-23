import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// FCM Push Notification Servisi
///
/// - Kullanıcıdan bildirim izni ister
/// - FCM token'ını alıp Supabase profiles tablosuna kaydeder
/// - Token yenilendiğinde otomatik günceller
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Servisi başlat: izin iste → token al → db'ye kaydet → yenilenme dinle
  Future<void> init() async {
    // 1. Bildirim izni iste
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Bildirim izni reddedildi');
      return;
    }

    debugPrint('[FCM] İzin durumu: ${settings.authorizationStatus}');

    // 2. Mevcut FCM token'ını al ve kaydet
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToDb(token);
        debugPrint('[FCM] Token kaydedildi: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      debugPrint('[FCM] Token alma hatası: $e');
    }

    // 3. Token yenilendiğinde otomatik güncelle
    _messaging.onTokenRefresh.listen((newToken) async {
      await _saveTokenToDb(newToken);
      debugPrint('[FCM] Token yenilendi ve güncellendi');
    });

    // 4. Foreground mesajları dinle (uygulama açıkken gelen bildirimler)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Foreground mesaj: ${message.notification?.title}');
      // TODO: In-app bildirim göster (overlay/snackbar)
    });

    // 5. Background'dan tıklanan bildirimler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] Bildirime tıklandı: ${message.data}');
      // TODO: İlgili ekrana yönlendir (deep link)
    });
  }

  /// FCM token'ını Supabase profiles tablosuna kaydet/güncelle
  Future<void> _saveTokenToDb(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('profiles').update({
        'fcm_token': token,
      }).eq('id', userId);
    } catch (e) {
      debugPrint('[FCM] Token db kayıt hatası: $e');
    }
  }

  /// Çıkış yapılırken token'ı temizle (başka kullanıcıya bildirim gitmesin)
  Future<void> clearToken() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('profiles').update({
        'fcm_token': null,
      }).eq('id', userId);
      await _messaging.deleteToken();
      debugPrint('[FCM] Token temizlendi');
    } catch (e) {
      debugPrint('[FCM] Token temizleme hatası: $e');
    }
  }
}
